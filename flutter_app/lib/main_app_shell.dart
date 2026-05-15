import 'package:flutter/material.dart';

import 'agri_store_screen.dart';
import 'ai_farming_assistant_screen.dart';
import 'farmer_account_screen.dart';
import 'home_dashboard_screen.dart';
import 'insect_live_scan_screen.dart';
import 'l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: _pageFor(_index),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bug_report_outlined),
            selectedIcon: const Icon(Icons.bug_report),
            label: l10n.navLiveScan,
          ),
          NavigationDestination(
            icon: const Icon(Icons.storefront_outlined),
            selectedIcon: const Icon(Icons.storefront),
            label: l10n.navShop,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(Icons.chat_bubble),
            label: l10n.navAssistant,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.navAccount,
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
