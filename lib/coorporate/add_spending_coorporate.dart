import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:naqd_app/coorporate/Cspending_add.dart';
import 'package:naqd_app/cubit/CoorporateCubit.dart';
import '../personal/spending_add.dart';

class AddSpendingCoorporateScreen extends StatefulWidget {
  final double amount;
  final String imagePath;

  const AddSpendingCoorporateScreen({
    super.key,
    required this.amount,
    required this.imagePath,
  });

  @override
  State<AddSpendingCoorporateScreen> createState() => _AddSpendingCoorporateScreenState();
}

class _AddSpendingCoorporateScreenState extends State<AddSpendingCoorporateScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController cardController = TextEditingController();
  String selectedIcon = "🍴";
  final List<String> icons = [
    "🍴", "🛒", "🎁", "🎓", "⛽", "💊", "🛍️", "🏥", "🏨", "🏦", "🏫", "🎮", "✈️"
  ];

  @override
  void initState() {
    super.initState();
    amountController.text = widget.amount.toString();
  }

  void handleCorporateSpendingRequest() async {
    if (amountController.text.isEmpty || double.tryParse(amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please enter a valid amount")));
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("User not logged in");
        return;
      }

      String? imagePathToStore;
      if (widget.imagePath.isNotEmpty) {
        imagePathToStore = widget.imagePath;
      }

      Map<String, dynamic> requestData = {
        'userId': user.uid,
        'amount': double.tryParse(amountController.text) ?? 0.0,
        'type': typeController.text,
        'date': dateController.text,
        'card': cardController.text,
        'icon': selectedIcon,
        'imagePath': imagePathToStore,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('corporateRequests')
          .add(requestData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Request sent for approval")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AddScreen()),
      );
    } catch (e) {
      print("Error submitting request: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit request")),
      );
    }
  }

  void selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
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
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.01,
                      ),
                      backgroundColor: const Color(0xFF9B4DFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: handleCorporateSpendingRequest,
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
