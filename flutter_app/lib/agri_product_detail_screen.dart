import 'package:flutter/material.dart';

import 'agri_cached_product_image.dart';
import 'agri_cart.dart';
import 'agri_checkout_screen.dart';
import 'agri_store_catalog.dart';
import 'ai_farming_assistant_screen.dart';

/// PDP-style screen: image, specs, Ask AI, Add to cart, Buy now.
class AgriProductDetailScreen extends StatefulWidget {
  const AgriProductDetailScreen({super.key, required this.product});

  final AgriProduct product;

  @override
  State<AgriProductDetailScreen> createState() => _AgriProductDetailScreenState();
}

class _AgriProductDetailScreenState extends State<AgriProductDetailScreen> {
  bool _favorite = false;

  AgriProduct get p => widget.product;

  int get _aiScore => 75 + (p.id.codeUnits.fold<int>(0, (a, b) => a + b) % 18);

  void _addToCart() {
    AgriCart.instance.add(p);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to cart · ${AgriCart.instance.totalItemCount} item(s) total'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _buyNow() {
    AgriCart.instance.add(p);
    if (!mounted) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const AgriCheckoutScreen()),
    );
  }

  void _askAi() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AiFarmingAssistantScreen(
          productContext:
              '${p.name} · ${p.brand}. ${p.displayDescription} Category: ${p.category}.',
          productShopCategory: p.category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final d = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Wishlist',
            onPressed: () => setState(() => _favorite = !_favorite),
            icon: Icon(_favorite ? Icons.favorite : Icons.favorite_border),
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
                  onPressed: () => _openCartSheet(context),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          AspectRatio(
            aspectRatio: 1.15,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AgriCachedProductImage(
                  imageUrl: p.imageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: 720,
                  placeholder: (_, __) => ColoredBox(
                    color: scheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => ColoredBox(
                    color: scheme.surfaceContainerHighest,
                    child: Icon(Icons.image_not_supported, size: 48, color: scheme.outline),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Text(
                        'AI $_aiScore',
                        style: TextStyle(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.brand,
                  style: d.titleMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(p.name, style: d.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade700, size: 22),
                    const SizedBox(width: 4),
                    Text(
                      '${p.rating.toStringAsFixed(1)} (${p.reviewCount} ratings)',
                      style: d.bodyLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${p.priceInr}',
                      style: d.headlineMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (p.mrpInr > p.priceInr) ...[
                      const SizedBox(width: 10),
                      Text(
                        '₹${p.mrpInr}',
                        style: d.bodyMedium?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${p.discountPercent}% off',
                        style: d.labelLarge?.copyWith(
                          color: scheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Text(p.displayDescription, style: d.bodyLarge?.copyWith(height: 1.4)),
                const SizedBox(height: 20),
                _specRow(Icons.spa_outlined, 'Suitable crops', p.displaySuitableCrops),
                const SizedBox(height: 12),
                _specRow(Icons.landscape_outlined, 'Soil compatibility', p.displaySoil),
                const SizedBox(height: 12),
                _specRow(Icons.menu_book_outlined, 'Usage', p.displayUsage),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Material(
        elevation: 12,
        color: scheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _askAi,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Ask AI'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addToCart,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add to cart'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _buyNow,
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Buy now'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openCartSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (modalCtx) {
        return ListenableBuilder(
          listenable: AgriCart.instance,
          builder: (sheetContext, _) {
            final lines = AgriCart.instance.lines;
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.paddingOf(sheetContext).bottom + 16,
              ),
              child: lines.isEmpty
                  ? const SizedBox(
                      height: 160,
                      child: Center(child: Text('Your cart is empty.')),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Cart (${AgriCart.instance.totalItemCount})',
                            style: Theme.of(sheetContext).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Flexible(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: lines.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final line = lines[i];
                              return ListTile(
                                title: Text(line.product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                                subtitle: Text('Qty ${line.qty} · ₹${line.product.priceInr * line.qty}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => AgriCart.instance.removeLine(line.product.id),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(modalCtx);
                            Navigator.of(context).push<void>(
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

  static Widget _specRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(color: Colors.grey.shade800, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }
}
