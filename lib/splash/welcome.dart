import 'package:flutter/material.dart';
import 'package:naqd_app/auth/login_in.dart';
import '../widget/background.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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

          Align(
            alignment: Alignment.center,
            child: Text(
              "Naqd: Smarter\n Tracking, Better\n Living.",
              style: TextStyle(
                fontSize: size.width * 0.09,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LoginOptionsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9648FE),
                  padding: EdgeInsets.symmetric(
                    vertical: size.height * 0.01,
                    horizontal: size.width * 0.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Start Smart",
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
