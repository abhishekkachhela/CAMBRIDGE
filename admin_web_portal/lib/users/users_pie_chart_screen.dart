import 'dart:math';
import 'package:admin_web_portal/widgets/nav_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UsersPieChartScreen extends StatefulWidget {
  @override
  State<UsersPieChartScreen> createState() => _UsersPieChartScreenState();
}

class _UsersPieChartScreenState extends State<UsersPieChartScreen> {
  int totalNumberOfVerifiedUsers = 0;
  int totalNumberOfBlockedUsers = 0;

  @override
  void initState() {
    super.initState();
    getTotalNumberOfVerifiedUsers();
    getTotalNumberOfBlockedUsers();
  }

  getTotalNumberOfVerifiedUsers() async {
    FirebaseFirestore.instance
        .collection("users")
        .where("status", isEqualTo: "approved")
        .get()
        .then((allVerifiedUsers) {
      setState(() {
        totalNumberOfVerifiedUsers = allVerifiedUsers.docs.length;
      });
    });
  }

  getTotalNumberOfBlockedUsers() async {
    FirebaseFirestore.instance
        .collection("users")
        .where("status", isEqualTo: "not approved")
        .get()
        .then((allBlockedUsers) {
      setState(() {
        totalNumberOfBlockedUsers = allBlockedUsers.docs.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalUsers = totalNumberOfVerifiedUsers + totalNumberOfBlockedUsers;
    double verifiedPercentage = totalUsers > 0 ? (totalNumberOfVerifiedUsers / totalUsers) * 100 : 0;
    double blockedPercentage = totalUsers > 0 ? (totalNumberOfBlockedUsers / totalUsers) * 100 : 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: NavAppBar(title: "Cambridge"),
      body: Center(
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                value: totalNumberOfBlockedUsers.toDouble(),
                color: Colors.pinkAccent,
                title: 'Blocked Users\n${blockedPercentage.toStringAsFixed(1)}%',
                radius: 80,
                titleStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                value: totalNumberOfVerifiedUsers.toDouble(),
                color: Colors.deepPurpleAccent,
                title: 'Verified Users\n${verifiedPercentage.toStringAsFixed(1)}%',
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
