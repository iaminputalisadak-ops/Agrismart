import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'admin_products_screen.dart';
import 'agri_product_repository.dart';

/// Single admin entry: overview, product CRUD, registered farmers, crop feature notes.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs =
      TabController(length: 3, vsync: this, initialIndex: 0);

  PackageInfo? _pkg;
  int _products = 0;
  int _farmers = 0;
  int _newFarmers7d = 0;

  @override
  void initState() {
    super.initState();
    _tabs.addListener(_onTab);
    _loadStats();
  }

  void _onTab() {
    if (!_tabs.indexIsChanging && mounted) _loadStats();
  }

  Future<void> _loadStats() async {
    final repo = AgriProductRepository.instance;
    _pkg ??= await PackageInfo.fromPlatform();
    final p = await repo.countProducts();
    final f = await repo.countTotalFarmers();
    final n = await repo.countNewFarmersWithinDays(7);
    if (mounted) {
      setState(() {
        _products = p;
        _farmers = f;
        _newFarmers7d = n;
      });
    }
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTab);
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriSmart admin'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Products'),
            Tab(text: 'Farmers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _OverviewTab(
            productCount: _products,
            farmerCount: _farmers,
            newFarmers7d: _newFarmers7d,
            versionLabel: _pkg == null
                ? '…'
                : '${_pkg!.version} (${_pkg!.buildNumber})',
            onRefresh: _loadStats,
          ),
          const AdminProductsScreen(embedded: true),
          _FarmersTab(onChanged: _loadStats),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.productCount,
    required this.farmerCount,
    required this.newFarmers7d,
    required this.versionLabel,
    required this.onRefresh,
  });

  final int productCount;
  final int farmerCount;
  final int newFarmers7d;
  final String versionLabel;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final d = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Summary', style: d.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _statCard(
            context,
            icon: Icons.inventory_2_outlined,
            title: 'Products listed',
            value: '$productCount',
            subtitle: 'Add, edit, or remove items under the Products tab.',
          ),
          _statCard(
            context,
            icon: Icons.people_outline,
            title: 'Registered farmers',
            value: '$farmerCount',
            subtitle: 'Profiles saved when farmers complete registration on this device.',
          ),
          _statCard(
            context,
            icon: Icons.person_add_alt_1_outlined,
            title: 'New registrations (7 days)',
            value: '$newFarmers7d',
            subtitle: 'First-time registrations in the last week (by account email).',
          ),
          const SizedBox(height: 20),
          Text('Crop intelligence', style: d.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.bug_report_outlined, color: scheme.primary),
                    title: const Text('Live crop & insect scan'),
                    subtitle: const Text(
                      'Uses on-device demo heuristics until a trained insect_model.tflite is added to assets. '
                      'Harm/safe lists are driven by the built-in crop risk database.',
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.spa_outlined, color: scheme.primary),
                    title: const Text('Crop disease check (photo)'),
                    subtitle: const Text(
                      'Heuristic foliage analysis in the app. Replace bundled models for production-grade diagnosis.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('App build', style: d.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(versionLabel),
            subtitle: const Text('Use this build label when reporting issues or updates.'),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36, color: scheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
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
}

class _FarmersTab extends StatefulWidget {
  const _FarmersTab({required this.onChanged});

  final Future<void> Function() onChanged;

  @override
  State<_FarmersTab> createState() => _FarmersTabState();
}

class _FarmersTabState extends State<_FarmersTab> {
  List<FarmerRegistration> _rows = const [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final list = await AgriProductRepository.instance.listFarmerRegistrations();
    if (mounted) setState(() => _rows = list);
  }

  Future<void> _confirmRemove(FarmerRegistration r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove registration'),
        content: Text(
          'Remove ${r.fullName} (${r.email}) from the admin list? '
          'This does not erase the farmer’s saved profile on their phone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await AgriProductRepository.instance.deleteFarmerRegistration(r.email);
      await widget.onChanged();
      await _reload();
    }
  }

  String _date(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (_rows.isEmpty) {
      return RefreshIndicator(
        onRefresh: _reload,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            Icon(Icons.people_outline, size: 56, color: scheme.outline),
            const SizedBox(height: 12),
            Text(
              'No farmer registrations yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'When a farmer completes registration on this device, they appear here for admin review.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final r = _rows[i];
          return Card(
            child: ListTile(
              title: Text(r.fullName, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                '${r.email}\n${r.phone}\nRegistered: ${_date(r.registeredAtMs)} · Updated: ${_date(r.updatedAtMs)}',
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              isThreeLine: true,
              trailing: IconButton(
                tooltip: 'Remove from list',
                icon: Icon(Icons.delete_outline, color: scheme.error),
                onPressed: () => _confirmRemove(r),
              ),
            ),
          );
        },
      ),
    );
  }
}
