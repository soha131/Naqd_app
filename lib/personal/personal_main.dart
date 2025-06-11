import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naqd_app/auth/login_in.dart';
import 'package:naqd_app/cubit/SpendingCubit.dart';
import 'package:naqd_app/cubit/ocr_cubit.dart';
import 'package:naqd_app/personal/personal_account.dart';
import 'package:naqd_app/personal/personal_trend.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_spending_personal.dart';

class PersonalMainScreen extends StatefulWidget {
  const PersonalMainScreen({super.key});

  @override
  _PersonalMainScreenState createState() => _PersonalMainScreenState();
}

class _PersonalMainScreenState extends State<PersonalMainScreen> {
  double? extractedAmount;
  Stream<DocumentSnapshot> getUserStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots();
    }
    return Stream.empty(); // In case user is not logged in
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: BlocProvider(
            create: (_) => SpendingCubit()..fetchTotalSpending(),
            child: BlocConsumer<SpendingCubit, SpendingState>(
              listener: (context, state) {
                if (state is SpendingError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${state.message}')),
                  );
                }
              },
              builder: (context, state) {
                if (state is SpendingLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SpendingLoaded) {
                  return _buildContent(context, state.total,state.transactions);
                } else if (state is SpendingError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return const Center(child: Text('No data available'));
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, double totalSpending, List<Map<String, dynamic>> transactions) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              const Text(
                'Your Spending:',
                style: TextStyle(color: Colors.white70, fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                '${totalSpending.toStringAsFixed(2)} Sar',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildActionButtons(context),
        const SizedBox(height: 20),
        const Text('Transaction', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 10),
        Expanded(child: _buildTransactionList(transactions: transactions)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? "User";
    final photoUrl = user?.photoURL;
    Future<void> logoutUser() async {
      try {
        final googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }

        await FirebaseAuth.instance.signOut();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginOptionsScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
      }
    }
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AccountSettingsPage()),
            );
          },
          child: CircleAvatar(
            radius: 28,
            backgroundImage: photoUrl!.startsWith('http')
                ? NetworkImage(photoUrl)
                : AssetImage(photoUrl) as ImageProvider,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome', style: TextStyle(color: const Color(0xFF9E27BC))),
            Text(displayName, style: TextStyle(color: Colors.white)),
          ],
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: logoutUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0x33FF0000),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('Logout', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }


  _buildActionButtons(BuildContext context) {
    final ImagePicker _picker = ImagePicker();

    Future<void> pickImageAndExtractAmount() async {
      final XFile? pickedFile = await showDialog<XFile>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Select Image Source'),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
                onPressed: () async {
                  Navigator.pop(
                    context,
                    await _picker.pickImage(source: ImageSource.camera),
                  );
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                onPressed: () async {
                  Navigator.pop(
                    context,
                    await _picker.pickImage(source: ImageSource.gallery),
                  );
                },
              ),
            ],
          );
        },
      );

      if (pickedFile != null) {
        File file = File(pickedFile.path);

        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        try {
          double amount = await context.read<AmountPredictionCubit>().total(
            file,
            context,
          );

          Navigator.pop(context); // Close loading dialog

          if (amount >= 0) {
            setState(() {
              extractedAmount = amount;
            });
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('image_path', file.path);
            context.read<SpendingCubit>().refreshSpending();

            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Amount Detected'),
                  content: Text('Amount detected: ${extractedAmount.toString()} SAR'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: context.read<SpendingCubit>(),
                              child: AddSpendingPersonalScreen(
                                amount: extractedAmount!,
                                imagePath: file.path,
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text('Go to Add Spending'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                );
              },
            );
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Failed to detect the amount'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } catch (e) {
          Navigator.pop(context); // Close loading dialog in case of error
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('Something went wrong: $e'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SpendingTrendScreen()),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF9648FE),
              side: const BorderSide(color: Colors.white),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.trending_up),
            label: const Text('Spending Trend'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: pickImageAndExtractAmount,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF9648FE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Spending'),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList({required List<Map<String, dynamic>> transactions}) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No transactions available.'));
    }

    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white12),
      itemBuilder: (context, index) {
        final transaction = transactions[index];

        // Extracting values from the transaction map
        final amount = transaction['amount'] ?? '0.00 SAR';
        final cardName = transaction['card'] ?? 'Unknown Card';
        final dateTime = transaction['timestamp'] ?? 'Unknown Date';
        final icon = transaction['icon'] ?? '🍴';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade900,
            child: Text(
              icon, // Displaying the icon (emoji or character)
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            cardName,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            dateTime, // Displaying the formatted datetime
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: Text(
            amount,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }
}
