import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepositiveRequest extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  DepositiveRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Depositive Request',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Fetch only users with isActive == false
        stream: firestore
            .collection('users')
            .where('isActive', isEqualTo: false) // Add this filter
            .snapshots(),
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
                      // Fetch only deposits where isActive == false
                      stream: firestore
                          .collection('deposites')
                          .doc(userId)
                          .collection('userDepoites')
                          .where('isActive',
                              isEqualTo: false) // Add this filter
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
                            title: Text('No deposits found for this user.'),
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
                                  'DepositiveRequest Name: ${orderData['name'] ?? 'No details'}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Number: ${orderData['number'] ?? 'No details'}'),
                                  Text(
                                      'Trx Id: ${orderData['id'] ?? 'No details'}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                    onPressed: () {
                                      firestore
                                          .collection('deposites')
                                          .doc(userId)
                                          .collection('userDepoites')
                                          .doc(orderDoc.id)
                                          .update({'isActive': true});
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      firestore
                                          .collection('deposites')
                                          .doc(userId)
                                          .collection('userDepoites')
                                          .doc(orderDoc.id)
                                          .delete();
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                        'DepositiveRequestment Details'),
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
                                            'DepositiveRequestment Name: ${orderData['name'] ?? 'No details'}'),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Text(
                                            'DepositiveRequest Amount: ${orderData['DepositiveRequestAmount']?.toString() ?? 'No details'}'),
                                        const SizedBox(
                                          height: 16,
                                        ),
                                        Text(
                                            'TrxId: ${orderData['id']?.toString() ?? 'No details'}'),
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
