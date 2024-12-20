import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jhatpat_serviceprovider/services/auth/auth_gate.dart';
import 'login.dart'; // Import LoginPage
import 'edit_profile.dart'; // Import EditProfilePage
import 'home.dart'; // Import HomePage

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized
  await Firebase.initializeApp(); // Initialize Firebase before running the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Flow',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthGate(), // Use AuthGate as the entry point
      routes: {
        '/login': (context) => const LoginPage(), // Start with LoginPage
        '/edit_profile': (context) => const EditProfilePage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
