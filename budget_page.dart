import 'package:flutter/material.dart';
import 'package:financial_manager_appv5/financial_table.dart';
import 'package:financial_manager_appv5/allocation_iden.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100, 
          flexibleSpace: const Padding(
            padding: EdgeInsets.only(top: 40.0),
            child: AllocationIdentifier(),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Income"),
              Tab(text: "Expenses"),
              Tab(text: "Savings"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FinancialTable(type: FinancialType.income),
            FinancialTable(type: FinancialType.expense),
            FinancialTable(type: FinancialType.savings),
          ],
        ),
      ),
    );
  }
}