/// Curated agricultural stock photos via Wikimedia Commons `Special:FilePath`
/// (stable redirects to the current image file).
///
/// Resolution order: admin URL override → product-name keywords → **stable
/// per-product image** from a category pool (by [productId]) → category default.
library agri_product_stock_images;

String _fp(String fileName) =>
    'https://commons.wikimedia.org/wiki/Special:FilePath/${Uri.encodeComponent(fileName)}';

int _stableIndex(String id, int modulo) {
  if (modulo <= 0) return 0;
  var h = 5381;
  for (final u in id.codeUnits) {
    h = ((h << 5) + h) + u;
  }
  return h.abs() % modulo;
}

// --- Category fallbacks (single “neutral” image per aisle) ---

final String _kFallbackSeeds = _fp('Wheat-grain.jpg');
final String _kFallbackFertilizers = _fp('Fertilizer.jpg');
final String _kFallbackPesticides = _fp('Pesticide_application.jpg');
final String _kFallbackTools = _fp('Knapsack_sprayer.jpg');

/// Distinct Commons files per aisle — indexed by [productId] so neighbours in
/// the catalogue do not all share one repeated photo when keyword match misses.
const List<String> _kSeedPool = [
  'Rice_p1160004_cropped.jpg',
  'Wheat-grain.jpg',
  'Corn_field_2007.jpg',
  'Pennisetum_glaucum_plant.jpg',
  'Setaria_italica_001.JPG',
  'Green_beans.jpg',
  'Green_grams.jpg',
  'Vigna_mungo_plant.jpg',
  'Lentils.jpg',
  'Chickpea_seeds.jpg',
  'Bitter_gourds.jpg',
  'Lagenaria_siceraria_002.JPG',
  'Cucumis_sativus_var_sativus.jpg',
  'YamsatBrixtonMarket.jpg',
  'Colocasia_esculenta_001.JPG',
  'Medicago_sativa_plant.jpg',
  'Bananas_on_Tree_9.jpg',
  'Punica_granatum_fruit.jpg',
  'Mustard_plant_-_Brassica_nigra.jpg',
  'Cotton_plant.jpg',
  'Saccharum_officinarum_-_Koepchen_-_01.jpg',
  'Patates.jpg',
  'Bright_red_tomato_and_cross_section02.jpg',
  'Glycine_max_001.JPG',
  'Sunflower_sky_backdrop.jpg',
  'Onions.jpg',
  'Abelmoschus_esculentus_001.JPG',
  'Capsicum_annuum_fruit.jpg',
  'Cabbage_collard.jpg',
  'Daucus_carota_005.JPG',
  'Watermelon_cross_BNC.jpg',
  'Aubergine.jpg',
  'Coriandrum_sativum_002.JPG',
  'Trigonella_foenum-graecum_001.JPG',
  'Arachis_hypogaea_002.JPG',
  'Ricinus_communis_001.JPG',
  'Sesamum_indicum_002.JPG',
  'Sorghum_bicolor_003.JPG',
  'Turmeric.jpg',
  'Zingiber_officinale_001.JPG',
  'Drumstick_vegetable.jpg',
  'Eleusine_coracana_002.JPG',
];

const List<String> _kFertilizerPool = [
  'Urea.jpg',
  'Diammonium_phosphate.jpg',
  'Potassium_chloride.jpg',
  'Zinc_sulfate.jpg',
  'Borax_crystals.jpg',
  'Gypsum_crystals.jpg',
  'Agricultural_lime.jpg',
  'Magnesium_sulfate_heptahydrate.jpg',
  'Worm_compost_bedding.jpg',
  'Seaweed_farm.jpg',
  'Sulfur_sample.jpg',
  'Fertilizer.jpg',
  'Rice_p1160004_cropped.jpg',
  'Corn_field_2007.jpg',
  'Patates.jpg',
  'Bright_red_tomato_and_cross_section02.jpg',
  'Cabbage_collard.jpg',
  'Onions.jpg',
  'Saccharum_officinarum_-_Koepchen_-_01.jpg',
  'Cotton_plant.jpg',
  'Medicago_sativa_plant.jpg',
  'Punica_granatum_fruit.jpg',
];

const List<String> _kPesticidePool = [
  'Pesticide_application.jpg',
  'Neem_leaves.jpg',
  'Knapsack_sprayer.jpg',
  'Capsicum_annuum_fruit.jpg',
  'Cabbage_collard.jpg',
  'Corn_field_2007.jpg',
  'Cotton_plant.jpg',
  'Patates.jpg',
  'Bright_red_tomato_and_cross_section02.jpg',
  'Rice_p1160004_cropped.jpg',
  'Mustard_plant_-_Brassica_nigra.jpg',
  'Saccharum_officinarum_-_Koepchen_-_01.jpg',
  'Glycine_max_001.JPG',
  'Sunflower_sky_backdrop.jpg',
  'Watermelon_cross_BNC.jpg',
];

const List<String> _kToolsPool = [
  'Knapsack_sprayer.jpg',
  'Drip_irrigation_system.JPG',
  'Wheelbarrow.jpg',
  'Pruning_shears.jpg',
  'Graduated_cylinder.jpg',
  'Coconut.jpg',
  'Corn_field_2007.jpg',
  'Patates.jpg',
  'Cabbage_collard.jpg',
  'Daucus_carota_005.JPG',
  'Watermelon_cross_BNC.jpg',
  'Onions.jpg',
  'Bananas_on_Tree_9.jpg',
  'Punica_granatum_fruit.jpg',
  'Saccharum_officinarum_-_Koepchen_-_01.jpg',
];

List<String> _poolForCategory(String category) {
  return switch (category) {
    'Seeds' => _kSeedPool,
    'Fertilizers' => _kFertilizerPool,
    'Pesticides' => _kPesticidePool,
    'Tools' => _kToolsPool,
    _ => _kSeedPool,
  };
}

String _fallbackCategory(String category) {
  return switch (category) {
    'Seeds' => _kFallbackSeeds,
    'Fertilizers' => _kFallbackFertilizers,
    'Pesticides' => _kFallbackPesticides,
    'Tools' => _kFallbackTools,
    _ => _kFallbackSeeds,
  };
}

/// (lowercase keyword substring, commons file name)
final List<(String, String)> _kKeywordImages = [
  ('finger millet', 'Eleusine_coracana_002.JPG'),
  ('pearl millet', 'Pennisetum_glaucum_plant.jpg'),
  ('foxtail millet', 'Setaria_italica_001.JPG'),
  ('bajra', 'Pennisetum_glaucum_plant.jpg'),
  ('sweet corn', 'Corn_field_2007.jpg'),
  ('french beans', 'Green_beans.jpg'),
  ('green gram', 'Green_grams.jpg'),
  ('black gram', 'Vigna_mungo_plant.jpg'),
  ('red lentil', 'Lentils.jpg'),
  ('chickpea', 'Chickpea_seeds.jpg'),
  ('bitter gourd', 'Bitter_gourds.jpg'),
  ('bottle gourd', 'Lagenaria_siceraria_002.JPG'),
  ('ridge gourd', 'Cucumis_sativus_var_sativus.jpg'),
  ('elephant foot yam', 'YamsatBrixtonMarket.jpg'),
  ('colocasia', 'Colocasia_esculenta_001.JPG'),
  ('hybrid napier', 'Saccharum_officinarum_-_Koepchen_-_01.jpg'),
  ('rhodes grass', 'Medicago_sativa_plant.jpg'),
  ('lucerne', 'Medicago_sativa_plant.jpg'),
  ('alfalfa', 'Medicago_sativa_plant.jpg'),
  ('tissue culture', 'Bananas_on_Tree_9.jpg'),
  ('basmati', 'Rice_p1160004_cropped.jpg'),
  ('paddy', 'Rice_p1160004_cropped.jpg'),
  ('hybrid paddy', 'Rice_p1160004_cropped.jpg'),
  ('rice', 'Rice_p1160004_cropped.jpg'),
  ('wheat', 'Wheat-grain.jpg'),
  ('maize', 'Corn_field_2007.jpg'),
  ('banana', 'Bananas_on_Tree_9.jpg'),
  ('pomegranate', 'Punica_granatum_fruit.jpg'),
  ('mustard', 'Mustard_plant_-_Brassica_nigra.jpg'),
  ('cotton', 'Cotton_plant.jpg'),
  ('sugarcane', 'Saccharum_officinarum_-_Koepchen_-_01.jpg'),
  ('potato', 'Patates.jpg'),
  ('tomato', 'Bright_red_tomato_and_cross_section02.jpg'),
  ('soybean', 'Glycine_max_001.JPG'),
  ('sunflower', 'Sunflower_sky_backdrop.jpg'),
  ('onion', 'Onions.jpg'),
  ('okra', 'Abelmoschus_esculentus_001.JPG'),
  ('chilli', 'Capsicum_annuum_fruit.jpg'),
  ('cabbage', 'Cabbage_collard.jpg'),
  ('carrot', 'Daucus_carota_005.JPG'),
  ('cucumber', 'Cucumis_sativus_var_sativus.jpg'),
  ('watermelon', 'Watermelon_cross_BNC.jpg'),
  ('brinjal', 'Aubergine.jpg'),
  ('coriander', 'Coriandrum_sativum_002.JPG'),
  ('fenugreek', 'Trigonella_foenum-graecum_001.JPG'),
  ('groundnut', 'Arachis_hypogaea_002.JPG'),
  ('castor', 'Ricinus_communis_001.JPG'),
  ('sesame', 'Sesamum_indicum_002.JPG'),
  ('jowar', 'Sorghum_bicolor_003.JPG'),
  ('turmeric', 'Turmeric.jpg'),
  ('ginger', 'Zingiber_officinale_001.JPG'),
  ('drumstick', 'Drumstick_vegetable.jpg'),
  ('sapling', 'Punica_granatum_fruit.jpg'),
  ('setts', 'Saccharum_officinarum_-_Koepchen_-_01.jpg'),
  ('kufri', 'Patates.jpg'),
  ('vermicompost', 'Worm_compost_bedding.jpg'),
  ('compost', 'Worm_compost_bedding.jpg'),
  ('fym', 'Worm_compost_bedding.jpg'),
  ('manure', 'Worm_compost_bedding.jpg'),
  ('city compost', 'Worm_compost_bedding.jpg'),
  ('organic manure', 'Worm_compost_bedding.jpg'),
  ('urea', 'Urea.jpg'),
  ('dap', 'Diammonium_phosphate.jpg'),
  ('iffco', 'Diammonium_phosphate.jpg'),
  ('yara', 'Fertilizer.jpg'),
  ('npk', 'Fertilizer.jpg'),
  ('water soluble', 'Fertilizer.jpg'),
  ('potash', 'Potassium_chloride.jpg'),
  ('mop', 'Potassium_chloride.jpg'),
  ('schoenite', 'Potassium_chloride.jpg'),
  ('potassium nitrate', 'Potassium_chloride.jpg'),
  ('potassium magnesium', 'Potassium_chloride.jpg'),
  ('zinc', 'Zinc_sulfate.jpg'),
  ('coromandel', 'Zinc_sulfate.jpg'),
  ('multiplex', 'Zinc_sulfate.jpg'),
  ('borax', 'Borax_crystals.jpg'),
  ('boron', 'Borax_crystals.jpg'),
  ('gypsum', 'Gypsum_crystals.jpg'),
  ('lime', 'Agricultural_lime.jpg'),
  ('liming', 'Agricultural_lime.jpg'),
  ('sulphur', 'Sulfur_sample.jpg'),
  ('sulfur', 'Sulfur_sample.jpg'),
  ('seaweed', 'Seaweed_farm.jpg'),
  ('humic', 'Gypsum_crystals.jpg'),
  ('amino acid', 'Worm_compost_bedding.jpg'),
  ('biofertilizer', 'Worm_compost_bedding.jpg'),
  ('rhizobium', 'Worm_compost_bedding.jpg'),
  ('azotobacter', 'Worm_compost_bedding.jpg'),
  ('bio npk', 'Worm_compost_bedding.jpg'),
  ('consortium', 'Worm_compost_bedding.jpg'),
  ('epsom', 'Magnesium_sulfate_heptahydrate.jpg'),
  ('magnesium sulphate', 'Magnesium_sulfate_heptahydrate.jpg'),
  ('chelate', 'Zinc_sulfate.jpg'),
  ('iron', 'Zinc_sulfate.jpg'),
  ('edta', 'Zinc_sulfate.jpg'),
  ('ammonium sulphate', 'Urea.jpg'),
  ('ammonium sulfate', 'Urea.jpg'),
  ('calcium ammonium nitrate', 'Urea.jpg'),
  ('calcium nitrate', 'Gypsum_crystals.jpg'),
  ('ssp', 'Diammonium_phosphate.jpg'),
  ('superphosphate', 'Diammonium_phosphate.jpg'),
  ('12-61-0', 'Diammonium_phosphate.jpg'),
  ('silicon', 'Gypsum_crystals.jpg'),
  ('manganese', 'Zinc_sulfate.jpg'),
  ('copper sulphate', 'Zinc_sulfate.jpg'),
  ('copper sulfate', 'Zinc_sulfate.jpg'),
  ('molybdate', 'Borax_crystals.jpg'),
  ('bentonite', 'Gypsum_crystals.jpg'),
  ('prom (', 'Diammonium_phosphate.jpg'),
  ('pi industries', 'Seaweed_farm.jpg'),
  ('glyphosate', 'Pesticide_application.jpg'),
  ('imidacloprid', 'Pesticide_application.jpg'),
  ('chlorpyrifos', 'Pesticide_application.jpg'),
  ('lambda', 'Pesticide_application.jpg'),
  ('cartap', 'Pesticide_application.jpg'),
  ('metribuzin', 'Pesticide_application.jpg'),
  ('mancozeb', 'Pesticide_application.jpg'),
  ('propiconazole', 'Pesticide_application.jpg'),
  ('copper oxychloride', 'Pesticide_application.jpg'),
  ('acephate', 'Pesticide_application.jpg'),
  ('emamectin', 'Pesticide_application.jpg'),
  ('spinosad', 'Pesticide_application.jpg'),
  ('metalaxyl', 'Pesticide_application.jpg'),
  ('chlorantraniliprole', 'Pesticide_application.jpg'),
  ('fipronil', 'Pesticide_application.jpg'),
  ('buprofezin', 'Pesticide_application.jpg'),
  ('pymetrozine', 'Pesticide_application.jpg'),
  ('diafenthiuron', 'Pesticide_application.jpg'),
  ('flubendiamide', 'Pesticide_application.jpg'),
  ('chlorfenapyr', 'Pesticide_application.jpg'),
  ('abamectin', 'Pesticide_application.jpg'),
  ('2,4-d', 'Pesticide_application.jpg'),
  ('pendimethalin', 'Pesticide_application.jpg'),
  ('quizalofop', 'Pesticide_application.jpg'),
  ('neem', 'Neem_leaves.jpg'),
  ('sticky trap', 'Neem_leaves.jpg'),
  ('pheromone', 'Neem_leaves.jpg'),
  ('herbicide', 'Pesticide_application.jpg'),
  ('fungicide', 'Pesticide_application.jpg'),
  ('biofungicide', 'Neem_leaves.jpg'),
  ('trichoderma', 'Neem_leaves.jpg'),
  ('metarhizium', 'Neem_leaves.jpg'),
  ('beauveria', 'Neem_leaves.jpg'),
  ('bacillus thuringiensis', 'Neem_leaves.jpg'),
  ('sprayer', 'Knapsack_sprayer.jpg'),
  ('drip', 'Drip_irrigation_system.JPG'),
  ('mulch', 'Corn_field_2007.jpg'),
  ('mulching', 'Corn_field_2007.jpg'),
  ('wheelbarrow', 'Wheelbarrow.jpg'),
  ('hose', 'Drip_irrigation_system.JPG'),
  ('rain gun', 'Drip_irrigation_system.JPG'),
  ('shade net', 'Corn_field_2007.jpg'),
  ('coir', 'Coconut.jpg'),
  ('sickle', 'Pruning_shears.jpg'),
  ('secateur', 'Pruning_shears.jpg'),
  ('pruning', 'Pruning_shears.jpg'),
  ('trowel', 'Knapsack_sprayer.jpg'),
  ('crate', 'Wheelbarrow.jpg'),
  ('sprinkler', 'Drip_irrigation_system.JPG'),
  ('weeder', 'Pruning_shears.jpg'),
  ('ph ', 'Graduated_cylinder.jpg'),
  ('soil', 'Graduated_cylinder.jpg'),
  ('cylinder', 'Graduated_cylinder.jpg'),
];

/// Admin image URL wins; then product-name keywords; then stable per-[productId]
/// image from a category pool; then a single category fallback.
String resolveAgriProductStockImage({
  required String productName,
  required String category,
  String? imageUrlOverride,
  String? productId,
}) {
  final trimmed = imageUrlOverride?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    return trimmed;
  }
  final n = productName.toLowerCase();
  for (final entry in _kKeywordImages) {
    if (n.contains(entry.$1)) return _fp(entry.$2);
  }
  final pid = productId?.trim();
  if (pid != null && pid.isNotEmpty) {
    final pool = _poolForCategory(category);
    final file = pool[_stableIndex(pid, pool.length)];
    return _fp(file);
  }
  return _fallbackCategory(category);
}
