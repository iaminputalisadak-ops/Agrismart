import 'package:flutter/material.dart';

import 'crop_disease_screen.dart';
import 'farmer_profile_storage.dart';
import 'farmer_register_screen.dart';

/// Landing hub: crop tools and shop are sections of the same app (not separate launchers).
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key, required this.onSelectTab});

  /// Bottom-nav index: 1 live scan, 2 shop, 3 assistant, 4 account.
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final d = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriSmart'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListenableBuilder(
            listenable: FarmerProfileController.instance,
            builder: (context, _) {
              final name = FarmerProfileController.instance.profile.displayName;
              if (name.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Hello, $name',
                  style: d.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              );
            },
          ),
          Text(
            'Your farming tools',
            style: d.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Live pest checks, disease screening, inputs, and help — all in this app.',
            style: d.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          _FeatureCard(
            icon: Icons.bug_report_outlined,
            title: 'Live crop & insect scan',
            subtitle:
                'Camera scan with alerts when an insect may harm your selected crop.',
            onTap: () => onSelectTab(1),
          ),
          _FeatureCard(
            icon: Icons.spa_outlined,
            title: 'Crop disease check (photo)',
            subtitle: 'Capture or choose a leaf photo for disease screening.',
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const CropDiseaseScreen(),
                ),
              );
            },
          ),
          _FeatureCard(
            icon: Icons.storefront_outlined,
            title: 'Agri inputs shop',
            subtitle: 'Seeds, fertilizer, and crop protection products.',
            onTap: () => onSelectTab(2),
          ),
          _FeatureCard(
            icon: Icons.chat_bubble_outline,
            title: 'AI farming assistant',
            subtitle: 'Questions on crops, pests, and practices.',
            onTap: () => onSelectTab(3),
          ),
          _FeatureCard(
            icon: Icons.app_registration_outlined,
            title: 'Farmer registration',
            subtitle: 'Save your profile for checkout and personalized help.',
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const FarmerRegisterScreen(),
                ),
              );
            },
          ),
          _FeatureCard(
            icon: Icons.person_outline,
            title: 'My account',
            subtitle: 'View or edit your saved profile.',
            onTap: () => onSelectTab(4),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: Icon(Icons.chevron_right, color: scheme.outline),
        onTap: onTap,
      ),
    );
  }
}
