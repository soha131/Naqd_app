import 'package:flutter/material.dart';
import 'package:naqd_app/personal/personal_main.dart';

class SpendingAddScreen extends StatelessWidget {
  const SpendingAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: Column(
        children: [
          const Spacer(flex: 7),
          Text(
            "Spending Added",
            style: TextStyle(
              fontSize: size.width * 0.08,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PersonalMainScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9648FE),
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.02,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(double.infinity, 0),
              ),
              child: Text(
                "Homepage",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.035,
                ),
              ),
            ),
          ),
          const Spacer(flex: 7),
        ],
      ),
    );
  }
}
