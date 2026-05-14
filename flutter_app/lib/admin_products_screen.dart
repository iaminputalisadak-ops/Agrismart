import 'package:flutter/material.dart';

import 'agri_cached_product_image.dart';
import 'agri_product_repository.dart';
import 'agri_store_catalog.dart';

/// Full CRUD over the shop catalogue backed by [AgriProductRepository] (SQLite).
///
/// Set [embedded] when hosting inside [AdminDashboardScreen] (no duplicate app bar).
class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key, this.embedded = false});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<AgriProduct> get _visible {
    final q = _search.text.trim().toLowerCase();
    var list = List<AgriProduct>.from(AgriProductRepository.instance.products);
    if (q.isEmpty) return list;
    return list
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q) ||
            p.id.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _confirmDelete(AgriProduct p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product'),
        content: Text('Remove “${p.name}” from the shop? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await AgriProductRepository.instance.deleteById(p.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted “${p.name}”')),
        );
      }
    }
  }

  Future<void> _openEditor({AgriProduct? existing}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: _ProductEditorPanel(
          initial: existing,
          onSaved: () {
            if (mounted) Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: SearchBar(
            controller: _search,
            hintText: 'Search by name, brand, or id…',
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
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: AgriProductRepository.instance,
            builder: (context, _) {
              final items = _visible;
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    AgriProductRepository.instance.products.isEmpty
                        ? 'No products in database.'
                        : 'No matches.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(16, 8, 16, widget.embedded ? 88 : 88),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final p = items[i];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 52,
                          height: 52,
                          child: AgriCachedProductImage(
                            imageUrl: p.imageUrl,
                            fit: BoxFit.cover,
                            memCacheWidth: 120,
                            placeholder: (_, __) => ColoredBox(
                              color: scheme.surfaceContainerHighest,
                              child: const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => ColoredBox(
                              color: scheme.surfaceContainerHighest,
                              child: Icon(Icons.image_not_supported_outlined, color: scheme.outline),
                            ),
                          ),
                        ),
                      ),
                      title: Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${p.brand} · ${p.category} · ₹${p.priceInr}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _openEditor(existing: p),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            icon: Icon(Icons.delete_outline, color: scheme.error),
                            onPressed: () => _confirmDelete(p),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        if (widget.embedded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: FloatingActionButton.extended(
                onPressed: () => _openEditor(),
                icon: const Icon(Icons.add),
                label: const Text('Add product'),
              ),
            ),
          ),
      ],
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
      body: body,
    );
  }
}

class _ProductEditorPanel extends StatefulWidget {
  const _ProductEditorPanel({this.initial, required this.onSaved});

  final AgriProduct? initial;
  final VoidCallback onSaved;

  @override
  State<_ProductEditorPanel> createState() => _ProductEditorPanelState();
}

class _ProductEditorPanelState extends State<_ProductEditorPanel> {
  late final TextEditingController _idCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _mrpCtrl;
  late final TextEditingController _ratingCtrl;
  late final TextEditingController _reviewsCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _cropsCtrl;
  late final TextEditingController _soilCtrl;
  late final TextEditingController _usageCtrl;
  late final TextEditingController _imageUrlCtrl;

  late String _category;
  bool _saving = false;

  static const _categories = ['Seeds', 'Fertilizers', 'Pesticides', 'Tools'];

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    _idCtrl = TextEditingController(text: p?.id ?? '');
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _brandCtrl = TextEditingController(text: p?.brand ?? '');
    _priceCtrl = TextEditingController(text: p != null ? '${p.priceInr}' : '');
    _mrpCtrl = TextEditingController(text: p != null ? '${p.mrpInr}' : '');
    _ratingCtrl = TextEditingController(text: p != null ? p.rating.toStringAsFixed(1) : '4.5');
    _reviewsCtrl = TextEditingController(text: p != null ? '${p.reviewCount}' : '0');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _cropsCtrl = TextEditingController(text: p?.suitableCrops ?? '');
    _soilCtrl = TextEditingController(text: p?.soilCompatibility ?? '');
    _usageCtrl = TextEditingController(text: p?.usageInstructions ?? '');
    _imageUrlCtrl = TextEditingController(text: p?.imageUrlOverride ?? '');
    _category = p?.category ?? 'Seeds';
    if (!_categories.contains(_category)) _category = 'Seeds';
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _priceCtrl.dispose();
    _mrpCtrl.dispose();
    _ratingCtrl.dispose();
    _reviewsCtrl.dispose();
    _descCtrl.dispose();
    _cropsCtrl.dispose();
    _soilCtrl.dispose();
    _usageCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  String? _validate() {
    final name = _nameCtrl.text.trim();
    final brand = _brandCtrl.text.trim();
    if (name.length < 2) return 'Enter a product name.';
    if (brand.isEmpty) return 'Enter a brand.';
    final price = int.tryParse(_priceCtrl.text.trim());
    final mrp = int.tryParse(_mrpCtrl.text.trim());
    if (price == null || price < 0) return 'Enter a valid price (₹).';
    if (mrp == null || mrp < 0) return 'Enter a valid MRP (₹).';
    if (mrp < price) return 'MRP should be ≥ selling price.';
    final rating = double.tryParse(_ratingCtrl.text.trim());
    if (rating == null || rating < 0 || rating > 5) return 'Rating must be between 0 and 5.';
    final reviews = int.tryParse(_reviewsCtrl.text.trim());
    if (reviews == null || reviews < 0) return 'Review count must be a non‑negative integer.';
    return null;
  }

  Future<void> _save() async {
    final err = _validate();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    setState(() => _saving = true);
    try {
      final id = widget.initial?.id ?? (_idCtrl.text.trim().isEmpty ? AgriProductRepository.newProductId() : _idCtrl.text.trim());
      final product = AgriProduct(
        id: id,
        name: _nameCtrl.text.trim(),
        brand: _brandCtrl.text.trim(),
        category: _category,
        priceInr: int.parse(_priceCtrl.text.trim()),
        mrpInr: int.parse(_mrpCtrl.text.trim()),
        rating: double.parse(_ratingCtrl.text.trim()),
        reviewCount: int.parse(_reviewsCtrl.text.trim()),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        suitableCrops: _cropsCtrl.text.trim().isEmpty ? null : _cropsCtrl.text.trim(),
        soilCompatibility: _soilCtrl.text.trim().isEmpty ? null : _soilCtrl.text.trim(),
        usageInstructions: _usageCtrl.text.trim().isEmpty ? null : _usageCtrl.text.trim(),
        imageUrlOverride: _imageUrlCtrl.text.trim().isEmpty ? null : _imageUrlCtrl.text.trim(),
      );
      await AgriProductRepository.instance.upsert(product);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product saved')),
        );
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isNew = widget.initial == null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isNew ? 'Add product' : 'Edit product',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              isNew
                  ? 'Leave ID empty to auto-generate. Images default to crop-related stock photos from the product name.'
                  : 'Product id cannot be changed.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (isNew)
              TextField(
                controller: _idCtrl,
                decoration: const InputDecoration(
                  labelText: 'Product id (optional)',
                  hintText: 'Auto if empty',
                  prefixIcon: Icon(Icons.tag),
                ),
              )
            else
              TextField(
                controller: _idCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Product id',
                  prefixIcon: Icon(Icons.tag),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _brandCtrl,
              decoration: const InputDecoration(
                labelText: 'Brand',
                prefixIcon: Icon(Icons.storefront_outlined),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey(_category),
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price (₹)',
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _mrpCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'MRP (₹)',
                      prefixIcon: Icon(Icons.price_change_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ratingCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Rating (0–5)',
                      prefixIcon: Icon(Icons.star_outline),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _reviewsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reviews',
                      prefixIcon: Icon(Icons.reviews_outlined),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _imageUrlCtrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Product image URL (optional)',
                hintText: 'https://… (leave blank for automatic photo)',
                prefixIcon: Icon(Icons.image_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _cropsCtrl,
              decoration: const InputDecoration(
                labelText: 'Suitable crops (optional)',
                prefixIcon: Icon(Icons.spa_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _soilCtrl,
              decoration: const InputDecoration(
                labelText: 'Soil / compatibility (optional)',
                prefixIcon: Icon(Icons.landscape_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usageCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Usage (optional)',
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.menu_book_outlined),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save product'),
            ),
          ],
        ),
      ),
    );
  }
}
