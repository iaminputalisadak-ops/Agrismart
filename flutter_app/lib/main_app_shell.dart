import 'package:flutter/material.dart';

import 'agri_store_screen.dart';
import 'ai_farming_assistant_screen.dart';
import 'farmer_account_screen.dart';
import 'home_dashboard_screen.dart';
import 'insect_live_scan_screen.dart';

/// Single app entry: home hub + bottom navigation (live scan is one tab, not the whole app).
class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageFor(_index),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bug_report_outlined),
            selectedIcon: Icon(Icons.bug_report),
            label: 'Live scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Assistant',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }

  Widget _pageFor(int i) {
    switch (i) {
      case 0:
        return HomeDashboardScreen(
          onSelectTab: (t) => setState(() => _index = t),
        );
      case 1:
        return const InsectLiveScanScreen();
      case 2:
        return const AgriStoreScreen();
      case 3:
        return const AiFarmingAssistantScreen();
      case 4:
        return const FarmerAccountScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}
