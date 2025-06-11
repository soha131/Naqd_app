import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naqd_app/coorporate/Expense_States.dart';
import 'package:naqd_app/coorporate/add_spending_coorporate.dart';
import 'package:naqd_app/coorporate/coorporate_account.dart';
import 'package:naqd_app/cubit/CoorporateCubit.dart';
import 'package:naqd_app/cubit/ocr_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoorporateMainScreen extends StatefulWidget {
  const CoorporateMainScreen({super.key});

  @override
  State<CoorporateMainScreen> createState() => _CoorporateMainScreenState();
}

class _CoorporateMainScreenState extends State<CoorporateMainScreen> {
  double? extractAmount;
  Stream<DocumentSnapshot> getUserStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance.collection('corporates').doc(user.uid).snapshots();
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
            create: (_) => Coorporatecubit()..fetchTransactions(approvedOnly: true),
            child: BlocConsumer<Coorporatecubit, CoorporateState>(
              listener: (context, state) {
                if (state is CoorporateError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${state.message}')),
                  );
                }
              },
              builder: (context, state) {
                if (state is CoorporateLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CoorporateLoadedAll) {
                  return _buildContent(
                    context,
                    state.total,
                    state.transactions,
                  );
                } else if (state is CoorporateLoadedApproved) {
                  return _buildContent(
                    context,
                    state.total,
                    state.transactions,
                  );
                } else if (state is CoorporateError) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else {
                  return const Center(
                    child: Text('No data available', style: TextStyle(color: Colors.white)),
                  );
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
        _buildHeader(),
        const SizedBox(height: 100),
        _buildActionButtons(),
        const SizedBox(height: 30),
        Expanded(
          child: _buildTransactionList(transactions: transactions),
        ),
      ],
    );
  }

  Widget _buildHeader() {

    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? "User";
    final photoUrl = user?.photoURL;


    return Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountScreen()),
                );
              },
              child: CircleAvatar(
                radius: 28,
                backgroundImage: photoUrl != null
                    ? NetworkImage(photoUrl)
                    : const AssetImage('assets/profile.jpg') as ImageProvider,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome', style: TextStyle(color: Color(0xFF9E27BC))),
                Text(displayName, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ],
        );

  }

  Widget _buildActionButtons() {
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
                  Navigator.pop(context, await _picker.pickImage(source: ImageSource.camera));
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
                onPressed: () async {
                  Navigator.pop(context, await _picker.pickImage(source: ImageSource.gallery));
                },
              ),
            ],
          );
        },
      );

      if (pickedFile != null) {
        File file = File(pickedFile.path);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
        try{
          double amount = await context.read<AmountPredictionCubit>().total(file, context);

          if (amount >= 0) {
            setState(() {
              extractAmount = amount;
            });

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('image_path', file.path);
            context.read<Coorporatecubit>().refresh();

            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Amount Detected'),
                  content: Text('Amount detected: ${extractAmount.toString()} SAR'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: context.read<Coorporatecubit>(),
                              child: AddSpendingCoorporateScreen(
                                amount: extractAmount!,
                                imagePath: file.path,
                              ),
                            ),
                          ),
                        );
                      },
                      child: const Text('Go to Add Spending'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        }
        catch (e) {
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
                MaterialPageRoute(builder: (_) => ExpenseStatesCoorporateScreen()),
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
            icon: const Icon(Icons.library_add_check),
            label: const Text('Expense States'),
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
      return const Center(
        child: Text(
          'No transactions available.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 5),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final amount = '${transaction['amount'] ?? '0.00'}';
        final cardName = transaction['card'] ?? 'Unknown Card';
        final icon = transaction['icon'] ?? '🍴';
        final dateTime = transaction['timestamp'] ?? 'Unknown Date';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade900,
            child: Text(
              icon,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(
            cardName,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            dateTime,
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
