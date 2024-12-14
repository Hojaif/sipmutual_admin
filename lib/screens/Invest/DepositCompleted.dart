import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepositCompleted extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  DepositCompleted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Deposit Completed',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Fetch only users with isActive == true
        stream: firestore.collection('users').snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No active users found.'));
          }

          return ListView.builder(
            itemCount: userSnapshot.data!.docs.length,
            itemBuilder: (context, userIndex) {
              final userDoc = userSnapshot.data!.docs[userIndex];
              final userId = userDoc.id;
              final userData = userDoc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: Text(
                    'Name:   ${userData['name'] ?? 'Unknown'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: firestore
                          .collection('deposites')
                          .doc(userId)
                          .collection('userDepoites')
                          .where('isActive', isEqualTo: true)
                          .snapshots(),
                      builder: (context, depositSnapshot) {
                        if (depositSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!depositSnapshot.hasData ||
                            depositSnapshot.data!.docs.isEmpty) {
                          return const ListTile(
                            title: Text('No completed deposits found.'),
                          );
                        }

                        return ListView.builder(
                          itemCount: depositSnapshot.data!.docs.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, depositIndex) {
                            final depositDoc =
                                depositSnapshot.data!.docs[depositIndex];
                            final depositData =
                                depositDoc.data() as Map<String, dynamic>;

                            return ListTile(
                              title: Text(
                                  'Deposit Name: ${depositData['name'] ?? 'No details'}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Number: ${depositData['number'] ?? 'No details'}'),
                                  Text(
                                      'Transaction ID: ${depositData['id'] ?? 'No details'}'),
                                ],
                              ),
                              trailing: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text(
                                    'Complete',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
