import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to send OTP
  Future<void> sendOtp(String phoneNumber, Function(String) onOtpSent, Function(String) onVerificationFailed) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException ex) {
        onVerificationFailed(ex.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        onOtpSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Function to verify OTP
  Future<UserCredential> verifyOtp(String verificationId, String otp) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    return await _auth.signInWithCredential(credential);
  }

  // Check if the phone number exists in Firestore
  Future<bool> isPhoneNumberExists(String phoneNumber) async {
    try {
      var snapshot = await _firestore
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking phone number in Firestore: $e');
      return false;
    }
  }

  // Add new user to Firestore
  Future<void> addUserToFirestore(String phoneNumber) async {
    try {
      await _firestore.collection('users').add({
        'phone': phoneNumber,
        'createdAt': Timestamp.now(),
      });
      print("User added to Firestore");
    } catch (e) {
      print("Error adding user to Firestore: $e");
    }
  }

  // Get user data by phone number
  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> getUserByPhoneNumber(String phoneNumber) async {
    var userSnapshot = await _firestore
        .collection('users')
        .where('phone', isEqualTo: phoneNumber)
        .limit(1)
        .get();
    return userSnapshot.docs.isNotEmpty ? userSnapshot.docs.first : null;
  }
}


