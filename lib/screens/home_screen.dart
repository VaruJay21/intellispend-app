import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';
import 'add_expense_screen.dart';
import 'expense_detail_screen.dart';

IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Food':
      return Icons.fastfood_rounded;
    case 'Transport':
      return Icons.directions_car_rounded;
    case 'Shopping':
      return Icons.shopping_bag_rounded;
    case 'Bills':
      return Icons.receipt_long_rounded;
    case 'Entertainment':
      return Icons.movie_rounded;
    case 'Health':
      return Icons.local_hospital_rounded;
    default:
      return Icons.category_rounded;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IntelliSpend'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _firestoreService.getExpensesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No expenses yet. Add one!'));
          }

          List<Expense> expenses = snapshot.data!;

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              Expense expense = expenses[index];
              return Card(
                color: Theme.of(context).colorScheme.surface,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.background,
                    child: Icon(
                      getCategoryIcon(expense.category),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    expense.description,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    DateFormat('MMM d, yyyy').format(expense.date),
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${expense.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (expense.isRecurring)
                        Icon(Icons.autorenew, size: 14, color: Colors.white.withOpacity(0.5)),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpenseDetailScreen(expense: expense),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}