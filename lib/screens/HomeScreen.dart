import 'package:flutter/material.dart';
import 'package:sipn_admin/screens/Dashboard/Dashboard.dart';
import 'package:sipn_admin/screens/Invest/DepositCompleted.dart';
import 'package:sipn_admin/screens/Invest/DepositRequest.dart';
import 'package:sipn_admin/screens/Invest/Invest.dart';
import 'package:sipn_admin/screens/SipnScreen.dart';
import 'package:sipn_admin/screens/Withdraw/WithdrawRequest.dart';
import 'package:sipn_admin/screens/Withdraw/WithdrawalCompleted.dart';
import 'package:sipn_admin/screens/user_profile/verify.dart';
import 'package:sipn_admin/screens/user_profile/verify_request.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int? expandedCardIndex;
  Widget? selectedScreen;

  // Left panel items
  final List<String> items = [
    'Dashboard',
    'Invest',
    'Withdraw',
    'Game',
    'User Profile',
    'Profile',
  ];

  // Sub-items with corresponding screens
  final List<Map<String, Widget>> subItemsWithScreens = [
    {},
    {
      'Invest': Invest(),
      'Deposit Request': DepositiveRequest(),
      'Deposit Completed': DepositCompleted(),
    },
    {
      'Withdraw Request': WithdrawRequest(),
      'Withdrawal Completed': WithdrawCompleted()
    },
    {'Add Sipn Data': const Sipnscreen()},
    {
      'Verify Request': const VerifiedRequest(),
      'Verified': const VerifiedScreen()
    },
    {},
  ];

  @override
  void initState() {
    super.initState();
    selectedScreen = const Dashboard(); // Default screen
  }

  void onItemSelect(String item, Widget? screen) {
    setState(() {
      selectedScreen = screen ?? Center(child: Text('Screen for $item'));
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Get screen size
    final bool isWideScreen = size.width > 800; // Define breakpoint

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: isWideScreen
          ? null
          : AppBar(
              backgroundColor: Colors.green,
              title: const Text('SIP Mutual Fund'),
            ),
      drawer: isWideScreen
          ? null
          : Drawer(
              child: Column(
                children: [
                  // Drawer Header
                  Container(
                    height: 100,
                    color: Colors.green,
                    child: const Center(
                      child: Text(
                        'SIP MUTUAL FUND',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(child: _buildLeftPanel()),
                ],
              ),
            ),
      body: Row(
        children: [
          // Left Panel (Only visible on wide screens)
          if (isWideScreen)
            Expanded(
              flex: 2,
              child: _buildLeftPanel(),
            ),
          // Right Panel
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.blue.shade900,
              child: selectedScreen,
            ),
          ),
        ],
      ),
    );
  }

  // Build the left panel (common for Drawer and Wide Screen)
  Widget _buildLeftPanel() {
    return Column(
      children: [
        const SizedBox(height: 10),
        // List items
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          expandedCardIndex =
                              (expandedCardIndex == index) ? null : index;
                        });
                        if (subItemsWithScreens[index].isEmpty) {
                          onItemSelect(items[index], const Dashboard());
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Text(
                                items[index],
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                              const Spacer(),
                              Icon(
                                expandedCardIndex == index
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Sub-items
                  if (expandedCardIndex == index &&
                      subItemsWithScreens[index].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: subItemsWithScreens[index]
                            .entries
                            .map(
                              (entry) => ListTile(
                                title: Text(entry.key),
                                leading: const Icon(
                                  Icons.list,
                                  color: Colors.green,
                                ),
                                onTap: () {
                                  onItemSelect(entry.key, entry.value);

                                  Navigator.pop(context); // Close Drawer
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
