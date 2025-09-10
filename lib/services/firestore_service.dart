import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart'; // Adjust the import path if needed

class FirestoreService {
  // Get a reference to the 'expenses' collection in Firestore
  final CollectionReference _expensesCollection =
      FirebaseFirestore.instance.collection('expenses');

  // Create
  Future<void> addExpense(Expense expense) {
    // Adds a new document to the 'expenses' collection
    return _expensesCollection.add(expense.toJson());
  }

  // Read
  // Get a stream of expenses to display in real-time
  Stream<List<Expense>> getExpensesStream() {
    return _expensesCollection
        .orderBy('date', descending: true) // Order expenses by date, newest first
        .snapshots() // This returns a Stream
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Convert each document into an Expense object
        return Expense.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>);
      }).toList();
    });
  }

  // Update 
  Future<void> updateExpense(Expense expense) {
    return _expensesCollection.doc(expense.id).update(expense.toJson());
  }

  // Delete
  Future<void> deleteExpense(String expenseId) {
    return _expensesCollection.doc(expenseId).delete();
  }
}