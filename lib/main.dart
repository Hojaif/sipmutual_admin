import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sipn_admin/screens/HomeScreen.dart';
import 'firebase_options.dart'; // Import the generated options file

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions
        .currentPlatform, // Use configuration for the platform
  );
  runApp(const DashboardApp());
}

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Homescreen(),
    );
  }
}
