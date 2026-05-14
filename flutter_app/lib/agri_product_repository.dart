import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'agri_cart.dart';
import 'agri_store_catalog.dart';

/// SQLite file name on device (see README / user docs for storage path).
const String kAgriSmartDatabaseFileName = 'agrismart.db';

/// Farmer row for admin visibility (device-local demo registry).
class FarmerRegistration {
  const FarmerRegistration({
    required this.email,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.registeredAtMs,
    required this.updatedAtMs,
  });

  final String email;
  final String fullName;
  final String phone;
  final String address;
  final int registeredAtMs;
  final int updatedAtMs;
}

class AgriProductRepository extends ChangeNotifier {
  AgriProductRepository._();
  static final AgriProductRepository instance = AgriProductRepository._();

  Database? _db;
  List<AgriProduct> _products = const [];

  List<AgriProduct> get products => _products;

  bool get isOpen => _db != null;

  Future<void> open() async {
    if (_db != null) return;

    final dir = await getDatabasesPath();
    final path = p.join(dir, kAgriSmartDatabaseFileName);
    _db = await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE products (
  id TEXT PRIMARY KEY NOT NULL,
  name TEXT NOT NULL,
  brand TEXT NOT NULL,
  category TEXT NOT NULL,
  price_inr INTEGER NOT NULL,
  mrp_inr INTEGER NOT NULL,
  rating REAL NOT NULL,
  review_count INTEGER NOT NULL,
  description TEXT,
  suitable_crops TEXT,
  soil_compatibility TEXT,
  usage_instructions TEXT,
  image_url TEXT
)
''');
        await db.execute('''
CREATE TABLE farmer_registrations (
  email TEXT PRIMARY KEY NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT NOT NULL,
  registered_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE products ADD COLUMN image_url TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('''
CREATE TABLE IF NOT EXISTS farmer_registrations (
  email TEXT PRIMARY KEY NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT NOT NULL,
  registered_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
)
''');
        }
      },
    );

    await _reload();
    if (_products.isEmpty) {
      await _seedFromBuiltInCatalog();
      await _reload();
    }
    notifyListeners();
  }

  Future<void> _seedFromBuiltInCatalog() async {
    final db = _db!;
    final batch = db.batch();
    for (final product in kAgriStoreCatalog) {
      batch.insert(
        'products',
        _toRow(product),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> _reload() async {
    final db = _db;
    if (db == null) {
      _products = const [];
      return;
    }
    final rows = await db.query('products', orderBy: 'name COLLATE NOCASE ASC');
    _products = rows.map(_fromRow).toList();
  }

  Map<String, Object?> _toRow(AgriProduct product) {
    return {
      'id': product.id,
      'name': product.name,
      'brand': product.brand,
      'category': product.category,
      'price_inr': product.priceInr,
      'mrp_inr': product.mrpInr,
      'rating': product.rating,
      'review_count': product.reviewCount,
      'description': product.description,
      'suitable_crops': product.suitableCrops,
      'soil_compatibility': product.soilCompatibility,
      'usage_instructions': product.usageInstructions,
      'image_url': product.imageUrlOverride,
    };
  }

  AgriProduct _fromRow(Map<String, Object?> m) {
    final rawImg = (m['image_url'] as String?)?.trim();
    return AgriProduct(
      id: m['id']! as String,
      name: m['name']! as String,
      brand: m['brand']! as String,
      category: m['category']! as String,
      priceInr: (m['price_inr'] as num).toInt(),
      mrpInr: (m['mrp_inr'] as num).toInt(),
      rating: (m['rating'] as num).toDouble(),
      reviewCount: (m['review_count'] as num).toInt(),
      description: m['description'] as String?,
      suitableCrops: m['suitable_crops'] as String?,
      soilCompatibility: m['soil_compatibility'] as String?,
      usageInstructions: m['usage_instructions'] as String?,
      imageUrlOverride: rawImg != null && rawImg.isNotEmpty ? rawImg : null,
    );
  }

  Future<void> upsert(AgriProduct product) async {
    final db = _db;
    if (db == null) return;
    await db.insert(
      'products',
      _toRow(product),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _reload();
    notifyListeners();
  }

  Future<void> deleteById(String id) async {
    final db = _db;
    if (db == null) return;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
    AgriCart.instance.removeLine(id);
    await _reload();
    notifyListeners();
  }

  /// Upsert farmer profile for admin reporting (called after successful registration).
  Future<void> recordFarmerRegistration({
    required String email,
    required String fullName,
    required String phone,
    required String address,
  }) async {
    final db = _db;
    if (db == null) return;
    final e = email.trim().toLowerCase();
    if (e.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await db.query(
      'farmer_registrations',
      columns: ['registered_at'],
      where: 'email = ?',
      whereArgs: [e],
      limit: 1,
    );
    final firstMs = existing.isEmpty
        ? now
        : (existing.first['registered_at'] as int?) ?? now;
    await db.insert(
      'farmer_registrations',
      {
        'email': e,
        'full_name': fullName.trim(),
        'phone': phone.trim(),
        'address': address.trim(),
        'registered_at': firstMs,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
  }

  Future<List<FarmerRegistration>> listFarmerRegistrations() async {
    final db = _db;
    if (db == null) return const [];
    final rows = await db.query(
      'farmer_registrations',
      orderBy: 'updated_at DESC',
    );
    return rows
        .map(
          (m) => FarmerRegistration(
            email: m['email']! as String,
            fullName: m['full_name']! as String,
            phone: m['phone']! as String,
            address: m['address']! as String,
            registeredAtMs: (m['registered_at'] as num).toInt(),
            updatedAtMs: (m['updated_at'] as num).toInt(),
          ),
        )
        .toList();
  }

  Future<void> deleteFarmerRegistration(String email) async {
    final db = _db;
    if (db == null) return;
    await db.delete(
      'farmer_registrations',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    notifyListeners();
  }

  Future<int> countTotalFarmers() async {
    final db = _db;
    if (db == null) return 0;
    final r = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM farmer_registrations',
    );
    return (r.first['c'] as num?)?.toInt() ?? 0;
  }

  /// Registrations whose first [registered_at] is within the last [days] days.
  Future<int> countNewFarmersWithinDays(int days) async {
    final db = _db;
    if (db == null) return 0;
    final cutoff = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;
    final r = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM farmer_registrations WHERE registered_at >= ?',
      [cutoff],
    );
    return (r.first['c'] as num?)?.toInt() ?? 0;
  }

  Future<int> countProducts() async {
    final db = _db;
    if (db == null) return 0;
    final r = await db.rawQuery('SELECT COUNT(*) AS c FROM products');
    return (r.first['c'] as num?)?.toInt() ?? 0;
  }

  /// New stable id for products created in the admin panel.
  static String newProductId() => 'p_${DateTime.now().millisecondsSinceEpoch}';
}
