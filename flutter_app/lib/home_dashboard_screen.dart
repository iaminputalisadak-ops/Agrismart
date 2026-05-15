import 'package:flutter/material.dart';

import 'crop_disease_screen.dart';
import 'farmer_profile_storage.dart';
import 'farmer_register_screen.dart';
import 'l10n/app_localizations.dart';

/// Landing hub: crop tools and shop are sections of the same app (not separate launchers).
class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key, required this.onSelectTab});

  /// Bottom-nav index: 1 live scan, 2 shop, 3 assistant, 4 account.
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final d = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeAppBarTitle),
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
                  l10n.homeHello(name),
                  style: d.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              );
            },
          ),
          Text(
            l10n.homeToolsHeadline,
            style: d.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.homeToolsBlurb,
            style: d.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          _FeatureCard(
            icon: Icons.bug_report_outlined,
            title: l10n.featLiveScanT,
            subtitle: l10n.featLiveScanS,
            onTap: () => onSelectTab(1),
          ),
          _FeatureCard(
            icon: Icons.spa_outlined,
            title: l10n.featDiseaseT,
            subtitle: l10n.featDiseaseS,
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
            title: l10n.featShopT,
            subtitle: l10n.featShopS,
            onTap: () => onSelectTab(2),
          ),
          _FeatureCard(
            icon: Icons.chat_bubble_outline,
            title: l10n.featAssistantT,
            subtitle: l10n.featAssistantS,
            onTap: () => onSelectTab(3),
          ),
          _FeatureCard(
            icon: Icons.app_registration_outlined,
            title: l10n.featRegisterT,
            subtitle: l10n.featRegisterS,
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
            title: l10n.featAccountT,
            subtitle: l10n.featAccountS,
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
