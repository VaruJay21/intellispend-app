import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';
import '../data/suggestion_keywords.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;
  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Food';
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  List<String> _suggestions = [];
  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    // If we are editing, pre-fill the form fields with existing data
    if (_isEditing) {
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toString();
      _category = widget.expense!.category;
      _selectedDate = widget.expense!.date;
      _isRecurring = widget.expense!.isRecurring;
    }
    _descriptionController.addListener(_updateSuggestions);
  }

  void _updateSuggestions() {
    final query = _descriptionController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    final Set<String> matchedCategories = {};
    keywordMap.forEach((category, keywords) {
      if (keywords.any((keyword) => query.contains(keyword))) {
        matchedCategories.add(category);
      }
    });

    setState(() {
      _suggestions = matchedCategories.toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final expenseData = Expense(
        id: _isEditing ? widget.expense!.id : null,
        description: _descriptionController.text,
        amount: double.tryParse(_amountController.text) ?? 0.0,
        category: _category,
        date: _selectedDate,
        isRecurring: _isRecurring,
      );

      if (_isEditing) {
        _firestoreService.updateExpense(expenseData).then((_) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        });
      } else {
        _firestoreService.addExpense(expenseData).then((_) {
          Navigator.pop(context);
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_updateSuggestions);
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _amountController,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  labelText: 'Amount',
                  labelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter an amount' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 12),
              if (_suggestions.isNotEmpty)
                Wrap(
                  spacing: 8.0,
                  children: _suggestions.map((suggestion) {
                    return ActionChip(
                      label: Text(suggestion),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                      onPressed: () => setState(() => _category = suggestion),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
              // ... rest of the form ...
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ['Food', 'Transport', 'Shopping', 'Bills', 'Entertainment', 'Health', 'Other']
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _category = value);
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('MMM d, yyyy').format(_selectedDate),
                ),
                decoration: InputDecoration(
                  labelText: 'Date',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Mark as recurring?'),
                value: _isRecurring,
                onChanged: (bool value) => setState(() => _isRecurring = value),
                activeColor: Theme.of(context).colorScheme.primary,
                tileColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: Text(_isEditing ? 'Update Expense' : 'Save Expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
