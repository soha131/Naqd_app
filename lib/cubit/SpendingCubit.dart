import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:naqd_app/SpendingService.dart';

class SpendingCubit extends Cubit<SpendingState> {
  SpendingCubit() : super(SpendingInitial());

/*
  Future<void> fetchTotalSpending() async {
    emit(SpendingLoading());

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('spendings')
          .get();

      double total = 0;
      List<Map<String, dynamic>> transactions = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final amount = double.tryParse(data['amount'].toString()) ?? 0.0;

        total += amount;

        transactions.add({
          'amount': '${amount.toStringAsFixed(2)} SAR',
          'name': data['name'] ?? '',
          'datetime': data['datetime'] ?? '',
          'icon': data['icon'] ?? '🛒',
        });
      }

      emit(SpendingLoaded(total: total, transactions: transactions));
    } catch (e) {
      emit(SpendingError(message: e.toString()));
    }
  }
*/


  Future<void> fetchTotalSpending() async {
    emit(SpendingLoading());

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('spendings')
          .get();

      double total = 0;
      List<Map<String, dynamic>> transactions = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        // Debugging logs to inspect the fetched data
        print('Transaction Data: $data');

        final amount = double.tryParse(data['amount'].toString()) ?? 0.0;
        final cardName = data['card'] ?? 'Unknown Card';  // Check if 'card' exists
        final timestamp = data['timestamp'] as Timestamp?;
        final icon = data['icon'] ?? '🍴'; // Default icon

        // If timestamp is not null, convert it to DateTime and format it
        final formattedDate = timestamp != null
            ? DateFormat('d MMM yyyy').format(timestamp.toDate()) // Formatting date as "2 Mar 2025"
            : 'Unknown Date';

        total += amount;

        transactions.add({
          'amount': '${amount.toStringAsFixed(2)} SAR',
          'card': cardName,
          'timestamp': formattedDate, // Display formatted date
          'icon': icon,
        });
      }

      emit(SpendingLoaded(total: total, transactions: transactions));
    } catch (e) {
      emit(SpendingError(message: e.toString()));
    }
  }

  void refreshSpending() {
    fetchTotalSpending();
  }
}

abstract class SpendingState {}

class SpendingInitial extends SpendingState {}

class SpendingLoading extends SpendingState {}

class SpendingLoaded extends SpendingState {
  final double total;
  final List<Map<String, dynamic>> transactions;

  SpendingLoaded({required this.total, required this.transactions});
}

class SpendingError extends SpendingState {
  final String message;
  SpendingError({required this.message});
}

