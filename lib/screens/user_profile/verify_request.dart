import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerifiedRequest extends StatefulWidget {
  const VerifiedRequest({super.key});

  @override
  State<VerifiedRequest> createState() => _VerifiedRequestState();
}

class _VerifiedRequestState extends State<VerifiedRequest> {
  final CollectionReference _accounts =
      FirebaseFirestore.instance.collection('accountActive');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Verify Request',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _accounts.where('isActive', isEqualTo: false).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No active accounts found.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          final data = snapshot.data!.docs;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final account = data[index].data() as Map<String, dynamic>;
              final docId = data[index].id; // Document ID from accountActive

              return Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            account['id'] ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(account['userid'])
                                  .update({
                                'isActive': true,
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                              await FirebaseFirestore.instance
                                  .collection('accountActive')
                                  .doc(account['userid'])
                                  .update({
                                'isActive': true,
                                'createdAt': FieldValue.serverTimestamp(),
                              });
                            },
                            child: const Text('Accept'),
                          ),
                          TextButton(
                            onPressed: () {
                              _showDetailsDialog(account);
                            },
                            child: const Text('Details'),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Amount: ${account['activeAmount'] ?? 'N/A'}',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black),
                          ),
                          const Spacer(),
                          Text(
                            'Number: ${account['number'] ?? 'N/A'}',
                            style: const TextStyle(
                                fontSize: 18, color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDetailsDialog(Map<String, dynamic> account) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Details of ${account['id'] ?? 'Unknown'}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              account['image'] != null
                  ? Image.network(account['image'])
                  : const Text('No image available'),
              const SizedBox(height: 8),
              Text(
                'ID: ${account['id'] ?? 'Unknown'}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Amount: ${account['activeAmount'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
