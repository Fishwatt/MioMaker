import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:financial_manager_appv5/budget_state.dart';
import 'package:financial_manager_appv5/financial_table.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:financial_manager_appv5/allocation_iden.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 12,
      child: Scaffold(
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(140),
          child: Column(
            children: [
              SizedBox(height: 40),
              AllocationIdentifier(), 
              TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: "January"),
                  Tab(text: "February"),
                  Tab(text: "March"),
                  Tab(text: "April"),
                  Tab(text: "May"),
                  Tab(text: "June"),
                  Tab(text: "July"),
                  Tab(text: "August"),
                  Tab(text: "September"),
                  Tab(text: "October"),
                  Tab(text: "November"),
                  Tab(text: "December"),
                ],
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: List.generate(
            12,
            (index) => MonthSummary(monthIndex: index),
          ),
        ),
      ),
    );
  }
}

class MonthSummary extends StatelessWidget {
  final int monthIndex;

  const MonthSummary({super.key, required this.monthIndex});

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetState>(
      builder: (context, budgetState, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Monthly Distribution Section
                const Text(
                  'Monthly Distribution',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Income Distribution
                _buildDistributionPieChart(
                  'Income Distribution',
                  budgetState,
                  FinancialType.income,
                  monthIndex,
                ),
                const SizedBox(height: 32),

                // Expense Distribution
                _buildDistributionPieChart(
                  'Expense Distribution',
                  budgetState,
                  FinancialType.expense,
                  monthIndex,
                ),
                const SizedBox(height: 32),

                // Savings Distribution
                _buildDistributionPieChart(
                  'Savings Distribution',
                  budgetState,
                  FinancialType.savings,
                  monthIndex,
                ),
                const SizedBox(height: 48),

                // Expenses Section
                const Text(
                  'Expenses Analysis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: _buildBudgetVsActualBarChart(
                    budgetState,
                    FinancialType.expense,
                    monthIndex,
                  ),
                ),
                _buildBudgetSummary(
                  budgetState,
                  FinancialType.expense,
                  monthIndex,
                ),
                const SizedBox(height: 48),

                // Savings Section
                const Text(
                  'Savings Analysis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: _buildBudgetVsActualBarChart(
                    budgetState,
                    FinancialType.savings,
                    monthIndex,
                  ),
                ),
                _buildBudgetSummary(
                  budgetState,
                  FinancialType.savings,
                  monthIndex,
                ),
                const SizedBox(height: 32),

                                _buildNetIncome(budgetState, monthIndex),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetIncome(BudgetState budgetState, int monthIndex) {
    // Calculate tracked values for each type
    final trackedIncome = budgetState.transactions
        .where((t) =>
            t.type == FinancialType.income && t.date.month == monthIndex + 1)
        .fold(0.0, (sum, t) => sum + t.amount);

    final trackedExpenses = budgetState.transactions
        .where((t) =>
            t.type == FinancialType.expense && t.date.month == monthIndex + 1)
        .fold(0.0, (sum, t) => sum + t.amount);

    final trackedSavings = budgetState.transactions
        .where((t) =>
            t.type == FinancialType.savings && t.date.month == monthIndex + 1)
        .fold(0.0, (sum, t) => sum + t.amount);

    // Calculate net income
    final netIncome = trackedIncome - trackedExpenses + trackedSavings;

    // Determine text color based on net income value
    final Color textColor;
    if (netIncome > 0) {
      textColor = Colors.green;
    } else if (netIncome < 0) {
      textColor = Colors.red;
    } else {
      textColor = Colors.black;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Net Income:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '\$${netIncome.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDistributionPieChart(
    String title,
    BudgetState budgetState,
    FinancialType type,
    int monthIndex,
  ) {
    final columns = budgetState.getColumns(type);
    final List<PieChartSectionData> sections = [];

    double total = 0;
    for (var column in columns) {
      final amount = double.tryParse(column.controllers[monthIndex].text) ?? 0;
      if (amount > 0) {
        total += amount;
      }
    }

    if (total == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('No data available'),
        ],
      );
    }

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    for (var i = 0; i < columns.length; i++) {
      final amount =
          double.tryParse(columns[i].controllers[monthIndex].text) ?? 0;
      if (amount > 0) {
        sections.add(
          PieChartSectionData(
            value: amount,
            title: '${(amount / total * 100).toStringAsFixed(1)}%',
            color: colors[i % colors.length],
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < columns.length; i++)
              if ((double.tryParse(columns[i].controllers[monthIndex].text) ??
                      0) >
                  0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: colors[i % colors.length],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      columns[i].name,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetVsActualBarChart(
    BudgetState budgetState,
    FinancialType type,
    int monthIndex,
  ) {
    final columns = budgetState.getColumns(type);
    final List<BarChartGroupData> barGroups = [];

    for (var i = 0; i < columns.length; i++) {
      final budgeted =
          double.tryParse(columns[i].controllers[monthIndex].text) ?? 0;
      final tracked = budgetState.transactions
          .where((t) =>
              t.type == type &&
              t.category == columns[i].name &&
              t.date.month == monthIndex + 1)
          .fold(0.0, (sum, t) => sum + t.amount);

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: budgeted,
              color: Colors.blue,
              width: 16,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            BarChartRodData(
              toY: tracked,
              color: Colors.red,
              width: 16,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
          barsSpace: 4,
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: columns.fold(
              0.0,
              (max, col) => math.max(
                max,
                math.max(
                  double.tryParse(col.controllers[monthIndex].text) ?? 0,
                  budgetState.transactions
                      .where((t) =>
                          t.type == type &&
                          t.category == col.name &&
                          t.date.month == monthIndex + 1)
                      .fold(0.0, (sum, t) => sum + t.amount),
                ),
              ),
            ) *
            1.2,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value >= 0 && value < columns.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      columns[value.toInt()].name,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildBudgetSummary(
    BudgetState budgetState,
    FinancialType type,
    int monthIndex,
  ) {
    final budgeted = budgetState.getMonthlyTotal(type, monthIndex);
    final tracked = budgetState.transactions
        .where((t) => t.type == type && t.date.month == monthIndex + 1)
        .fold(0.0, (sum, t) => sum + t.amount);
    final remaining = budgeted - tracked;

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Budget', budgeted, Colors.blue),
          _buildSummaryItem('Tracked', tracked, Colors.red),
          _buildSummaryItem(
            'Remaining',
            remaining,
            remaining >= 0 ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
