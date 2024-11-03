import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_manager_appv5/budget_state.dart';
import 'package:financial_manager_appv5/financial_table.dart';

class AllocationIdentifier extends StatelessWidget {
  const AllocationIdentifier({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetState>(
      builder: (context, budgetState, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 40,
            dataRowHeight: 40,
            columns: _buildMonthColumns(),
            rows: [
              DataRow(
                cells: List.generate(12, (index) {
                  // Calculate the allocation difference for each month
                  double income = budgetState.getMonthlyTotal(FinancialType.income, index);
                  double expenses = budgetState.getMonthlyTotal(FinancialType.expense, index);
                  double savings = budgetState.getMonthlyTotal(FinancialType.savings, index);
                  double difference = income - (expenses + savings);

                  // Check if the difference is zero (using a small epsilon for double comparison)
                  bool isBalanced = difference.abs() < 0.01;

                  if (isBalanced) {
                    // Show tick mark for balanced allocations
                    return const DataCell(
                      Center(
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.purple,
                          size: 24,
                        ),
                      ),
                    );
                  } else {
                    // Format the difference and determine the color for non-zero values
                    String displayValue = difference.abs().toStringAsFixed(2);
                    Color textColor = difference > 0 ? Colors.green : Colors.red;
                    String prefix = difference > 0 ? '+' : '-';

                    return DataCell(
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          '$prefix\$$displayValue',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  List<DataColumn> _buildMonthColumns() {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    
    return months
        .map((month) => DataColumn(
              label: Expanded(
                child: Text(
                  month,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ))
        .toList();
  }
}