import 'package:financial_manager_appv5/allocation_iden.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_manager_appv5/budget_state.dart';
import 'package:financial_manager_appv5/financial_table.dart';

class TrackerPage extends StatelessWidget {
  const TrackerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(
            86), // Increased height to accommodate padding
        child: Column(
          children: [
            SizedBox(height: 40), // Added padding
            AllocationIdentifier(),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Consumer<BudgetState>(
              builder: (context, budgetState, child) {
                return ElevatedButton(
                  onPressed: () {
                    budgetState.addTransaction(
                      Transaction(
                        date: DateTime.now(),
                        amount: 0,
                      ),
                    );
                  },
                  child: const Text('Add Transaction'),
                );
              },
            ),
            const SizedBox(height: 16),
            const Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: TrackerTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TrackerTable extends StatelessWidget {
  const TrackerTable({super.key});

  // Helper method to determine text color based on transaction type
  Color _getAmountColor(FinancialType? type) {
    if (type == null) return Colors.black; // Default color
    switch (type) {
      case FinancialType.income:
        return Colors.green;
      case FinancialType.expense:
      case FinancialType.savings:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetState>(
      builder: (context, budgetState, child) {
        return DataTable(
          columns: const [
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Amount')),
            DataColumn(label: Text('Actions')),
          ],
          rows: [
            ...budgetState.transactions.map((transaction) {
              // Controller for the amount field
              final amountController = TextEditingController(
                text:
                    transaction.amount > 0 ? transaction.amount.toString() : '',
              );

              return DataRow(
                cells: [
                  // Date Cell
                  DataCell(
                    Text(
                      '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}',
                    ),
                    onTap: () async {
                      final newDate = await showDatePicker(
                        context: context,
                        initialDate: transaction.date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (newDate != null) {
                        transaction.date = newDate;
                        budgetState.updateTransaction(transaction);
                      }
                    },
                  ),
                  // Type Cell
                  DataCell(
                    Text(transaction.type?.name.capitalize() ?? 'Select Type'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                            title: const Text('Select Type'),
                            children: FinancialType.values.map((type) {
                              return SimpleDialogOption(
                                onPressed: () {
                                  transaction.type = type;
                                  // Reset category when type changes
                                  transaction.category = null;
                                  Navigator.pop(context);
                                  budgetState.updateTransaction(transaction);
                                },
                                child: Text(type.name.capitalize()),
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
                  ),
                  // Category Cell
                  DataCell(
                    Text(transaction.category ?? 'Select Category'),
                    onTap: () {
                      if (transaction.type != null) {
                        final categories =
                            budgetState.getCategoriesForType(transaction.type!);

                        if (categories.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return SimpleDialog(
                                title: const Text('Select Category'),
                                children: categories.map((category) {
                                  return SimpleDialogOption(
                                    onPressed: () {
                                      transaction.category = category;
                                      Navigator.pop(context);
                                      budgetState
                                          .updateTransaction(transaction);
                                    },
                                    child: Text(category),
                                  );
                                }).toList(),
                              );
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'No categories available for ${transaction.type!.name}. Please add categories in the budget table.',
                              ),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a type first'),
                          ),
                        );
                      }
                    },
                  ),
                  // Amount Cell with colored text based on type
                  DataCell(
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: TextStyle(
                        color: _getAmountColor(transaction.type),
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: _getAmountColor(transaction.type)
                              .withOpacity(0.5),
                        ),
                      ),
                      onChanged: (value) {
                        transaction.amount = double.tryParse(value) ?? 0;
                        budgetState.updateTransaction(transaction);
                      },
                    ),
                  ),
                  // Actions Cell
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Transaction'),
                              content: const Text(
                                  'Are you sure you want to delete this transaction?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    budgetState.removeTransaction(transaction);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ],
        );
      },
    );
  }
}
