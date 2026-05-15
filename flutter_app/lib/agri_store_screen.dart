import 'package:flutter/material.dart';

import 'agri_cached_product_image.dart';
import 'agri_cart.dart';
import 'agri_checkout_screen.dart';
import 'agri_product_detail_screen.dart';
import 'agri_product_repository.dart';
import 'agri_store_catalog.dart';
import 'farmer_account_screen.dart';
import 'farmer_profile_storage.dart';
import 'l10n/app_localizations.dart';

/// Agri inputs shop: searchable grid; product art from [AgriProduct.imageUrl].
class AgriStoreScreen extends StatefulWidget {
  const AgriStoreScreen({super.key, this.initialCategory});

  /// When set to Seeds / Fertilizers / Pesticides, that chip is selected on open.
  final String? initialCategory;

  @override
  State<AgriStoreScreen> createState() => _AgriStoreScreenState();
}

class _AgriStoreScreenState extends State<AgriStoreScreen> {
  final TextEditingController _search = TextEditingController();
  String _category = 'All';
  AgriStoreSort _sort = AgriStoreSort.relevance;
  final Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    final ic = widget.initialCategory;
    if (ic != null && kAgriStoreCategories.contains(ic)) {
      _category = ic;
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _appBarTitle(BuildContext context) =>
      AppLocalizations.of(context).shopAppBarTitle(_category);

  List<AgriProduct> get _filtered {
    var list = List<AgriProduct>.from(AgriProductRepository.instance.products);
    if (_category != 'All') {
      list = list.where((p) => p.category == _category).toList();
    }
    final q = _search.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.brand.toLowerCase().contains(q))
          .toList();
    }
    switch (_sort) {
      case AgriStoreSort.relevance:
        break;
      case AgriStoreSort.priceLowHigh:
        list.sort((a, b) => a.priceInr.compareTo(b.priceInr));
        break;
      case AgriStoreSort.priceHighLow:
        list.sort((a, b) => b.priceInr.compareTo(a.priceInr));
        break;
    }
    return list;
  }

  void _openCartBottomSheet(BuildContext navigatorContext) {
    showModalBottomSheet<void>(
      context: navigatorContext,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (modalCtx) {
        final h = MediaQuery.sizeOf(modalCtx).height * 0.45;
        return ListenableBuilder(
          listenable: AgriCart.instance,
          builder: (sheetContext, _) {
            final lines = AgriCart.instance.lines;
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(modalCtx).padding.bottom + 16,
              ),
              child: lines.isEmpty
                  ? SizedBox(
                      height: 140,
                      child: Center(
                        child: Text(
                          'Your cart is empty.',
                          style: Theme.of(modalCtx).textTheme.titleMedium,
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Cart (${AgriCart.instance.totalItemCount})',
                          style: Theme.of(sheetContext).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: h,
                          child: ListView.separated(
                            itemCount: lines.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final line = lines[i];
                              return ListTile(
                                title: Text(
                                  line.product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  'Qty ${line.qty} · ₹${line.product.priceInr * line.qty}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => AgriCart.instance.removeLine(line.product.id),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(modalCtx);
                            Navigator.of(navigatorContext).push<void>(
                              MaterialPageRoute<void>(builder: (_) => const AgriCheckoutScreen()),
                            );
                          },
                          child: const Text('Proceed to checkout'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            AgriCart.instance.clear();
                            Navigator.pop(modalCtx);
                          },
                          child: const Text('Clear cart'),
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final light = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF1B5E20),
      brightness: Brightness.light,
    );

    return ListenableBuilder(
      listenable: AgriProductRepository.instance,
      builder: (context, _) {
        return Theme(
          data: light,
          child: Builder(
            builder: (context) {
              final scheme = Theme.of(context).colorScheme;
              final products = _filtered;

              return Scaffold(
                appBar: AppBar(
                  title: Text(_appBarTitle(context)),
                  actions: [
                ListenableBuilder(
                  listenable: FarmerProfileController.instance,
                  builder: (context, _) {
                    final n = FarmerProfileController.instance.profile.displayName;
                    return IconButton(
                      tooltip: n.isEmpty ? AppLocalizations.of(context).shopMyAccount : '${AppLocalizations.of(context).shopMyAccount} ($n)',
                      icon: const Icon(Icons.account_circle_outlined),
                      onPressed: () async {
                        await Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(builder: (_) => const FarmerAccountScreen()),
                        );
                        await FarmerProfileController.instance.refresh();
                      },
                    );
                  },
                ),
                ListenableBuilder(
                  listenable: AgriCart.instance,
                  builder: (context, _) {
                    final n = AgriCart.instance.totalItemCount;
                    return Badge(
                      isLabelVisible: n > 0,
                      label: Text('$n'),
                      child: IconButton(
                        tooltip: 'Cart',
                        icon: const Icon(Icons.shopping_cart_outlined),
                        onPressed: () => _openCartBottomSheet(context),
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'More filters',
                  icon: const Icon(Icons.tune),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Advanced filters can be added here.')),
                    );
                  },
                ),
              ],
            ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: SearchBar(
                      controller: _search,
                      hintText: 'Search products…',
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
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: kAgriStoreCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final c = kAgriStoreCategories[i];
                      final sel = c == _category;
                      return FilterChip(
                        label: Text(
                          c,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: c.length > 10 ? 11.5 : 13,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                            height: 1.15,
                          ),
                        ),
                        selected: sel,
                        showCheckmark: false,
                        selectedColor: scheme.primary,
                        labelStyle: TextStyle(color: sel ? scheme.onPrimary : scheme.onSurface),
                        onSelected: (_) => setState(() => _category = c),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                        tooltip: c,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                  child: SegmentedButton<AgriStoreSort>(
                    segments: const [
                      ButtonSegment<AgriStoreSort>(
                        value: AgriStoreSort.relevance,
                        label: Text('Relevance'),
                        icon: Icon(Icons.sort, size: 18),
                      ),
                      ButtonSegment<AgriStoreSort>(
                        value: AgriStoreSort.priceLowHigh,
                        label: Text('Price ↑'),
                      ),
                      ButtonSegment<AgriStoreSort>(
                        value: AgriStoreSort.priceHighLow,
                        label: Text('Price ↓'),
                      ),
                    ],
                    emptySelectionAllowed: false,
                    showSelectedIcon: false,
                    selected: {_sort},
                    onSelectionChanged: (Set<AgriStoreSort> next) {
                      if (next.isEmpty) return;
                      setState(() => _sort = next.first);
                    },
                  ),
                ),
                Expanded(
                  child: products.isEmpty
                      ? Center(
                          child: Text(
                            'No products match your search.',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.56,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final p = products[index];
                            return _ProductCard(
                              product: p,
                              favorite: _favorites.contains(p.id),
                              onOpenDetail: () {
                                Navigator.of(context).push<void>(
                                  MaterialPageRoute<void>(
                                    builder: (_) => AgriProductDetailScreen(product: p),
                                  ),
                                );
                              },
                              onFavorite: () {
                                setState(() {
                                  if (_favorites.contains(p.id)) {
                                    _favorites.remove(p.id);
                                  } else {
                                    _favorites.add(p.id);
                                  }
                                });
                              },
                              onAdd: () {
                                AgriCart.instance.add(p);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Added "${p.name}" · ${AgriCart.instance.totalItemCount} item(s) in cart',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
            },
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onOpenDetail,
    required this.favorite,
    required this.onFavorite,
    required this.onAdd,
  });

  final AgriProduct product;
  final VoidCallback onOpenDetail;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onOpenDetail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AgriCachedProductImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 480,
                  placeholder: (_, __) => ColoredBox(
                    color: scheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (_, __, ___) => ColoredBox(
                    color: scheme.surfaceContainerHighest,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hide_image_outlined, size: 36, color: scheme.outline),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'Could not load image',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: Colors.black45,
                    shape: const CircleBorder(),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      icon: Icon(
                        favorite ? Icons.favorite : Icons.favorite_border,
                        color: favorite ? Colors.pinkAccent : Colors.white,
                        size: 20,
                      ),
                      onPressed: onFavorite,
                    ),
                  ),
                ),
                Positioned(
                  left: 6,
                  top: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.tertiaryContainer.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: scheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        ' (${product.reviewCount})',
                        style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${product.priceInr}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      if (product.discountPercent > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '₹${product.mrpInr}',
                          style: TextStyle(
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: scheme.errorContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${product.discountPercent}% off',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: scheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          minimumSize: const Size(40, 40),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: onAdd,
                        icon: const Icon(Icons.add, size: 22),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
