import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SpendingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> addSpending(double amount) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print("User not authenticated");
      return;
    }

    try {
      await _firestore.collection('spendings').add({
        'userId': userId,
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),  // Optional, for sorting
      });
      print('Spending added successfully');
    } catch (e) {
      print('Error adding spending: $e');
    }
  }
  Future<double> getTotalSpendingForUser() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Check if the user is authenticated
    if (userId == null) {
      print("User is not authenticated");
      return 0.0;  // Return 0 if no user is authenticated
    }

    try {
      // Query Firestore to get all spending data for the authenticated user
      final querySnapshot = await FirebaseFirestore.instance
          .collection('spendings')
          .where('userId', isEqualTo: userId)
          .get();

      print("Number of transactions: ${querySnapshot.docs.length}");  // Debugging line

      double total = 0.0;

      // Loop through the fetched documents and sum up the amounts
      for (var doc in querySnapshot.docs) {
        print("Document data: ${doc.data()}");  // Print document data for debugging

        // Ensure the document contains the necessary fields
        if (doc.data().containsKey('userId') && doc.data().containsKey('amount')) {
          final amount = doc['amount'];

          // Ensure amount is a valid number (either double or string that can be converted)
          if (amount is String) {
            // Try to parse the string to a double
            final parsedAmount = double.tryParse(amount);
            if (parsedAmount != null) {
              total += parsedAmount;
            } else {
              print("Error: Invalid amount value in document (unable to parse string): $amount");
            }
          } else if (amount is double) {
            total += amount;
          } else {
            print("Error: Unexpected amount type in document: ${amount.runtimeType}");
          }
        } else {
          print("Error: Missing userId or amount in document");
        }
      }

      return total;

    } catch (e) {
      // Catch any error that might occur during the Firestore operation
      print("Error fetching total spending: $e");
      return 0.0;  // Return 0 if an error occurred
    }
  }
  Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      // Reference to the transactions collection
      final transactionRef = FirebaseFirestore.instance.collection('transactions');

      // Fetch the documents in the collection
      QuerySnapshot querySnapshot = await transactionRef.get();

      // Transform the documents into a list of maps
      List<Map<String, dynamic>> transactions = querySnapshot.docs.map((doc) {
        return {
          'name': doc['name'],
          'datetime': doc['datetime'],
          'amount': doc['amount'].toString(),
          'icon': doc['icon'], // Assuming there's an icon field in the Firestore document
        };
      }).toList();

      return transactions;
    } catch (e) {
      // Handle error, for example logging the error or returning an empty list
      print('Error fetching transactions: $e');
      return [];
    }
  }
}
