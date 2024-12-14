import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Sipnscreen extends StatefulWidget {
  const Sipnscreen({super.key});

  @override
  State<Sipnscreen> createState() => _SipnscreenState();
}

class _SipnscreenState extends State<Sipnscreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch data from Firestore
  Stream<QuerySnapshot> getSipnData() {
    return _firestore.collection('spins').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'Sipn Data',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.topRight,
            child: TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController controller = TextEditingController();

                    return AlertDialog(
                      title: const Text("Add Sipn Data"),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: "Enter value",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            final value = controller.text.trim();

                            if (value.isNotEmpty) {
                              try {
                                // Add data to Firestore
                                await _firestore
                                    .collection('spins')
                                    .add({'value': value});

                                // Close the dialog
                                Navigator.of(context).pop();
                              } catch (e) {
                                print("Error adding data: $e");
                              }
                            } else {
                              // Optionally show a validation error
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Value cannot be empty!"),
                                ),
                              );
                            }
                          },
                          child: const Text("Add"),
                        ),
                      ],
                    );
                  },
                );
              },
              label: const Row(
                children: [Icon(Icons.add), Text('Add Sipn Data')],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getSipnData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No data found'),
                  );
                }

                // Retrieve and display data from snapshot
                final List<DocumentSnapshot> documents = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final data =
                        documents[index].data() as Map<String, dynamic>;
                    final value = data['value'] ?? 'No Value';

                    return Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Text(
                              'Value: $value',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.black),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                _firestore
                                    .collection('spins')
                                    .doc(documents[index].id)
                                    .delete();
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
