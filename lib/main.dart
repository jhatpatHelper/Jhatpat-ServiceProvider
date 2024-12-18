import 'package:flutter/material.dart';
import 'login.dart'; // Import LoginPage
import 'edit_profile.dart'; // Import EditProfilePage
import 'home.dart'; // Import HomePage

void main() {
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
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(), // Start with LoginPage
        '/edit_profile': (context) => const EditProfilePage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
