import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Streams for user counts
  Stream<int> _getAllUserCount() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.length; // Total user count
    });
  }

  Stream<int> _getActiveUserCount() {
    return _firestore
        .collection('users')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.length; // Active user count
    });
  }

  Stream<int> _getUnActiveUserCount() {
    return _firestore
        .collection('users')
        .where('isActive', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.length; // Canceled user count
    });
  }

  Stream<int> _getactiverequestUserCount() {
    return _firestore
        .collection('accountActive')
        .where('isActive', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size to make the UI responsive
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;

    return Scaffold(
      body: Column(
        children: [
          // Dashboard Header
          Container(
            width: double.infinity,
            height: 50,
            color: Colors.green,
            child: const Center(
              child: Text(
                'Dashboard',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Stat cards - Use Grid for larger screens and List for smaller
                  isMobile
                      ? SingleChildScrollView(
                          child: Column(
                            children: [
                              // All Users
                              StreamBuilder<int>(
                                stream: _getAllUserCount(),
                                builder: (context, snapshot) {
                                  int allUsers = snapshot.data ?? 0;
                                  return _buildStatCard(
                                      'All Users', allUsers.toString());
                                },
                              ),
                              const SizedBox(height: 10),
                              // Active Users
                              StreamBuilder<int>(
                                stream: _getActiveUserCount(),
                                builder: (context, snapshot) {
                                  int activeUsers = snapshot.data ?? 0;
                                  return _buildStatCard(
                                      'Active Users', activeUsers.toString());
                                },
                              ),
                              const SizedBox(height: 10),
                              // Canceled Users
                              StreamBuilder<int>(
                                stream: _getUnActiveUserCount(),
                                builder: (context, snapshot) {
                                  int canceledUsers = snapshot.data ?? 0;
                                  return _buildStatCard('UnActive Users',
                                      canceledUsers.toString());
                                },
                              ),
                              const SizedBox(height: 10),
                              // Active Request
                              StreamBuilder<int>(
                                stream: _getactiverequestUserCount(),
                                builder: (context, snapshot) {
                                  int activeRequests = snapshot.data ?? 0;
                                  return _buildStatCard('Active Request',
                                      activeRequests.toString());
                                },
                              ),
                            ],
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // All Users
                            StreamBuilder<int>(
                              stream: _getAllUserCount(),
                              builder: (context, snapshot) {
                                int allUsers = snapshot.data ?? 0;
                                return _buildStatCard(
                                    'All Users', allUsers.toString());
                              },
                            ),
                            const SizedBox(width: 10),
                            // Active Users
                            StreamBuilder<int>(
                              stream: _getActiveUserCount(),
                              builder: (context, snapshot) {
                                int activeUsers = snapshot.data ?? 0;
                                return _buildStatCard(
                                    'Active Users', activeUsers.toString());
                              },
                            ),
                            const SizedBox(width: 10),
                            // Canceled Users
                            StreamBuilder<int>(
                              stream: _getUnActiveUserCount(),
                              builder: (context, snapshot) {
                                int canceledUsers = snapshot.data ?? 0;
                                return _buildStatCard(
                                    'UnActive Users', canceledUsers.toString());
                              },
                            ),
                            const SizedBox(width: 10),
                            // Active Request
                            StreamBuilder<int>(
                              stream: _getactiverequestUserCount(),
                              builder: (context, snapshot) {
                                int activeRequests = snapshot.data ?? 0;
                                return _buildStatCard('Active Request',
                                    activeRequests.toString());
                              },
                            ),
                          ],
                        ),
                  const SizedBox(height: 20),
                  // Chart - Takes full width on smaller screens, fixed width on large screens
                  isMobile
                      ? SizedBox(height: 20)
                      : SizedBox(
                          width: isMobile ? double.infinity : 600,
                          child: SfCartesianChart(
                              primaryXAxis: CategoryAxis(),
                              series: <LineSeries<SalesData, String>>[
                                LineSeries<SalesData, String>(
                                    dataSource: <SalesData>[
                                      SalesData('Jan', 35),
                                      SalesData('Feb', 28),
                                      SalesData('Mar', 34),
                                      SalesData('Apr', 32),
                                      SalesData('May', 40)
                                    ],
                                    xValueMapper: (SalesData sales, _) =>
                                        sales.year,
                                    yValueMapper: (SalesData sales, _) =>
                                        sales.sales),
                              ])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build a stat card
  Widget _buildStatCard(String title, String value) {
    return Container(
      height: 80,
      width: 240,
      decoration: BoxDecoration(
          color: Colors.green, borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final double sales;
}
