import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:naqd_app/auth/email_login.dart';
import '../splash/main_page.dart';
import '../widget/background.dart';

class LoginOptionsScreen extends StatelessWidget {
  const LoginOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF131313),

      body: Stack(
        children: [
          NaqdBackground(
            child: Positioned(
              top: -350,
              left: -80,
              right: -50,
              child: SizedBox(
                height: size.height * 0.9,
                width: double.infinity,
                child: Image.asset(
                  "assets/Vector.png",
                  width: 180,
                  height: 180,
                ),
              ),
            ),
          ),
          Positioned(
            top: -400,
            left: -80,
            right: -50,
            child: SizedBox(
              height: size.height * 0.9,
              width: double.infinity,
              child: Image.asset(
                "assets/Vector (1).png",
                width: 180,
                height: 180,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Center(
                  child: Image.asset(
                    "assets/Group 4568.png",
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.05),
              _socialButton("Continue with Google", Bootstrap.google, size,context),
             /* _socialButton("Continue with Facebook", Bootstrap.facebook, size,context),
              _socialButton("Continue with Apple", Bootstrap.apple, size,context),*/
              Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.02,horizontal: 20),
                child: Text("Or", style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                onPressed: () { Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) =>  LoginPage()),
                );},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9648FE),
                  padding: EdgeInsets.symmetric(
                    vertical: size.height * 0.02,
                    horizontal: size.width * 0.140,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Login with Email or Phone Number",
                  style: TextStyle(
                    fontSize: size.width * 0.035,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _socialButton(String text, IconData icon, Size size, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.1,
        vertical: size.height * 0.01,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(25),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(text, style: TextStyle(color: Colors.white)),
          onTap: () async {
            try {
              final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
              if (googleUser == null) return;

              final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

              final credential = GoogleAuthProvider.credential(
                accessToken: googleAuth.accessToken,
                idToken: googleAuth.idToken,
              );

              final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
              final user = userCredential.user;
              print('Signed in: ${user?.displayName}, ${user?.email}');

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const UserStateScreen()),
              );
            } catch (e) {
              print('Google sign-in error: $e');
            }
          },
        ),
      ),
    );
  }

}
