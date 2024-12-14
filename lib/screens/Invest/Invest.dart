import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Invest extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Invest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'All User Investments',
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
                    'Name:   ${userData['name'] ?? 'Unknown'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: firestore
                          .collection('investments')
                          .doc(userId)
                          .collection('userInvestments')
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
                            title: Text('No orders found for this user.'),
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
                                  'Invest Name: ${orderData['name'] ?? 'No details'}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'InvestAmount: ${orderData['investAmount'] ?? 'No details'}'),
                                  Text(
                                      'Invested Year: ${orderData['year'] ?? 'No details'}'),
                                ],
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  firestore
                                      .collection('investments')
                                      .doc(userId)
                                      .collection('userInvestments')
                                      .doc(orderDoc.id)
                                      .delete();
                                },
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Investment Details'),
                                    content: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            'User Name: ${userData['name'] ?? 'No details'}'),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Text(
                                            'Investment Name: ${orderData['name'] ?? 'No details'}'),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Text(
                                            'Invest Amount: ${orderData['investAmount']?.toString() ?? 'No details'}'),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Text(
                                            'Year: ${orderData['year']?.toString() ?? 'No details'}'),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Text(
                                            'Total Amount: ${orderData['totalValue']?.toString() ?? 'No details'}'),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
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
