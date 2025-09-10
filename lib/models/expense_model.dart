import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String? id;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final bool isRecurring;

  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    this.isRecurring = false,
  });

  // Convert an Expense object into a Map (JSON format) for Firestore
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date), // Firestore uses a special Timestamp object for dates
      'isRecurring': isRecurring,
    };
  }

  // Create an Expense object from a Firestore document snapshot
  factory Expense.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return Expense(
      id: document.id,
      description: data['description'],
      amount: (data['amount'] as num).toDouble(),
      category: data['category'],
      date: (data['date'] as Timestamp).toDate(), // Convert Timestamp back to DateTime
      isRecurring: data['isRecurring'] ?? false,
    );
  }
}