import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naqd_app/cubit/SpendingCubit.dart';
import 'spending_add.dart';

class AddSpendingPersonalScreen extends StatefulWidget {
  final double amount;
  final String imagePath;

  const AddSpendingPersonalScreen({super.key, required this.amount, required this.imagePath});

  @override
  State<AddSpendingPersonalScreen> createState() => _AddSpendingPersonalScreenState();
}

class _AddSpendingPersonalScreenState extends State<AddSpendingPersonalScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController cardController = TextEditingController();
  String selectedIcon = "🍴";
  File? imageFile;
  final List<String> icons = [
    "🍴", "🛒", "🎁", "🎓", "⛽", "💊","🛍️","🏥","🏨,""🏦","🏫","🎮","✈️"
  ];

  @override
  void initState() {
    super.initState();
    amountController.text = widget.amount.toString();
  }
 /* void saveSpendingData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user is logged in");
        return;
      }

      Map<String, dynamic> spendingData = {
        'amount': double.tryParse(amountController.text) ?? 0.0,
        'type': typeController.text,
        'date': dateController.text,
        'card': cardController.text,
        'icon': selectedIcon,
        'imageUrl': imageFile != null ? await uploadImage(imageFile!) : null,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Correct Firestore path
      await FirebaseFirestore.instance
          .collection('users') // Correct path
          .doc(user.uid)
          .collection('spendings')
          .add(spendingData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Spending added successfully")));

      // Refresh the total spending and transactions
      context.read<SpendingCubit>().fetchTotalSpending();

      // Navigate back or reset the form
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SpendingAddScreen()),
      );    } catch (e) {
      print("Error adding spending: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error adding spending")));
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    // If you want to upload the image, implement it here using Firebase Storage
    // For now, returning null if no image is selected*

    return null;
  }*/

  void saveSpendingData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user is logged in");
        return;
      }
      String? imagePathToStore;
      if (widget.imagePath.isNotEmpty) {
        imagePathToStore = widget.imagePath;
      }
      Map<String, dynamic> spendingData = {
        'amount': double.tryParse(amountController.text) ?? 0.0,
        'type': typeController.text,
        'date': dateController.text,
        'card': cardController.text,
        'icon': selectedIcon,
        'imageUrl': imagePathToStore,
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Correct Firestore path
      await FirebaseFirestore.instance
          .collection('users') // Correct path
          .doc(user.uid)
          .collection('spendings')
          .add(spendingData);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Spending added successfully")));

      // Refresh the total spending and transactions
      context.read<SpendingCubit>().fetchTotalSpending();

      // Navigate back or reset the form
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SpendingAddScreen()),
      );
    } catch (e) {
      print("Error adding spending: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error adding spending")));
    }
  }

  Future<String?> uploadImage(File imageFile) async {
    try {
      // Generate a unique file name using the current timestamp
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a reference to Firebase Storage
      Reference storageReference = FirebaseStorage.instance.ref().child('spending_images/$fileName');

      // Upload the image to Firebase Storage
      UploadTask uploadTask = storageReference.putFile(imageFile);

      // Wait for the upload to complete and get the download URL
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL for the uploaded image
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;  // Return the URL to store in Firestore
    } catch (e) {
      print("Error uploading image: $e");
      return null;  // Return null if upload fails
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    typeController.dispose();
    dateController.dispose();
    cardController.dispose();
    super.dispose();
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildLabel("Total Amount"),
              _buildField(amountController, hintText: "Detecting..."),
              _buildLabel("Type of spending"),
              _buildField(typeController, hintText: "e.g. Food"),
              _buildLabel("Transaction Date"),
              _buildField(dateController, hintText: "Please enter manually"),
              _buildLabel("Card used"),
              _buildField(cardController, hintText: "Please enter manually"),
              _buildLabel("Choose Icon"),
              _buildDropdown(),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
                      backgroundColor: const Color(0xFF9B4DFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      saveSpendingData();
                    },
                    child: const Text(
                      "Add Spending",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, {String? hintText}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(25),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedIcon,
        isExpanded: true,
        dropdownColor: const Color(0xFF1E1E1E),
        iconEnabledColor: Colors.white,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        decoration: const InputDecoration(border: InputBorder.none),
        items: icons.map((icon) {
          return DropdownMenuItem(
            value: icon,
            child: Center(child: Text(icon)),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              selectedIcon = value;
            });
          }
        },
        menuMaxHeight: 250,
      ),
    );
  }
}
