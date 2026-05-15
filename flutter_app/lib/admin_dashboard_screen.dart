import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'admin_products_screen.dart';
import 'agri_product_repository.dart';
import 'auth_controller.dart';
import 'l10n/app_localizations.dart';

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
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: AuthController.instance,
      builder: (context, _) {
        final adminEmail = AuthController.instance.email;
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).adminDashboardTitle),
            bottom: TabBar(
              controller: _tabs,
              indicatorColor: scheme.onPrimary,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard_outlined), text: 'Overview'),
                Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Products'),
                Tab(icon: Icon(Icons.people_outline), text: 'Farmers'),
              ],
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: Row(
                    children: [
                      Icon(Icons.verified_user_outlined, size: 20, color: scheme.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          adminEmail.isEmpty ? 'Administrator session' : 'Signed in as $adminEmail',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
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
              ),
            ],
          ),
        );
      },
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Text('Dashboard', style: d.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Live metrics from this device’s AgriSmart database.',
            style: d.bodySmall?.copyWith(color: scheme.onSurfaceVariant, height: 1.3),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final cross = w >= 520 ? 3 : 2;
              return GridView.count(
                crossAxisCount: cross,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.15,
                children: [
                  _metricTile(
                    context,
                    icon: Icons.inventory_2_outlined,
                    label: 'Catalogue items',
                    value: '$productCount',
                    tint: scheme.primaryContainer,
                    onTint: scheme.onPrimaryContainer,
                  ),
                  _metricTile(
                    context,
                    icon: Icons.how_to_reg_outlined,
                    label: 'Registered farmers',
                    value: '$farmerCount',
                    tint: scheme.secondaryContainer,
                    onTint: scheme.onSecondaryContainer,
                  ),
                  _metricTile(
                    context,
                    icon: Icons.trending_up,
                    label: 'New (7 days)',
                    value: '$newFarmers7d',
                    tint: scheme.tertiaryContainer,
                    onTint: scheme.onTertiaryContainer,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 22),
          Text('Crop intelligence', style: d.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      child: Icon(Icons.bug_report_outlined, color: scheme.onPrimaryContainer),
                    ),
                    title: const Text('Live crop & insect scan'),
                    subtitle: const Text(
                      'On-device TFLite when insect_model.tflite is bundled; otherwise demo heuristics. '
                      'Crop context is estimated automatically from the camera scene (not a trained crop classifier).',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      child: Icon(Icons.spa_outlined, color: scheme.onPrimaryContainer),
                    ),
                    title: const Text('Crop disease check (photo)'),
                    subtitle: const Text(
                      'Bundled heuristics / placeholder models — swap assets for production-grade diagnosis.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text('Build', style: d.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(versionLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Reference this build when reporting issues.'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color tint,
    required Color onTint,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: onTint, size: 26),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onTint,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: onTint.withValues(alpha: 0.92),
                    height: 1.2,
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
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reload();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final list = await AgriProductRepository.instance.listFarmerRegistrations();
    if (mounted) setState(() => _rows = list);
  }

  List<FarmerRegistration> get _filtered {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _rows;
    return _rows
        .where(
          (r) =>
              r.fullName.toLowerCase().contains(q) ||
              r.email.toLowerCase().contains(q) ||
              r.phone.toLowerCase().contains(q) ||
              r.address.toLowerCase().contains(q),
        )
        .toList();
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
    final d = Theme.of(context).textTheme;
    final filtered = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_rows.length} registration${_rows.length == 1 ? '' : 's'}',
                style: d.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SearchBar(
                controller: _search,
                hintText: 'Search name, email, phone, address…',
                leading: const Icon(Icons.search),
                trailing: [
                  if (_search.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _search.clear();
                        setState(() {});
                      },
                    ),
                ],
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        Expanded(
          child: _rows.isEmpty
              ? RefreshIndicator(
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
                )
              : filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No matches for your search.',
                        style: d.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _reload,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final r = filtered[i];
                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.45)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: scheme.primaryContainer,
                                    child: Text(
                                      r.fullName.isNotEmpty ? r.fullName[0].toUpperCase() : '?',
                                      style: TextStyle(
                                        color: scheme.onPrimaryContainer,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.fullName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          r.email,
                                          style: d.bodySmall?.copyWith(color: scheme.primary),
                                        ),
                                        const SizedBox(height: 2),
                                        Text('Phone: ${r.phone}', style: d.bodySmall),
                                        const SizedBox(height: 2),
                                        Text(
                                          r.address,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: d.bodySmall?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Registered ${_date(r.registeredAtMs)} · Updated ${_date(r.updatedAtMs)}',
                                          style: d.labelSmall?.copyWith(color: scheme.outline),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Remove from list',
                                    icon: Icon(Icons.delete_outline, color: scheme.error),
                                    onPressed: () => _confirmRemove(r),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
