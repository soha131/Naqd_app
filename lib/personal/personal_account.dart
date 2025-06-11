import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naqd_app/auth/login_in.dart';
import 'package:path_provider/path_provider.dart';
import '../coorporate/coorporate_main.dart';
import 'package:path/path.dart' as path;

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  bool isUploading = false;
  double uploadProgress = 0.0;

  final nameController = TextEditingController();
  final currencyController = TextEditingController();
  final salaryController = TextEditingController();
  final salaryDateController = TextEditingController();
  final spendingLimitController = TextEditingController();

  String selectedCompany = 'Al-Yamamah University';
  final companyOptions = [
    'Al-Yamamah University',
    'King Saud University',
    'STC',
    'Mobily',
  ];

  File? _pickedImage;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    nameController.text = FirebaseAuth.instance.currentUser?.displayName ?? 'Guest';
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          nameController.text = data?['name'] ?? '';
          currencyController.text = data?['currency'] ?? '';
          salaryController.text = data?['salary'] ?? '';
          salaryDateController.text = data?['salaryDate'] ?? '';
          spendingLimitController.text = data?['spendingLimit'] ?? '';
          selectedCompany = data?['company'] ?? selectedCompany;

          // Handle profile image - check if it's a valid local path or URL
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

          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name': nameController.text.trim(),
            'currency': currencyController.text.trim(),
            'company': selectedCompany,
            'salary': salaryController.text.trim(),
            'salaryDate': salaryDateController.text.trim(),
            'spendingLimit': spendingLimitController.text.trim(),
            'email': user.email,
            'uid': user.uid,
            'profileImage': imagePath, // Local file path stored here
          }, SetOptions(merge: true));

          print('Stored local image path: $imagePath');
          await fetchUserData();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully!")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save data.")),
        );
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
    } catch (_) {
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
              if (isUploading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: LinearProgressIndicator(
                    value: uploadProgress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9B4DFF)),
                  ),
                ),
              _buildTextFormField('Your Name', nameController, hintText: 'Random Name'),
              _buildTextFormField('Account Currency', currencyController, hintText: 'SAR'),
              _buildDropdownField('Company (Optional only for Coorporate Account)'),
              _buildTextFormField('Monthly Salary', salaryController, hintText: '5000 SAR'),
              _buildTextFormField('Salary Date', salaryDateController, hintText: '1st of the Month'),
              _buildTextFormField('Spending Limit Warning', spendingLimitController, hintText: '2000 SAR'),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _handleCorporateRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B4DFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Center(
                  child: Text(
                    'Change to Coorporate',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => deleteUserAccount(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0000),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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

  Future<void> _handleCorporateRequest() async {
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
  }

  Widget _buildTextFormField(String label, TextEditingController controller, {String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF1C1C1E),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
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
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
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
            decoration: const InputDecoration(border: InputBorder.none),
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
