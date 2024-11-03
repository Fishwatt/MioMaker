import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'budget_state.dart';

enum FinancialType { income, expense, savings }

class FinancialTable extends StatelessWidget {
  final FinancialType type;

  const FinancialTable({super.key, required this.type});

  String get typeTitle {
    switch (type) {
      case FinancialType.income:
        return 'Income';
      case FinancialType.expense:
        return 'Expense';
      case FinancialType.savings:
        return 'Savings';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetState>(
      builder: (context, budgetState, child) {
        final columns = budgetState.getColumns(type);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => budgetState.addColumn(type),
                    child: Text("Add $typeTitle Category"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text(typeTitle)),
                        ...columns.asMap().entries.map((entry) {
                          final index = entry.key;
                          final col = entry.value;
                          return DataColumn(
                            label: GestureDetector(
                              onTap: () async {
                                final newName = await showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    final controller = TextEditingController(text: col.name);
                                    return AlertDialog(
                                      title: Text('Edit $typeTitle Name'),
                                      content: TextField(
                                        controller: controller,
                                        decoration: const InputDecoration(
                                          hintText: 'Enter name',
                                        ),
                                        autofocus: true,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(controller.text),
                                          child: const Text('Save'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (newName != null && newName.isNotEmpty) {
                                  budgetState.updateColumnName(type, index, newName);
                                }
                              },
                              onLongPress: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Delete Column'),
                                      content: Text('Are you sure you want to delete "${col.name}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            budgetState.deleteColumn(type, index);
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text(
                                col.name,
                                style: const TextStyle(
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }),
                        const DataColumn(label: Text("Monthly Total")),
                      ],
                      rows: [
                        ...List.generate(12, (index) {
                          final monthName = _getMonthName(index);
                          return DataRow(
                            cells: [
                              DataCell(Text(monthName)),
                              ...columns.map((col) => DataCell(
                                    TextField(
                                      controller: col.controllers[index],
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      decoration: const InputDecoration(
                                        hintText: "0.00",
                                      ),
                                      onChanged: (_) => budgetState.notifyListeners(),
                                    ),
                                  )),
                              DataCell(
                                Text(
                                  budgetState.getMonthlyTotal(type, index).toStringAsFixed(2),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          );
                        }),
                        DataRow(
                          cells: [
                            const DataCell(Text(
                              "Yearly Total",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            ...columns.map((col) => DataCell(
                                  Text(
                                    budgetState.getYearlyTotalForColumn(type, col).toStringAsFixed(2),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                )),
                            DataCell(
                              Text(
                                budgetState.getGrandTotal(type).toStringAsFixed(2),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMonthName(int index) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[index];
  }
}
