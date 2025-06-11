import 'package:flutter/material.dart';
import 'welcome.dart';
import '../widget/background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    });
  }

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
          Center(
            child: Image.asset(
              "assets/Group 4568.png",
              width: 150,
              height: 150,
            ),
          ),
          Positioned(
            bottom: -350,
            left: -50,
            right: -80,
            child: SizedBox(
              height: size.height * 0.9,
              width: double.infinity,
              child: Image.asset("assets/vector1.png", width: 180, height: 180),
            ),
          ),
          Positioned(
            bottom: -400,
            left: -50,
            right: -80,
            child: SizedBox(
              height: size.height * 0.9,
              width: double.infinity,
              child: Image.asset(
                "assets/Vector (2).png",
                width: 180,
                height: 180,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
