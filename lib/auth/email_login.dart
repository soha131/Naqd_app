import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:naqd_app/auth/login_in.dart';
import 'package:naqd_app/auth/signup.dart';
import 'package:naqd_app/splash/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US');
  String? verificationId;

  Future<void> signInWithEmailPassword() async {
    try {
      final email = _emailController.text;
      final password = _passwordController.text;

      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserStateScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'too-many-requests':
          message = 'Too many failed login attempts. Please try again later.';
          break;
        default:
          message = 'Authentication error: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Phone Number Login Function
  Future<void> signInWithPhoneNumber() async {
    try {
      String phoneNumber = _phoneNumber.phoneNumber!;

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserStateScreen()),
          );
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Phone number verification failed: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            this.verificationId = verificationId;
          });
          showDialog(
            context: context,
            builder: (context) => OTPDialog(verificationId: verificationId),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("OTP auto-retrieval timeout: $verificationId");
        },
      );
    } catch (e) {
      print("Phone login error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginOptionsScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Login",
                      style: TextStyle(
                        fontSize: size.width * 0.08,
                        color: Color(0xFF9E27BC),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don’t have an account?",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Sign up",
                            style: TextStyle(
                              color: Color(0xFF9E27BC),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                    ElevatedButton(
                      onPressed: signInWithEmailPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF9B4DFF),
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.02,
                          horizontal: 70,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),

                      child: Text(
                        "Login with Email",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 60),

                    InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) {
                        setState(() {
                          _phoneNumber = number;
                        });
                      },
                      initialValue: _phoneNumber,
                      selectorConfig: SelectorConfig(
                        selectorType: PhoneInputSelectorType.DIALOG,
                        setSelectorButtonAsPrefixIcon: true,
                        showFlags: true,
                      ),
                      textStyle: TextStyle(color: Colors.white, fontSize: 16),
                      inputDecoration: InputDecoration(
                        labelText: 'Phone Number',
                        contentPadding: EdgeInsets.symmetric(horizontal: 20),
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: Color(0xFF9B4DFF),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        prefixIcon: Icon(Icons.phone, color: Colors.white),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 30,
                          minHeight: 30,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                    ElevatedButton(
                      onPressed: signInWithPhoneNumber,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF9B4DFF),
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.02,
                          horizontal: 40,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Login with Phone Number",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OTPDialog extends StatefulWidget {
  final String verificationId;
  OTPDialog({required this.verificationId});

  @override
  _OTPDialogState createState() => _OTPDialogState();
}

class _OTPDialogState extends State<OTPDialog> {
  final otpController = TextEditingController();

  Future<void> verifyOTP() async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otpController.text,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      print('Signed in: ${user?.phoneNumber}');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserStateScreen()),
      );
    } catch (e) {
      print("OTP verification error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        "Enter OTP",
        style: TextStyle(
          fontSize: 24,
          color: Color(0xFF9E27BC),
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: TextField(
        controller: otpController,
        decoration: InputDecoration(labelText: 'OTP'),
      ),
      actions: [
        TextButton(
          onPressed: verifyOTP,
          child: Text(
            "Verify",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF9563A3),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
