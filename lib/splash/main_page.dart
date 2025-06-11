import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:naqd_app/coorporate/coorporate_main.dart';
import '../personal/personal_main.dart';

class UserStateScreen extends StatelessWidget {
  const UserStateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? "User";
    final photoUrl = user?.photoURL;
    return Scaffold(
      backgroundColor: Color(0xFF131313),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const Spacer(flex: 5),
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  photoUrl != null
                      ? NetworkImage(photoUrl)
                      : AssetImage('assets/profile.jpg') as ImageProvider,
            ),
            // Headline
            Text(
              "Welcome",
              style: TextStyle(
                fontSize: size.width * 0.08,
                color: Color(0xFF9E27BC),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              displayName,
              style: TextStyle(
                fontSize: size.width * 0.05,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(flex: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => PersonalMainScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_circle_outlined,
                          color: Color(0xFF9E27BC),
                        ),
                        SizedBox(width: 15),
                        Text(
                          "Personal",
                          style: TextStyle(
                            color: Color(0xFF9E27BC),
                            fontSize: size.width * 0.035,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: ()async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          scaffoldMessenger.showSnackBar(const SnackBar(content: Text('User not logged in')));
                          return;
                        }

                        final doc = await FirebaseFirestore.instance.collection('joinRequests').doc(user.uid).get();

                        if (doc.exists && doc['status'] == 'approved') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CoorporateMainScreen()));
                          scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Welcome, Corporate User!')));
                        } else if (!doc.exists) {
                          await FirebaseFirestore.instance.collection('joinRequests').doc(user.uid).set({
                            'userId': user.uid,
                            'email': user.email,
                            'timestamp': FieldValue.serverTimestamp(),
                            'status': 'pending',
                          });
                          scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Request sent. Waiting for approval.')));
                        } else {
                          scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Request is pending approval.')));
                        }
                      } catch (e) {
                        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9648FE),
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, color: Colors.white),
                        SizedBox(width: 15),
                        Text(
                          "Corporate",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.035,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
