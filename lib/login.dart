import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jhatpat_serviceprovider/services/auth/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _buttonScale;

  bool _showOtpField = false;
  String verificationId = "";
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _buttonScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // Method to send OTP using AuthService
  void _sendOtp(String phoneNumber) async {  // Added this method
    await _authService.sendOtp(
      phoneNumber,
          (String verificationId) {  // Callback when OTP is sent
        setState(() {
          this.verificationId = verificationId;
          _showOtpField = true;  // Show OTP field once OTP is sent
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP sent to $phoneNumber')),
        );
      },
          (String error) {  // Callback for errors in sending OTP
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: $error')),
        );
      },
    );
  }

  // Method to verify OTP using AuthService
  void _verifyOtp() async {  // Added this method
    String otp = _otpController.text.trim();
    if (otp.isNotEmpty) {
      try {
        await _authService.verifyOtp(verificationId, otp);  // Verifies the OTP
        String phoneNumber = _phoneController.text.trim();

        // Check if phone number exists in Firestore and handle user redirection
        bool phoneExists = await _authService.isPhoneNumberExists(phoneNumber);

        if (!phoneExists) {  // If phone does not exist, add to Firestore
          await _authService.addUserToFirestore(phoneNumber);
          Navigator.pushReplacementNamed(context, '/edit_profile');
        } else{
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid OTP, please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter OTP')),
      );
    }
  }


  // void _onSubmit() {
  //   if (_phoneController.text.isNotEmpty && !_showOtpField) {
  //     setState(() {
  //       _showOtpField = true;
  //     });
  //   } else if (_otpController.text.isNotEmpty) {
  //     Navigator.pushNamed(context, '/edit_profile'); // Redirect to EditProfilePage
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: _showOtpField ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Visibility(
                visible: _showOtpField,
                child: TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    labelText: "OTP",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) {
                _animationController.reverse();
                if (!_showOtpField) {  // If OTP field is not visible, send OTP
                  String phoneNumber = '+91${_phoneController.text.trim()}';
                  if (phoneNumber.isNotEmpty) {
                    _sendOtp(phoneNumber);  // Send OTP
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid phone number')),
                    );
                  }
                } else {  // If OTP field is visible, verify OTP
                  _verifyOtp();  // Verify OTP
                }

                // _onSubmit();
              },
              child: ScaleTransition(
                scale: _buttonScale,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
