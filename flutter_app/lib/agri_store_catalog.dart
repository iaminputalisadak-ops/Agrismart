/// Agri e‑commerce demo catalogue.
///
/// Product images use [resolveAgriProductStockImage] (Wikimedia Commons, matched
/// to product name) with an optional per-product admin URL override from SQLite.
library agri_store_catalog;

import 'agri_product_stock_images.dart';

class AgriProduct {
  const AgriProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.priceInr,
    required this.mrpInr,
    required this.rating,
    required this.reviewCount,
    this.description,
    this.suitableCrops,
    this.soilCompatibility,
    this.usageInstructions,
    this.imageUrlOverride,
  });

  final String id;
  final String name;
  final String brand;
  /// One of: Seeds, Fertilizers, Pesticides, Tools
  final String category;
  final int priceInr;
  final int mrpInr;
  final double rating;
  final int reviewCount;
  final String? description;
  final String? suitableCrops;
  final String? soilCompatibility;
  final String? usageInstructions;
  /// Optional HTTPS image URL (set in admin / DB). When null, a stock photo is chosen from the product name.
  final String? imageUrlOverride;

  String get displayDescription {
    if (description != null && description!.trim().isNotEmpty) return description!;
    return switch (category) {
      'Seeds' =>
        'Certified seed / planting material. Check germination % and lot number on the pack before sowing.',
      'Fertilizers' =>
        'Soil amendment or plant nutrition product. Apply rates based on soil test and local extension advice.',
      'Pesticides' =>
        'Plant protection product. Read the label, use PPE, and respect PHI before harvest.',
      'Tools' =>
        'Farm tool or equipment. Inspect welds, hoses, and seals before first use; follow safety guards.',
      _ => 'Agricultural input — follow label and local regulations.',
    };
  }

  String get displaySuitableCrops {
    if (suitableCrops != null && suitableCrops!.trim().isNotEmpty) return suitableCrops!;
    return switch (category) {
      'Seeds' => 'See pack label for recommended crops and seasons.',
      'Fertilizers' => 'Most field and horticultural crops when deficiency matches product.',
      'Pesticides' => 'Only crops and pests listed on the registered label.',
      'Tools' => 'General field and garden use unless marked specialty.',
      _ => 'Refer to product documentation.',
    };
  }

  String get displaySoil {
    if (soilCompatibility != null && soilCompatibility!.trim().isNotEmpty) return soilCompatibility!;
    return switch (category) {
      'Seeds' => 'Well-prepared, well-drained nursery beds or field as per crop.',
      'Fertilizers' => 'Typical agricultural soils; avoid application to waterlogged fields unless specified.',
      'Pesticides' => 'Follow label restrictions for soil type and proximity to water.',
      'Tools' => 'Firm level ground; store dry after washing.',
      _ => 'As per label.',
    };
  }

  String get displayUsage {
    if (usageInstructions != null && usageInstructions!.trim().isNotEmpty) return usageInstructions!;
    return switch (category) {
      'Seeds' => 'Sow at recommended depth and spacing for your agro-climatic zone.',
      'Fertilizers' => 'Split doses where recommended; avoid foliar burn in hot midday sun.',
      'Pesticides' => 'Calibrate sprayer, alternate MOA where resistance is a risk.',
      'Tools' => 'Rinse sprayers separately; grease moving parts per manual.',
      _ => 'Follow manufacturer instructions.',
    };
  }

  /// Product image: admin [imageUrlOverride] if set, else name-matched agricultural stock photo.
  String get imageUrl => resolveAgriProductStockImage(
        productName: name,
        category: category,
        imageUrlOverride: imageUrlOverride,
        productId: id,
      );

  AgriProduct copyWith({
    String? id,
    String? name,
    String? brand,
    String? category,
    int? priceInr,
    int? mrpInr,
    double? rating,
    int? reviewCount,
    String? description,
    String? suitableCrops,
    String? soilCompatibility,
    String? usageInstructions,
    String? imageUrlOverride,
  }) {
    return AgriProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      priceInr: priceInr ?? this.priceInr,
      mrpInr: mrpInr ?? this.mrpInr,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      description: description ?? this.description,
      suitableCrops: suitableCrops ?? this.suitableCrops,
      soilCompatibility: soilCompatibility ?? this.soilCompatibility,
      usageInstructions: usageInstructions ?? this.usageInstructions,
      imageUrlOverride: imageUrlOverride ?? this.imageUrlOverride,
    );
  }

  int get discountPercent {
    if (mrpInr <= 0 || mrpInr <= priceInr) return 0;
    return (((mrpInr - priceInr) / mrpInr) * 100).round();
  }
}

const List<String> kAgriStoreCategories = ['All', 'Seeds', 'Fertilizers', 'Pesticides', 'Tools'];

enum AgriStoreSort { relevance, priceLowHigh, priceHighLow }

const List<AgriProduct> kAgriStoreCatalog = [
  // —— Seeds ——
  AgriProduct(
    id: 's1',
    name: 'Basmati Rice 1121 (10 kg)',
    brand: 'GreenHarvest',
    category: 'Seeds',
    priceInr: 1200,
    mrpInr: 1500,
    rating: 4.6,
    reviewCount: 980,
    description: 'Premium basmati rice variety with long grains and excellent aroma.',
    suitableCrops: 'Rice, Paddy',
    soilCompatibility: 'Clay, Alluvial',
    usageInstructions: 'Transplant 25-day seedlings, 20x15 cm spacing.',
  ),
  AgriProduct(id: 's2', name: 'Hybrid Wheat HD-2967 (5 kg)', brand: 'AgriSeeds Co.', category: 'Seeds', priceInr: 540, mrpInr: 690, rating: 4.5, reviewCount: 189),
  AgriProduct(id: 's3', name: 'Banana Tissue Culture (10 plants)', brand: 'GreenGrow', category: 'Seeds', priceInr: 420, mrpInr: 500, rating: 4.3, reviewCount: 96),
  AgriProduct(id: 's4', name: 'Pomegranate Bhagwa Sapling', brand: 'Orchard Pro', category: 'Seeds', priceInr: 180, mrpInr: 240, rating: 4.4, reviewCount: 142),
  AgriProduct(id: 's5', name: 'Hybrid Maize DHM-117 (4 kg)', brand: 'AgriSeeds Co.', category: 'Seeds', priceInr: 890, mrpInr: 1020, rating: 4.5, reviewCount: 167),
  AgriProduct(id: 's6', name: 'Mustard Pusa Bold (3 kg)', brand: 'NorthFarm', category: 'Seeds', priceInr: 310, mrpInr: 380, rating: 4.2, reviewCount: 88),
  AgriProduct(id: 's7', name: 'Cotton BT Hybrid (450 g)', brand: 'FiberMax', category: 'Seeds', priceInr: 920, mrpInr: 1100, rating: 4.1, reviewCount: 201),
  AgriProduct(id: 's8', name: 'Sugarcane Co-0238 Setts (100)', brand: 'SweetCane', category: 'Seeds', priceInr: 650, mrpInr: 780, rating: 4.4, reviewCount: 73),
  AgriProduct(id: 's9', name: 'Potato Kufri Pukhraj (50 kg)', brand: 'TuberTech', category: 'Seeds', priceInr: 1450, mrpInr: 1680, rating: 4.5, reviewCount: 154),
  AgriProduct(id: 's10', name: 'Tomato Arka Rakshak F1 (10 g)', brand: 'VegiSeed', category: 'Seeds', priceInr: 195, mrpInr: 240, rating: 4.6, reviewCount: 312),
  AgriProduct(id: 's11', name: 'Soybean JS 335 (40 kg)', brand: 'PulsePro', category: 'Seeds', priceInr: 4100, mrpInr: 4600, rating: 4.3, reviewCount: 56),
  AgriProduct(id: 's12', name: 'Chickpea Desi Mix (30 kg)', brand: 'PulsePro', category: 'Seeds', priceInr: 2800, mrpInr: 3200, rating: 4.4, reviewCount: 91),
  AgriProduct(id: 's13', name: 'Sunflower KBSH-44 (2 kg)', brand: 'OilCrop', category: 'Seeds', priceInr: 780, mrpInr: 920, rating: 4.2, reviewCount: 67),
  AgriProduct(id: 's14', name: 'Red Onion N-53 (4 kg)', brand: 'BulbFarm', category: 'Seeds', priceInr: 1120, mrpInr: 1280, rating: 4.5, reviewCount: 178),
  AgriProduct(id: 's15', name: 'Finger Millet GPU-28 (8 kg)', brand: 'MilletCo', category: 'Seeds', priceInr: 480, mrpInr: 560, rating: 4.3, reviewCount: 44),
  AgriProduct(id: 's16', name: 'Red Lentil IPL-406 (25 kg)', brand: 'PulsePro', category: 'Seeds', priceInr: 2200, mrpInr: 2550, rating: 4.4, reviewCount: 102),
  AgriProduct(id: 's17', name: 'Okra Parbhani Kranti F1 (100 g)', brand: 'VegiSeed', category: 'Seeds', priceInr: 165, mrpInr: 200, rating: 4.5, reviewCount: 233),
  AgriProduct(id: 's18', name: 'Chilli Tejaswini F1 (50 g)', brand: 'SpiceSeed', category: 'Seeds', priceInr: 210, mrpInr: 260, rating: 4.4, reviewCount: 198),
  AgriProduct(id: 's19', name: 'Cabbage Golden Acre (25 g)', brand: 'VegiSeed', category: 'Seeds', priceInr: 95, mrpInr: 120, rating: 4.2, reviewCount: 145),
  AgriProduct(id: 's20', name: 'Carrot Pusa Rudhira (400 g)', brand: 'VegiSeed', category: 'Seeds', priceInr: 340, mrpInr: 400, rating: 4.3, reviewCount: 87),
  AgriProduct(id: 's21', name: 'Cucumber Japanese Long (50 g)', brand: 'VegiSeed', category: 'Seeds', priceInr: 125, mrpInr: 155, rating: 4.4, reviewCount: 121),
  AgriProduct(id: 's22', name: 'Green Gram CO-8 (20 kg)', brand: 'PulsePro', category: 'Seeds', priceInr: 1680, mrpInr: 1920, rating: 4.3, reviewCount: 63),
  AgriProduct(id: 's23', name: 'Black Gram T-9 (20 kg)', brand: 'PulsePro', category: 'Seeds', priceInr: 1750, mrpInr: 2000, rating: 4.2, reviewCount: 71),
  AgriProduct(id: 's24', name: 'Pearl Millet ICMV-221 (3 kg)', brand: 'MilletCo', category: 'Seeds', priceInr: 290, mrpInr: 350, rating: 4.1, reviewCount: 52),
  AgriProduct(id: 's25', name: 'Sesame white local (5 kg)', brand: 'OilCrop', category: 'Seeds', priceInr: 620, mrpInr: 720, rating: 4.0, reviewCount: 39),
  AgriProduct(id: 's26', name: 'Watermelon Sugar Baby F1 (50 g)', brand: 'VegiSeed', category: 'Seeds', priceInr: 210, mrpInr: 255, rating: 4.3, reviewCount: 94),
  AgriProduct(id: 's27', name: 'Bitter Gourd Pusa Vishwas (100 g)', brand: 'VegiSeed', category: 'Seeds', priceInr: 185, mrpInr: 220, rating: 4.2, reviewCount: 76),
  AgriProduct(id: 's28', name: 'Brinjal Round F1 (10 g)', brand: 'VegiSeed', category: 'Seeds', priceInr: 95, mrpInr: 120, rating: 4.4, reviewCount: 201),
  AgriProduct(id: 's29', name: 'Coriander local (500 g)', brand: 'SpiceSeed', category: 'Seeds', priceInr: 120, mrpInr: 145, rating: 4.1, reviewCount: 58),
  AgriProduct(id: 's30', name: 'Fenugreek Kasuri (1 kg)', brand: 'SpiceSeed', category: 'Seeds', priceInr: 160, mrpInr: 190, rating: 4.0, reviewCount: 47),
  AgriProduct(id: 's31', name: 'Hybrid Paddy IR-64 (25 kg)', brand: 'Krishi Seeds', category: 'Seeds', priceInr: 1680, mrpInr: 1920, rating: 4.5, reviewCount: 164),
  AgriProduct(id: 's32', name: 'Sweet Corn Sugar-75 F1 (1 kg)', brand: 'VegiSeed', category: 'Seeds', priceInr: 890, mrpInr: 1020, rating: 4.4, reviewCount: 112),
  AgriProduct(id: 's33', name: 'Foxtail Millet KMR-370 (4 kg)', brand: 'MilletCo', category: 'Seeds', priceInr: 340, mrpInr: 400, rating: 4.2, reviewCount: 38),
  AgriProduct(id: 's34', name: 'Bajra Hybrid 86M86 (3 kg)', brand: 'MilletCo', category: 'Seeds', priceInr: 260, mrpInr: 310, rating: 4.1, reviewCount: 47),
  AgriProduct(id: 's35', name: 'Groundnut TMV-13 (80 kg)', brand: 'OilCrop', category: 'Seeds', priceInr: 6200, mrpInr: 6900, rating: 4.4, reviewCount: 112),
  AgriProduct(id: 's36', name: 'Castor hybrid GCH-7 (2 kg)', brand: 'OilCrop', category: 'Seeds', priceInr: 890, mrpInr: 1020, rating: 4.0, reviewCount: 29),
  AgriProduct(id: 's37', name: 'Jowar hybrid CSH-16 (4 kg)', brand: 'MilletCo', category: 'Seeds', priceInr: 380, mrpInr: 440, rating: 4.2, reviewCount: 56),
  AgriProduct(id: 's38', name: 'Lucerne / Alfalfa Multicut (1 kg)', brand: 'ForagePro', category: 'Seeds', priceInr: 1180, mrpInr: 1350, rating: 4.3, reviewCount: 67),
  AgriProduct(id: 's39', name: 'Rhodes grass seed (5 kg)', brand: 'ForagePro', category: 'Seeds', priceInr: 1450, mrpInr: 1680, rating: 4.1, reviewCount: 34),
  AgriProduct(id: 's40', name: 'Hybrid Napier CO-4 slips (100)', brand: 'ForagePro', category: 'Seeds', priceInr: 520, mrpInr: 620, rating: 4.4, reviewCount: 91),
  AgriProduct(id: 's41', name: 'Turmeric Salem local rhizome (10 kg)', brand: 'SpiceSeed', category: 'Seeds', priceInr: 980, mrpInr: 1150, rating: 4.5, reviewCount: 144),
  AgriProduct(id: 's42', name: 'Ginger high altitude variety (5 kg)', brand: 'SpiceSeed', category: 'Seeds', priceInr: 720, mrpInr: 860, rating: 4.3, reviewCount: 78),
  AgriProduct(id: 's43', name: 'Elephant foot yam Gajendra (5 kg)', brand: 'TuberTech', category: 'Seeds', priceInr: 340, mrpInr: 400, rating: 4.2, reviewCount: 51),
  AgriProduct(id: 's44', name: 'Colocasia corm local (8 kg)', brand: 'TuberTech', category: 'Seeds', priceInr: 280, mrpInr: 330, rating: 4.0, reviewCount: 33),
  AgriProduct(id: 's45', name: 'Drumstick PKM-1 pods seed (250 g)', brand: 'VegiSeed', category: 'Seeds', priceInr: 195, mrpInr: 240, rating: 4.4, reviewCount: 167),
  AgriProduct(id: 's46', name: 'Ridge gourd hybrid (100 g)', brand: 'VegiSeed', category: 'Seeds', priceInr: 125, mrpInr: 155, rating: 4.3, reviewCount: 98),
  AgriProduct(id: 's47', name: 'Bottle gourd Pusa Summer (50 g)', brand: 'VegiSeed', category: 'Seeds', priceInr: 95, mrpInr: 120, rating: 4.2, reviewCount: 121),
  AgriProduct(id: 's48', name: 'French beans bush type (250 g)', brand: 'VegiSeed', category: 'Seeds', priceInr: 210, mrpInr: 255, rating: 4.4, reviewCount: 86),

  // —— Fertilizers (incl. names from your screenshot) ——
  AgriProduct(id: 'f1', name: 'Urea 46% N (45 kg bag)', brand: 'NutriField', category: 'Fertilizers', priceInr: 315, mrpInr: 360, rating: 4.5, reviewCount: 402),
  AgriProduct(id: 'f2', name: 'IFFCO DAP 18-46-0 (50 kg)', brand: 'IFFCO', category: 'Fertilizers', priceInr: 1450, mrpInr: 1620, rating: 4.7, reviewCount: 891),
  AgriProduct(id: 'f3', name: 'Yara NPK 19-19-19 WS (5 kg)', brand: 'Yara', category: 'Fertilizers', priceInr: 1180, mrpInr: 1350, rating: 4.6, reviewCount: 312),
  AgriProduct(id: 'f4', name: 'MOP 0-0-60 Potash (50 kg)', brand: 'NutriField', category: 'Fertilizers', priceInr: 1780, mrpInr: 1950, rating: 4.3, reviewCount: 156),
  AgriProduct(id: 'f5', name: 'Zinc Sulphate mono (25 kg)', brand: 'MicroNutri', category: 'Fertilizers', priceInr: 890, mrpInr: 1020, rating: 4.2, reviewCount: 98),
  AgriProduct(id: 'f6', name: 'Borax 10.5% B (20 kg)', brand: 'MicroNutri', category: 'Fertilizers', priceInr: 720, mrpInr: 840, rating: 4.1, reviewCount: 67),
  AgriProduct(id: 'f7', name: 'Vermicompost (50 kg)', brand: 'OrganicEarth', category: 'Fertilizers', priceInr: 420, mrpInr: 500, rating: 4.6, reviewCount: 234),
  AgriProduct(id: 'f23', name: 'EcoFarm Organic Vermicompost (25 kg)', brand: 'EcoFarm', category: 'Fertilizers', priceInr: 360, mrpInr: 440, rating: 4.7, reviewCount: 412),
  AgriProduct(id: 'f8', name: 'Well-decomposed FYM (40 kg)', brand: 'OrganicEarth', category: 'Fertilizers', priceInr: 180, mrpInr: 220, rating: 4.4, reviewCount: 121),
  AgriProduct(id: 'f9', name: 'SSP Single Super Phosphate (50 kg)', brand: 'GrowMore', category: 'Fertilizers', priceInr: 920, mrpInr: 1050, rating: 4.2, reviewCount: 88),
  AgriProduct(id: 'f10', name: 'Calcium Nitrate (25 kg)', brand: 'GrowMore', category: 'Fertilizers', priceInr: 1100, mrpInr: 1280, rating: 4.3, reviewCount: 76),
  AgriProduct(id: 'f11', name: 'Rhizobium Biofertilizer (1 L)', brand: 'BioAgri', category: 'Fertilizers', priceInr: 240, mrpInr: 290, rating: 4.4, reviewCount: 143),
  AgriProduct(id: 'f12', name: 'Azotobacter Liquid (500 ml)', brand: 'BioAgri', category: 'Fertilizers', priceInr: 165, mrpInr: 200, rating: 4.3, reviewCount: 91),
  AgriProduct(id: 'f13', name: 'Magnesium Sulphate Epsom (10 kg)', brand: 'MicroNutri', category: 'Fertilizers', priceInr: 380, mrpInr: 450, rating: 4.2, reviewCount: 54),
  AgriProduct(id: 'f14', name: 'Humic Acid Granules (25 kg)', brand: 'OrganicEarth', category: 'Fertilizers', priceInr: 1450, mrpInr: 1680, rating: 4.3, reviewCount: 72),
  AgriProduct(id: 'f15', name: 'NPK 10:26:26 (50 kg)', brand: 'NutriField', category: 'Fertilizers', priceInr: 1980, mrpInr: 2200, rating: 4.5, reviewCount: 198),
  AgriProduct(id: 'f16', name: 'Calcium Nitrate + Boron (1 kg)', brand: 'GrowMore', category: 'Fertilizers', priceInr: 195, mrpInr: 230, rating: 4.3, reviewCount: 167),
  AgriProduct(id: 'f17', name: 'PI Industries Seaweed Bio-stimulant (1 L)', brand: 'PI Industries', category: 'Fertilizers', priceInr: 620, mrpInr: 720, rating: 4.6, reviewCount: 289),
  AgriProduct(id: 'f18', name: 'Potassium Schoenite (25 kg)', brand: 'NutriField', category: 'Fertilizers', priceInr: 1320, mrpInr: 1500, rating: 4.2, reviewCount: 61),
  AgriProduct(id: 'f19', name: 'Liquid NPK 20:20:20 (1 L)', brand: 'Yara', category: 'Fertilizers', priceInr: 340, mrpInr: 390, rating: 4.5, reviewCount: 144),
  AgriProduct(id: 'f20', name: 'Granular Gypsum (40 kg)', brand: 'GrowMore', category: 'Fertilizers', priceInr: 280, mrpInr: 320, rating: 4.1, reviewCount: 43),
  AgriProduct(id: 'f21', name: 'Iron Chelate Fe-EDTA (500 g)', brand: 'MicroNutri', category: 'Fertilizers', priceInr: 420, mrpInr: 490, rating: 4.2, reviewCount: 56),
  AgriProduct(id: 'f22', name: 'Potassium Nitrate 13-0-45 (25 kg)', brand: 'NutriField', category: 'Fertilizers', priceInr: 2100, mrpInr: 2380, rating: 4.4, reviewCount: 77),
  AgriProduct(id: 'f24', name: 'Multiplex Iron EDTA Chelated Micronutrient (1 kg)', brand: 'Multiplex', category: 'Fertilizers', priceInr: 720, mrpInr: 915, rating: 4.3, reviewCount: 240, description: 'Chelated iron for foliar or soil drench on iron-deficient crops.'),
  AgriProduct(id: 'f25', name: 'Coromandel Zinc Sulphate 21% (5 kg)', brand: 'Coromandel', category: 'Fertilizers', priceInr: 420, mrpInr: 560, rating: 4.2, reviewCount: 480, description: 'Zinc sulphate monohydrate for basal or top dressing as per soil Zn status.'),
  AgriProduct(id: 'f26', name: 'Ammonium Sulphate 21% N (50 kg)', brand: 'NutriField', category: 'Fertilizers', priceInr: 980, mrpInr: 1120, rating: 4.3, reviewCount: 156),
  AgriProduct(id: 'f27', name: 'Calcium Ammonium Nitrate CAN (50 kg)', brand: 'GrowMore', category: 'Fertilizers', priceInr: 1420, mrpInr: 1620, rating: 4.4, reviewCount: 201),
  AgriProduct(id: 'f28', name: 'Water Soluble NPK 13-40-13 (1 kg)', brand: 'Yara', category: 'Fertilizers', priceInr: 285, mrpInr: 340, rating: 4.5, reviewCount: 312),
  AgriProduct(id: 'f29', name: 'Bentonite Sulphur 90% (20 kg)', brand: 'MicroNutri', category: 'Fertilizers', priceInr: 1180, mrpInr: 1350, rating: 4.2, reviewCount: 88),
  AgriProduct(id: 'f30', name: 'Manganese Sulphate 30% (25 kg)', brand: 'MicroNutri', category: 'Fertilizers', priceInr: 920, mrpInr: 1080, rating: 4.1, reviewCount: 64),
  AgriProduct(id: 'f31', name: 'Copper Sulphate Pentahydrate (5 kg)', brand: 'GrowMore', category: 'Fertilizers', priceInr: 640, mrpInr: 760, rating: 4.0, reviewCount: 71),
  AgriProduct(id: 'f32', name: 'Ammonium Molybdate 1% Mo (500 g)', brand: 'MicroNutri', category: 'Fertilizers', priceInr: 380, mrpInr: 450, rating: 4.2, reviewCount: 42),
  AgriProduct(id: 'f33', name: 'Silicon Soluble Powder (10 kg)', brand: 'NutriField', category: 'Fertilizers', priceInr: 1680, mrpInr: 1920, rating: 4.3, reviewCount: 55),
  AgriProduct(id: 'f34', name: 'Liquid Calcium 10% w/v (5 L)', brand: 'GrowMore', category: 'Fertilizers', priceInr: 890, mrpInr: 1020, rating: 4.4, reviewCount: 97),
  AgriProduct(id: 'f35', name: 'Bio NPK Consortium (1 kg)', brand: 'BioAgri', category: 'Fertilizers', priceInr: 195, mrpInr: 240, rating: 4.5, reviewCount: 178),
  AgriProduct(id: 'f36', name: 'Phosphate Rich Organic Manure PROM (40 kg)', brand: 'OrganicEarth', category: 'Fertilizers', priceInr: 520, mrpInr: 620, rating: 4.4, reviewCount: 134),
  AgriProduct(id: 'f37', name: 'City Compost ISO-marked (50 kg)', brand: 'EcoFarm', category: 'Fertilizers', priceInr: 240, mrpInr: 290, rating: 4.3, reviewCount: 89),
  AgriProduct(id: 'f38', name: 'Liquid Seaweed Extract 0.5% (1 L)', brand: 'PI Industries', category: 'Fertilizers', priceInr: 410, mrpInr: 480, rating: 4.6, reviewCount: 223),
  AgriProduct(id: 'f39', name: 'Potassium Magnesium Sulphate SOP-Mg (25 kg)', brand: 'NutriField', category: 'Fertilizers', priceInr: 1520, mrpInr: 1750, rating: 4.2, reviewCount: 61),
  AgriProduct(id: 'f40', name: 'Amino Acid Blend 40% (500 g)', brand: 'GrowMore', category: 'Fertilizers', priceInr: 310, mrpInr: 380, rating: 4.4, reviewCount: 144),
  AgriProduct(id: 'f41', name: 'Water Soluble MAP 12-61-0 (25 kg)', brand: 'IFFCO', category: 'Fertilizers', priceInr: 2180, mrpInr: 2480, rating: 4.5, reviewCount: 167),
  AgriProduct(id: 'f42', name: 'Granulated Lime / Liming material (50 kg)', brand: 'GrowMore', category: 'Fertilizers', priceInr: 420, mrpInr: 480, rating: 4.1, reviewCount: 52),
  AgriProduct(id: 'f43', name: 'Fe + Zn + B Micromix foliar (250 g)', brand: 'Multiplex', category: 'Fertilizers', priceInr: 165, mrpInr: 200, rating: 4.3, reviewCount: 201),
  AgriProduct(id: 'f44', name: 'Potash derived molasses-based (40 kg)', brand: 'OrganicEarth', category: 'Fertilizers', priceInr: 780, mrpInr: 900, rating: 4.2, reviewCount: 73),
  AgriProduct(id: 'f45', name: 'Slow-release Urea coated (45 kg)', brand: 'NutriField', category: 'Fertilizers', priceInr: 1180, mrpInr: 1320, rating: 4.4, reviewCount: 91),

  // —— Pesticides ——
  AgriProduct(id: 'p1', name: 'Imidacloprid 17.8% SL (250 ml)', brand: 'CropShield', category: 'Pesticides', priceInr: 310, mrpInr: 380, rating: 4.3, reviewCount: 201),
  AgriProduct(id: 'p2', name: 'Chlorpyrifos 20% EC (1 L)', brand: 'CropShield', category: 'Pesticides', priceInr: 520, mrpInr: 610, rating: 4.1, reviewCount: 134),
  AgriProduct(id: 'p3', name: 'Glyphosate 41% SL (1 L)', brand: 'WeedOff', category: 'Pesticides', priceInr: 480, mrpInr: 560, rating: 4.2, reviewCount: 312),
  AgriProduct(id: 'p4', name: 'Mancozeb 75% WP (500 g)', brand: 'FungiCare', category: 'Pesticides', priceInr: 290, mrpInr: 340, rating: 4.4, reviewCount: 178),
  AgriProduct(id: 'p5', name: 'Propiconazole 25% EC (500 ml)', brand: 'FungiCare', category: 'Pesticides', priceInr: 640, mrpInr: 740, rating: 4.5, reviewCount: 156),
  AgriProduct(id: 'p6', name: 'Neem Oil 1500 ppm (500 ml)', brand: 'NaturalGuard', category: 'Pesticides', priceInr: 195, mrpInr: 240, rating: 4.6, reviewCount: 421),
  AgriProduct(id: 'p7', name: 'Yellow Sticky Traps (10 pack)', brand: 'IPM Tools', category: 'Pesticides', priceInr: 220, mrpInr: 280, rating: 4.4, reviewCount: 267),
  AgriProduct(id: 'p8', name: 'Lambda Cyhalothrin 5% EC (250 ml)', brand: 'CropShield', category: 'Pesticides', priceInr: 340, mrpInr: 400, rating: 4.2, reviewCount: 89),
  AgriProduct(id: 'p9', name: 'Cartap Hydrochloride 4G (4 kg)', brand: 'CropShield', category: 'Pesticides', priceInr: 890, mrpInr: 1020, rating: 4.1, reviewCount: 112),
  AgriProduct(id: 'p10', name: 'Metribuzin 70% WP (500 g)', brand: 'WeedOff', category: 'Pesticides', priceInr: 410, mrpInr: 480, rating: 4.0, reviewCount: 67),
  AgriProduct(id: 'p11', name: 'Copper Oxychloride 50% WP (1 kg)', brand: 'FungiCare', category: 'Pesticides', priceInr: 360, mrpInr: 420, rating: 4.3, reviewCount: 94),
  AgriProduct(id: 'p12', name: 'Trichoderma Biofungicide (1 kg)', brand: 'BioAgri', category: 'Pesticides', priceInr: 280, mrpInr: 330, rating: 4.5, reviewCount: 143),
  AgriProduct(id: 'p13', name: 'Acephate 75% SP (1 kg)', brand: 'CropShield', category: 'Pesticides', priceInr: 520, mrpInr: 600, rating: 4.0, reviewCount: 58),
  AgriProduct(id: 'p14', name: 'Emamectin Benzoate 5% SG (100 g)', brand: 'CropShield', category: 'Pesticides', priceInr: 180, mrpInr: 220, rating: 4.4, reviewCount: 176),
  AgriProduct(id: 'p15', name: 'Spray adjuvant / sticker (250 ml)', brand: 'IPM Tools', category: 'Pesticides', priceInr: 145, mrpInr: 175, rating: 4.2, reviewCount: 91),
  AgriProduct(id: 'p16', name: 'Bacillus thuringiensis 5% WP (500 g)', brand: 'BioAgri', category: 'Pesticides', priceInr: 260, mrpInr: 300, rating: 4.4, reviewCount: 122),
  AgriProduct(id: 'p17', name: 'Spinosad 45% SC (100 ml)', brand: 'CropShield', category: 'Pesticides', priceInr: 310, mrpInr: 360, rating: 4.3, reviewCount: 84),
  AgriProduct(id: 'p18', name: 'Metalaxyl + Mancozeb 72% WP (500 g)', brand: 'FungiCare', category: 'Pesticides', priceInr: 480, mrpInr: 550, rating: 4.2, reviewCount: 73),
  AgriProduct(id: 'p19', name: 'Chlorantraniliprole 18.5% SC (150 ml)', brand: 'CropShield', category: 'Pesticides', priceInr: 890, mrpInr: 1020, rating: 4.5, reviewCount: 201),
  AgriProduct(id: 'p20', name: 'Sulphur 80% WP (1 kg)', brand: 'FungiCare', category: 'Pesticides', priceInr: 220, mrpInr: 260, rating: 4.1, reviewCount: 49),
  AgriProduct(id: 'p21', name: 'Abamectin 1.8% EC (250 ml)', brand: 'CropShield', category: 'Pesticides', priceInr: 410, mrpInr: 480, rating: 4.2, reviewCount: 76),
  AgriProduct(id: 'p22', name: 'Fipronil 5% SC (250 ml)', brand: 'CropShield', category: 'Pesticides', priceInr: 520, mrpInr: 610, rating: 4.3, reviewCount: 112),
  AgriProduct(id: 'p23', name: 'Buprofezin 25% SC (500 ml)', brand: 'CropShield', category: 'Pesticides', priceInr: 380, mrpInr: 440, rating: 4.1, reviewCount: 58),
  AgriProduct(id: 'p24', name: 'Pymetrozine 50% WG (120 g)', brand: 'CropShield', category: 'Pesticides', priceInr: 290, mrpInr: 340, rating: 4.2, reviewCount: 84),
  AgriProduct(id: 'p25', name: 'Diafenthiuron 50% WP (500 g)', brand: 'CropShield', category: 'Pesticides', priceInr: 640, mrpInr: 740, rating: 4.0, reviewCount: 47),
  AgriProduct(id: 'p26', name: 'Flubendiamide 20% WG (100 g)', brand: 'CropShield', category: 'Pesticides', priceInr: 720, mrpInr: 840, rating: 4.5, reviewCount: 156),
  AgriProduct(id: 'p27', name: 'Chlorfenapyr 10% SC (250 ml)', brand: 'CropShield', category: 'Pesticides', priceInr: 890, mrpInr: 1020, rating: 4.2, reviewCount: 63),
  AgriProduct(id: 'p28', name: 'Metarhizium bioinsecticide (1 kg)', brand: 'BioAgri', category: 'Pesticides', priceInr: 310, mrpInr: 360, rating: 4.4, reviewCount: 92),
  AgriProduct(id: 'p29', name: 'Beauveria bassiana 1.15% WP (1 kg)', brand: 'BioAgri', category: 'Pesticides', priceInr: 340, mrpInr: 390, rating: 4.3, reviewCount: 71),
  AgriProduct(id: 'p30', name: 'Herbicide 2,4-D amine salt 58% SL (1 L)', brand: 'WeedOff', category: 'Pesticides', priceInr: 260, mrpInr: 300, rating: 4.0, reviewCount: 112),
  AgriProduct(id: 'p31', name: 'Pendimethalin 30% EC (1 L)', brand: 'WeedOff', category: 'Pesticides', priceInr: 480, mrpInr: 550, rating: 4.1, reviewCount: 88),
  AgriProduct(id: 'p32', name: 'Quizalofop-p-ethyl 5% EC (400 ml)', brand: 'WeedOff', category: 'Pesticides', priceInr: 360, mrpInr: 420, rating: 4.2, reviewCount: 64),
  AgriProduct(id: 'p33', name: 'Blue sticky trap sheets (15 pack)', brand: 'IPM Tools', category: 'Pesticides', priceInr: 260, mrpInr: 310, rating: 4.3, reviewCount: 144),
  AgriProduct(id: 'p34', name: 'Pheromone lure funnel trap kit', brand: 'IPM Tools', category: 'Pesticides', priceInr: 420, mrpInr: 500, rating: 4.4, reviewCount: 98),

  // —— Tools & field equipment ——
  AgriProduct(id: 't1', name: 'Knapsack sprayer 16 L brass lance', brand: 'FieldPro', category: 'Tools', priceInr: 1850, mrpInr: 2180, rating: 4.4, reviewCount: 312),
  AgriProduct(id: 't2', name: 'Battery sprayer 12L 12V', brand: 'FieldPro', category: 'Tools', priceInr: 4200, mrpInr: 4890, rating: 4.5, reviewCount: 167),
  AgriProduct(id: 't3', name: 'Drip irrigation starter kit 100 m', brand: 'AquaDrip', category: 'Tools', priceInr: 3200, mrpInr: 3650, rating: 4.6, reviewCount: 201),
  AgriProduct(id: 't4', name: 'LDPE mulching sheet 400 gauge 1.2m x 400m', brand: 'MulchMat', category: 'Tools', priceInr: 5400, mrpInr: 6200, rating: 4.3, reviewCount: 89),
  AgriProduct(id: 't5', name: 'Garden hand trowel + fork set', brand: 'FieldPro', category: 'Tools', priceInr: 320, mrpInr: 390, rating: 4.2, reviewCount: 256),
  AgriProduct(id: 't6', name: 'Bypass pruning secateurs 8 inch', brand: 'FieldPro', category: 'Tools', priceInr: 680, mrpInr: 780, rating: 4.5, reviewCount: 178),
  AgriProduct(id: 't7', name: 'Wheelbarrow 65 L pneumatic tyre', brand: 'BuildAgri', category: 'Tools', priceInr: 2650, mrpInr: 2990, rating: 4.1, reviewCount: 94),
  AgriProduct(id: 't8', name: 'Measuring cylinder 1000 ml poly', brand: 'LabFarm', category: 'Tools', priceInr: 145, mrpInr: 175, rating: 4.3, reviewCount: 112),
  AgriProduct(id: 't9', name: 'Soil pH & moisture combo meter', brand: 'LabFarm', category: 'Tools', priceInr: 890, mrpInr: 1050, rating: 4.0, reviewCount: 201),
  AgriProduct(id: 't10', name: 'Rain gun 1.5 inch metal', brand: 'AquaDrip', category: 'Tools', priceInr: 1180, mrpInr: 1350, rating: 4.4, reviewCount: 76),
  AgriProduct(id: 't11', name: 'PVC lay-flat hose 3 inch 30m', brand: 'AquaDrip', category: 'Tools', priceInr: 2100, mrpInr: 2420, rating: 4.2, reviewCount: 58),
  AgriProduct(id: 't12', name: 'Shade net 50% 4m x 10m green', brand: 'MulchMat', category: 'Tools', priceInr: 1680, mrpInr: 1920, rating: 4.3, reviewCount: 134),
  AgriProduct(id: 't13', name: 'Coconut coir pith bale 5 kg', brand: 'EcoFarm', category: 'Tools', priceInr: 180, mrpInr: 220, rating: 4.5, reviewCount: 412),
  AgriProduct(id: 't14', name: 'Weed slasher / sickle heavy duty', brand: 'FieldPro', category: 'Tools', priceInr: 240, mrpInr: 290, rating: 4.2, reviewCount: 189),
  AgriProduct(id: 't15', name: 'Harvesting sickle set (3 pcs)', brand: 'FieldPro', category: 'Tools', priceInr: 420, mrpInr: 490, rating: 4.3, reviewCount: 97),
  AgriProduct(id: 't16', name: 'Plastic field crate 20 kg (stackable)', brand: 'BuildAgri', category: 'Tools', priceInr: 185, mrpInr: 220, rating: 4.1, reviewCount: 223),
  AgriProduct(id: 't17', name: 'Sprinkler impact type brass', brand: 'AquaDrip', category: 'Tools', priceInr: 520, mrpInr: 610, rating: 4.4, reviewCount: 145),
  AgriProduct(id: 't18', name: 'Hand rotary weeder 3 tine', brand: 'FieldPro', category: 'Tools', priceInr: 1180, mrpInr: 1350, rating: 4.2, reviewCount: 67),
];
