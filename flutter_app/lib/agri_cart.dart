import 'package:flutter/foundation.dart';

import 'agri_store_catalog.dart';

/// In-memory cart for the agri shop (demo). Wire to checkout / backend later.
class AgriCart extends ChangeNotifier {
  AgriCart._();
  static final AgriCart instance = AgriCart._();

  final Map<String, int> _qtyById = <String, int>{};
  final Map<String, AgriProduct> _productById = <String, AgriProduct>{};

  int get totalItemCount =>
      _qtyById.values.fold<int>(0, (sum, q) => sum + q);

  int quantityOf(String productId) => _qtyById[productId] ?? 0;

  List<({AgriProduct product, int qty})> get lines {
    final out = <({AgriProduct product, int qty})>[];
    for (final e in _qtyById.entries) {
      final p = _productById[e.key];
      if (p != null) out.add((product: p, qty: e.value));
    }
    return out;
  }

  int get subtotalInr {
    var sum = 0;
    for (final line in lines) {
      sum += line.product.priceInr * line.qty;
    }
    return sum;
  }

  void add(AgriProduct product, {int qty = 1}) {
    if (qty <= 0) return;
    _productById[product.id] = product;
    _qtyById[product.id] = (_qtyById[product.id] ?? 0) + qty;
    notifyListeners();
  }

  void setQuantity(String productId, int qty) {
    if (qty <= 0) {
      _qtyById.remove(productId);
      _productById.remove(productId);
    } else {
      _qtyById[productId] = qty;
    }
    notifyListeners();
  }

  void removeLine(String productId) {
    _qtyById.remove(productId);
    _productById.remove(productId);
    notifyListeners();
  }

  void clear() {
    _qtyById.clear();
    _productById.clear();
    notifyListeners();
  }
}
