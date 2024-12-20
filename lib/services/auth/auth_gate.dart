import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  bool _isProfileComplete(Map<String, dynamic>? data) {
    if (data == null) return false;

    // Define required fields
    List<String> requiredFields = ['name', 'dob', 'location', 'specialty', 'category'];

    // Check if all required fields are present and non-empty
    for (String field in requiredFields) {
      if (data[field] == null || data[field].toString().isEmpty) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      // Redirect to login if no user is logged in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('service-providers').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Error: ${snapshot.error}"),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          Map<String, dynamic>? userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (_isProfileComplete(userData)) {
            // Redirect to home if the profile is complete
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/home');
            });
          } else {
            // Redirect to edit profile if the profile is incomplete
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/edit_profile');
            });
          }
        } else {
          return const Scaffold(
            body: Center(
              child: Text("No user data found."),
            ),
          );
        }

        return const SizedBox(); // Placeholder to prevent rendering issues
      },
    );
  }
}
