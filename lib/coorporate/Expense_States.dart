import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/CoorporateCubit.dart';
import 'coorporate_main.dart';

class ExpenseStatesCoorporateScreen extends StatefulWidget {
  const ExpenseStatesCoorporateScreen({super.key});

  @override
  State<ExpenseStatesCoorporateScreen> createState() => _ExpenseStatesCoorporateScreenState();
}

class _ExpenseStatesCoorporateScreenState extends State<ExpenseStatesCoorporateScreen> {

  Color getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.yellow;
      case 'rejected':
        return Colors.red;
      case 'info':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  Widget buildLegendDot(Color color, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        SizedBox(width: 10),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 20)),
        SizedBox(width: 12),
      ],
    );
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CoorporateMainScreen(),
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: BlocProvider(
            create: (_) => Coorporatecubit()..fetchTransactions(),
            child: BlocBuilder<Coorporatecubit, CoorporateState>(
              builder: (context, state) {
                if (state is CoorporateLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (state is CoorporateError) {
                  return Center(child: Text('Error: ${state.message}'));
                }

                List<Map<String, dynamic>> transactions = [];
                double total = 0;

                // Depending on the state, load the transactions
                if (state is CoorporateLoadedAll) {
                  transactions = state.transactions;
                  total = state.total;
                } else if (state is CoorporateLoadedApproved) {
                  transactions = state.transactions;
                  total = state.total;
                }

                return Column(
                  children: [
                    // Status Legend
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          children: [
                            buildLegendDot(Colors.red, 'Rejected'),
                            buildLegendDot(Colors.brown, 'Needs More Info'),
                            buildLegendDot(Colors.green, 'Approved'),
                            buildLegendDot(Colors.yellow, 'Pending'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    // Transaction List
                    Expanded(
                      child: ListView.separated(
                        itemCount: transactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 5),
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          final amount = '${transaction['amount'] ?? '0.00'}';
                          final cardName = transaction['card'] ?? 'Unknown Card';
                          final icon = transaction['icon'] ?? '🍴';
                          final dateTime = transaction['timestamp'] ?? 'Unknown Date';
                          final String rawStatus = transaction['status'] ?? '';
                          final String status = rawStatus.toLowerCase().trim();
                          final Color statusColor = getStatusColor(status);
                          print('Status for item $index: $status');
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF1C1C1E), // Apply color based on status
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Text(
                                  icon,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                title: Text(
                                  cardName,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                subtitle: Text(
                                  dateTime,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,

                                  children: [
                                    Text(
                                      amount,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    if (status.isNotEmpty)
                                      CircleAvatar(
                                        radius: 15,
                                        backgroundColor: statusColor,
                                      ),
                                  ],
                                ),

                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
