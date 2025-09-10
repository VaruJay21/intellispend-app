import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';
import 'add_expense_screen.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;
  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    void _deleteExpense() {
      // Show a confirmation dialog before deleting
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Expense'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                firestoreService.deleteExpense(expense.id!);
                // Pop twice to go back to the home screen
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close detail screen
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        backgroundColor: Colors.teal,
        actions: [
          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // We pass the existing expense to the AddExpenseScreen
                  builder: (context) => AddExpenseScreen(expense: expense),
                ),
              );
            },
          ),
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteExpense,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expense.description,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Amount: ₹${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${expense.category}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              // Simple date formatting
              'Date: ${expense.date.day}/${expense.date.month}/${expense.date.year}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            if (expense.isRecurring)
              const Row(
                children: [
                  Icon(Icons.autorenew, color: Colors.teal),
                  SizedBox(width: 8),
                  Text(
                    'This is a recurring expense',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}