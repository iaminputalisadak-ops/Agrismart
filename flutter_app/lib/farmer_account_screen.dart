import 'package:flutter/material.dart';

import 'admin_dashboard_screen.dart';
import 'auth_controller.dart';
import 'crop_disease_screen.dart';
import 'farmer_profile_storage.dart';
import 'farmer_register_screen.dart';
import 'insect_live_scan_screen.dart';

/// Farmer profile, integrated crop intelligence tools, and admin catalogue (role-based).
class FarmerAccountScreen extends StatelessWidget {
  const FarmerAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        FarmerProfileController.instance,
        AuthController.instance,
      ]),
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        final d = Theme.of(context).textTheme;
        final auth = AuthController.instance;
        final p = FarmerProfileController.instance.profile;
        final hasProfile = p.displayName.isNotEmpty;

        return Scaffold(
          appBar: AppBar(
            title: Text(auth.isAdmin ? 'Account' : 'My account'),
            actions: [
              if (!auth.isAdmin)
                TextButton(
                  onPressed: () async {
                    await Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const FarmerRegisterScreen(),
                      ),
                    );
                    await FarmerProfileController.instance.refresh();
                  },
                  child: Text(hasProfile ? 'Edit' : 'Register'),
                ),
              IconButton(
                tooltip: 'Sign out',
                icon: const Icon(Icons.logout),
                onPressed: () => AuthController.instance.logout(),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (auth.isAdmin) ...[
                _banner(
                  context,
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Administrator',
                  subtitle:
                      'Signed in as ${auth.email}. Open the admin dashboard to manage products, farmers, and crop-tool notes.',
                  color: scheme.tertiaryContainer,
                  onText: scheme.onTertiaryContainer,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const AdminDashboardScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.dashboard_customize_outlined),
                  label: const Text('Admin dashboard'),
                ),
                const SizedBox(height: 28),
              ],
              if (!auth.isAdmin) ...[
                Text(
                  'Crop intelligence',
                  style: d.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Run detection from your account — same tools as the Home and Live scan tabs.',
                  style: d.bodySmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.35),
                ),
                const SizedBox(height: 14),
                _toolCard(
                  context,
                  icon: Icons.bug_report_outlined,
                  title: 'Live crop & insect scan',
                  subtitle: 'Real-time camera scan with crop-specific harm alerts.',
                  onTap: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const InsectLiveScanScreen(),
                      ),
                    );
                  },
                ),
                _toolCard(
                  context,
                  icon: Icons.spa_outlined,
                  title: 'Crop disease check (photo)',
                  subtitle: 'Analyze a leaf or canopy photo for disease signals.',
                  onTap: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const CropDiseaseScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
              ],
              if (!auth.isAdmin) ...[
                Text(
                  'Profile & delivery',
                  style: d.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (!hasProfile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.person_outline, size: 56, color: scheme.outline),
                      const SizedBox(height: 12),
                      Text(
                        'Complete your farmer profile',
                        style: d.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your name, phone, email, and delivery address for checkout and personalized help.',
                        style: d.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () async {
                          await Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => const FarmerRegisterScreen(),
                            ),
                          );
                          await FarmerProfileController.instance.refresh();
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                else ...[
                  Text(
                    p.displayName,
                    style: d.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Used on checkout, assistant, and anywhere your account appears.',
                    style: d.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  _tile(Icons.phone_outlined, 'Phone', p.phoneDisplay.isEmpty ? '—' : p.phoneDisplay, scheme),
                  _tile(Icons.email_outlined, 'Email', p.email.isEmpty ? '—' : p.email, scheme),
                  _tile(Icons.home_work_outlined, 'Delivery address', p.address.isEmpty ? '—' : p.address, scheme),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => const FarmerRegisterScreen(),
                        ),
                      );
                      await FarmerProfileController.instance.refresh();
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit profile'),
                  ),
                ],
              ],
              if (auth.isAdmin) ...[
                Text(
                  'Admin tools',
                  style: d.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Farmer profiles and crop shortcuts are hidden here. Use the main tabs (Home, Live scan) for crop tools.',
                  style: d.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, height: 1.35),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static Widget _banner(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color onText,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: onText, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: onText,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: onText.withValues(alpha: 0.95),
                          height: 1.35,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _toolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
        trailing: Icon(Icons.open_in_new, color: scheme.outline, size: 20),
        onTap: onTap,
      ),
    );
  }

  static Widget _tile(IconData icon, String label, String value, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
