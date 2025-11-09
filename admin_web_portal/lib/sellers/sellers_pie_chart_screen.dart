import 'dart:math';
import 'package:admin_web_portal/widgets/nav_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SellersPieChartScreen extends StatefulWidget {
  @override
  State<SellersPieChartScreen> createState() => _SellersPieChartScreenState();
}

class _SellersPieChartScreenState extends State<SellersPieChartScreen> {
  int totalNumberOfVerifiedSellers = 0;
  int totalNumberOfBlockedSellers = 0;

  @override
  void initState() {
    super.initState();
    getTotalNumberOfVerifiedSellers();
    getTotalNumberOfBlockedSellers();
  }

  Future<void> getTotalNumberOfVerifiedSellers() async {
    try {
      QuerySnapshot allVerifiedSellers = await FirebaseFirestore.instance
          .collection("sellers")
          .where("status", isEqualTo: "approved")
          .get();
      setState(() {
        totalNumberOfVerifiedSellers = allVerifiedSellers.docs.length;
      });
    } catch (e) {
      print("Error fetching verified sellers: $e");
    }
  }

  Future<void> getTotalNumberOfBlockedSellers() async {
    try {
      QuerySnapshot allBlockedSellers = await FirebaseFirestore.instance
          .collection("sellers")
          .where("status", isEqualTo: "not approved")
          .get();
      setState(() {
        totalNumberOfBlockedSellers = allBlockedSellers.docs.length;
      });
    } catch (e) {
      print("Error fetching blocked sellers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalSellers = totalNumberOfVerifiedSellers + totalNumberOfBlockedSellers;
    double verifiedPercentage = totalSellers > 0 ? (totalNumberOfVerifiedSellers / totalSellers) * 100 : 0;
    double blockedPercentage = totalSellers > 0 ? (totalNumberOfBlockedSellers / totalSellers) * 100 : 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: NavAppBar(title: "Cambridge"),
      body: Center(
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                value: totalNumberOfBlockedSellers.toDouble(),
                color: Colors.pinkAccent,
                title: 'Blocked Sellers\n${blockedPercentage.toStringAsFixed(1)}%',
                radius: 80,
                titleStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                value: totalNumberOfVerifiedSellers.toDouble(),
                color: Colors.deepPurpleAccent,
                title: 'Verified Sellers\n${verifiedPercentage.toStringAsFixed(1)}%',
                radius: 80,
                titleStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
            sectionsSpace: 5,
            centerSpaceRadius: 40,
          ),
        ),
      ),
    );
  }
}
