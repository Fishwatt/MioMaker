import 'package:financial_manager_appv5/pages/budget_page.dart';
import 'package:financial_manager_appv5/pages/tracker_page.dart';
import 'package:financial_manager_appv5/pages/summary_page.dart';
import 'package:flutter/material.dart';

class PageNavigator extends StatefulWidget {
  const PageNavigator({super.key});

  @override
  State<PageNavigator> createState() => _PageNavigatorState();
}

class _PageNavigatorState extends State<PageNavigator> {
  int currentPageIndex = 0;

  static final List<Widget> pages = [
    const SummaryPage(),
    const TrackerPage(),
    const BudgetPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.insert_chart), label: "Information"),
            NavigationDestination(icon: Icon(Icons.search), label: "Track"),
            NavigationDestination(icon: Icon(Icons.summarize), label: "Allocation")
          ]),
    );
  }
}
