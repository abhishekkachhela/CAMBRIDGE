// lib/reportsScreen/reports_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cambridge_customer/global/global.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late Stream<QuerySnapshot> ordersStream;
  int selectedYear = DateTime.now().year;
  List<int> availableYears = [];
  Map<String, int> monthlyOrders = {};
  double totalRevenue = 0;
  int totalOrders = 0;

  @override
  void initState() {
    super.initState();
    ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('orderBy', isEqualTo: sharedPreferences!.getString('uid'))
        .snapshots();

    _loadAvailableYears();
  }

  DateTime? _parseOrderTime(dynamic orderTime) {
    if (orderTime is Timestamp) {
      return orderTime.toDate();
    } else if (orderTime is String) {
      try {
        return DateTime.parse(orderTime);
      } catch (e) {
        print("Error parsing date string: $e");
        return null;
      }
    }
    return null;
  }

  void _loadAvailableYears() async {
    final QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('orderBy', isEqualTo: sharedPreferences!.getString('uid'))
        .get();

    Set<int> years = {};

    for (var doc in ordersSnapshot.docs) {
      final orderData = doc.data() as Map<String, dynamic>;
      final orderDate = _parseOrderTime(orderData['orderTime']);
      if (orderDate != null) {
        years.add(orderDate.year);
      }
    }

    setState(() {
      availableYears = years.toList()..sort();
      if (availableYears.isNotEmpty) {
        selectedYear = availableYears.last;
      }
    });
  }

  void _analyzeOrders(List<QueryDocumentSnapshot> orders) {
    monthlyOrders.clear();
    totalRevenue = 0;
    totalOrders = 0;

    // Initialize all months with 0
    for (int i = 1; i <= 12; i++) {
      String monthName = DateFormat('MMMM').format(DateTime(2024, i, 1));
      monthlyOrders[monthName] = 0;
    }

    for (var order in orders) {
      final orderData = order.data() as Map<String, dynamic>;
      final orderDate = _parseOrderTime(orderData['orderTime']);

      if (orderDate != null && orderDate.year == selectedYear) {
        String monthName = DateFormat('MMMM').format(orderDate);
        monthlyOrders[monthName] = (monthlyOrders[monthName] ?? 0) + 1;

        totalOrders++;

        if (orderData['totalAmount'] != null) {
          if (orderData['totalAmount'] is num) {
            totalRevenue += (orderData['totalAmount'] as num).toDouble();
          } else if (orderData['totalAmount'] is String) {
            totalRevenue += double.tryParse(orderData['totalAmount']) ?? 0;
          }
        }
      }
    }
  }

  List<BarChartGroupData> _createBarGroups() {
    final List<MapEntry<String, int>> sortedEntries = monthlyOrders.entries.toList()
      ..sort((a, b) => DateFormat('MMMM').parse(a.key).month.compareTo(
          DateFormat('MMMM').parse(b.key).month));

    return sortedEntries.asMap().entries.map((entry) {
      double value = entry.value.value.toDouble();

      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: value,
            color: Colors.blue,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY() {
    double maxValue = 0;
    monthlyOrders.values.forEach((value) {
      if (value > maxValue) {
        maxValue = value.toDouble();
      }
    });
    return maxValue * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Reports'),
        backgroundColor: Colors.black54,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ordersStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          _analyzeOrders(snapshot.data!.docs);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Year Selection
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Text('Select Year: ',
                            style: TextStyle(fontSize: 16)),
                        if (availableYears.isNotEmpty)
                          DropdownButton<int>(
                            value: selectedYear,
                            items: availableYears.map((year) {
                              return DropdownMenuItem<int>(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }).toList(),
                            onChanged: (year) {
                              if (year != null) {
                                setState(() {
                                  selectedYear = year;
                                });
                              }
                            },
                          )
                        else
                          const Text('No data available'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Summary Cards
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text('Total Orders',
                                  style: TextStyle(fontSize: 16)),
                              Text(totalOrders.toString(),
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text('Total Revenue',
                                  style: TextStyle(fontSize: 16)),
                              Text(
                                  '\$${totalRevenue.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (monthlyOrders.isNotEmpty) ...[
                  const SizedBox(height: 20),

                  // Monthly Orders Chart
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text('Monthly Orders Distribution',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 300,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: _getMaxY(),
                                barGroups: _createBarGroups(),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final monthsList = monthlyOrders.keys.toList()
                                          ..sort((a, b) => DateFormat('MMMM')
                                              .parse(a)
                                              .month
                                              .compareTo(DateFormat('MMMM')
                                              .parse(b)
                                              .month));
                                        if (value.toInt() >= 0 &&
                                            value.toInt() < monthsList.length) {
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              monthsList[value.toInt()]
                                                  .substring(0, 3),
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                    ),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                gridData: FlGridData(show: false),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Monthly Breakdown Table
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Monthly Breakdown',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Table(
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1),
                            },
                            children: [
                              const TableRow(
                                children: [
                                  TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Month',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  TableCell(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Orders',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                              ...monthlyOrders.entries
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                return TableRow(
                                  children: [
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(entry.value.key),
                                      ),
                                    ),
                                    TableCell(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(entry.value.value.toString()),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}