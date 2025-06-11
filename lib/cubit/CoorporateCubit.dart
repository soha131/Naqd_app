import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';



class Coorporatecubit extends Cubit<CoorporateState> {
  Coorporatecubit() : super(CoorporateInitial());

  // Fetch transactions with the option to filter by 'approved' status
  Future<void> fetchTransactions({bool approvedOnly = false}) async {
    emit(CoorporateLoading());

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('corporateRequests')
          .where('userId', isEqualTo: userId)
          .get();

      double total = 0;
      List<Map<String, dynamic>> transactions = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        // If fetching approved transactions only, filter by status
        if (approvedOnly && data['status'] != 'approved') continue;

        // For both all and approved transactions, process the data
        final amount = double.tryParse(data['amount'].toString()) ?? 0.0;
        final cardName = data['card'] ?? 'Unknown Card';
        final timestamp = data['timestamp'] as Timestamp?;
        final icon = data['icon'] ?? '🍴';
        final status = data['status'] ?? 'unknown';

        final formattedDate = timestamp != null
            ? DateFormat('d MMM yyyy').format(timestamp.toDate())
            : 'Unknown Date';

        total += amount;

        transactions.add({
          'amount': '${amount.toStringAsFixed(2)} SAR',
          'card': cardName,
          'timestamp': formattedDate,
          'icon': icon,
          'status': status,
        });
      }

      // Emit different states based on what was fetched
      if (approvedOnly) {
        emit(CoorporateLoadedApproved(total: total, transactions: transactions));
      } else {
        emit(CoorporateLoadedAll(total: total, transactions: transactions));
      }
    } catch (e) {
      emit(CoorporateError(message: e.toString()));
    }
  }

  void refresh() {
    fetchTransactions();
  }
}

abstract class CoorporateState {}

class CoorporateInitial extends CoorporateState {}

class CoorporateLoading extends CoorporateState {}

class CoorporateLoadedAll extends CoorporateState {
  final double total;
  final List<Map<String, dynamic>> transactions;

  CoorporateLoadedAll({required this.total, required this.transactions});
}

class CoorporateLoadedApproved extends CoorporateState {
  final double total;
  final List<Map<String, dynamic>> transactions;

  CoorporateLoadedApproved({required this.total, required this.transactions});
}

class CoorporateError extends CoorporateState {
  final String message;
  CoorporateError({required this.message});
}
