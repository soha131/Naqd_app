import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naqd_app/auth/login_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../personal/personal_main.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController(text: 'Random Name');
  final TextEditingController currencyController = TextEditingController(text: 'Sar');
  final TextEditingController salaryController = TextEditingController(text: '5000 Sar');
  final TextEditingController salaryDateController = TextEditingController(text: '1st Of The Month');
  final TextEditingController spendingLimitController = TextEditingController(text: '3000Sar');

  String selectedCompany = 'Al-Yamamah University';
  final List<String> companyOptions = [
    'Al-Yamamah University',
    'King Saud University',
    'STC',
    'Mobily'
  ];

  @override
  void initState() {
    super.initState();
    nameController.text = FirebaseAuth.instance.currentUser?.displayName ?? ' Guest';
    fetchCorporateData();
  }
  File? _pickedImage;
  String? profileImageUrl;

  Future<void> fetchCorporateData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('corporates').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          nameController.text = data?['name'] ?? '';
          currencyController.text = data?['currency'] ?? '';
          salaryController.text = data?['salary'] ?? '';
          salaryDateController.text = data?['salaryDate'] ?? '';
          spendingLimitController.text = data?['spendingLimit'] ?? '';
          selectedCompany = data?['company'] ?? selectedCompany;
          if (data?['profileImage'] != null) {
            String profileImage = data!['profileImage'];

            // Check if it's a URL
            if (profileImage.startsWith('http')) {
              profileImageUrl = "${profileImage}?v=${DateTime.now().millisecondsSinceEpoch}";
            } else {
              // If it's a local path, update the local image
              _pickedImage = File(profileImage);
              profileImageUrl = null; // Do not show URL, show local image instead
            }
          } else {
            profileImageUrl = null;
          }
        });
      }
    }
  }

  Future<void> saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final imagePath = profileImageUrl; // Just the local path
          await FirebaseFirestore.instance.collection('corporates').doc(user.uid).set({
            'name': nameController.text.trim(),
            'currency': currencyController.text.trim(),
            'company': selectedCompany,
            'salary': salaryController.text.trim(),
            'salaryDate': salaryDateController.text.trim(),
            'spendingLimit': spendingLimitController.text.trim(),
            'email': user.email,
            'uid': user.uid,
            'profileImage': imagePath,
          }, SetOptions(merge: true));

          setState(() {
            nameController.text = nameController.text.trim();
            currencyController.text = currencyController.text.trim();
            salaryController.text = salaryController.text.trim();
            salaryDateController.text = salaryDateController.text.trim();
            spendingLimitController.text = spendingLimitController.text.trim();
          });
          fetchCorporateData();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated successfully!")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save data.")));
      }
    }
  }

  Future<void> deleteUserAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete();
        await FirebaseAuth.instance.signOut();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginOptionsScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deleted successfully.")),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please re-authenticate before deleting your account."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.message}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unexpected error occurred.")),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(pickedFile.path);
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

      setState(() {
        _pickedImage = savedImage;
      });

      print('Saved image path: ${savedImage.path}');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    currencyController.dispose();
    salaryController.dispose();
    salaryDateController.dispose();
    spendingLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account Settings',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.white),
            onPressed: saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipOval(
                      child: _pickedImage != null
                          ? Image.file(_pickedImage!, width: 110, height: 110, fit: BoxFit.cover)
                          : Image.asset('assets/profile.jpg', width: 110, height: 110, fit: BoxFit.cover),
                    ),


                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Color(0xFF9B4DFF)),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildTextFormField('Your Name', nameController, hintText: 'Random Name'),
              _buildTextFormField('Account Currency', currencyController, hintText: 'SAR'),
              _buildDropdownField('Company (Optional only for Coorporate Account)'),
              _buildTextFormField('Monthly Salary', salaryController, hintText: '5000 Sar'),
              _buildTextFormField('Salary Date', salaryDateController, hintText: '1st of the Month'),
              _buildTextFormField('Spending Limit Warning', spendingLimitController, hintText: '2000 Sar'),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PersonalMainScreen(),
                    ),
                  );
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Welcome, Personal User!'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9B4DFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Center(
                  child: Text(
                    'Change to Personal',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => deleteUserAccount(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF0000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Center(
                  child: Text(
                    'Delete my account',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, TextEditingController controller, {String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1C1C1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(25),
          ),
          child: DropdownButtonFormField<String>(
            dropdownColor: const Color(0xFF1C1C1E),
            value: selectedCompany,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            items: companyOptions.map((String company) {
              return DropdownMenuItem<String>(
                value: company,
                child: Text(company),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedCompany = newValue!;
              });
            },
          ),
        ),
      ],
    );
  }
}
