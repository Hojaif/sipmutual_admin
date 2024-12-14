import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class WithdrawCompleted extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  WithdrawCompleted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'All User Withdrawal Requests',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('users').snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
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
                    'Name: ${userData['name'] ?? 'Unknown'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: firestore
                          .collection('withdraws')
                          .doc(userId)
                          .collection('userWithdraws')
                          .where('withdraw', isEqualTo: true)
                          .snapshots(),
                      builder: (context, orderSnapshot) {
                        if (orderSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!orderSnapshot.hasData ||
                            orderSnapshot.data!.docs.isEmpty) {
                          return const ListTile(
                            title: Text('No withdrawal requests found.'),
                          );
                        }
                        return ListView.builder(
                          itemCount: orderSnapshot.data!.docs.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, orderIndex) {
                            final orderDoc =
                                orderSnapshot.data!.docs[orderIndex];
                            final orderData =
                                orderDoc.data() as Map<String, dynamic>;

                            return ListTile(
                                title: Text(
                                    'Number: ${orderData['number'] ?? 'No details'}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Amount: ${orderData['withdrawAmount']?.toString() ?? 'No details'}'),
                                  ],
                                ),
                                trailing: const Text(
                                  'Complete',
                                  style: TextStyle(color: Colors.green),
                                ));
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
