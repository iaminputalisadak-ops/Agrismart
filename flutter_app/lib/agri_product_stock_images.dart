/// Curated agricultural stock photos via Wikimedia Commons `Special:FilePath`
/// (stable redirects to the current image file).
library agri_product_stock_images;

String _fp(String fileName) =>
    'https://commons.wikimedia.org/wiki/Special:FilePath/${Uri.encodeComponent(fileName)}';

// --- Category fallbacks ---

final String _kFallbackSeeds = _fp('Wheat-grain.jpg');
final String _kFallbackFertilizers = _fp('Fertilizer.jpg');
final String _kFallbackPesticides = _fp('Pesticide_application.jpg');
final String _kFallbackTools = _fp('Knapsack_sprayer.jpg');

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
  ('rhodes grass', 'Wheat-grain.jpg'),
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
  ('urea', 'Urea.jpg'),
  ('dap', 'Diammonium_phosphate.jpg'),
  ('iffco', 'Diammonium_phosphate.jpg'),
  ('npk', 'Fertilizer.jpg'),
  ('potash', 'Potassium_chloride.jpg'),
  ('mop', 'Potassium_chloride.jpg'),
  ('zinc', 'Zinc_sulfate.jpg'),
  ('borax', 'Borax_crystals.jpg'),
  ('gypsum', 'Gypsum_crystals.jpg'),
  ('lime', 'Agricultural_lime.jpg'),
  ('sulphur', 'Sulfur_sample.jpg'),
  ('seaweed', 'Seaweed_farm.jpg'),
  ('humic', 'Fertilizer.jpg'),
  ('biofertilizer', 'Fertilizer.jpg'),
  ('rhizobium', 'Fertilizer.jpg'),
  ('azotobacter', 'Fertilizer.jpg'),
  ('epsom', 'Magnesium_sulfate_heptahydrate.jpg'),
  ('chelate', 'Fertilizer.jpg'),
  ('glyphosate', 'Pesticide_application.jpg'),
  ('imidacloprid', 'Pesticide_application.jpg'),
  ('chlorpyrifos', 'Pesticide_application.jpg'),
  ('neem', 'Neem_leaves.jpg'),
  ('sticky trap', 'Pesticide_application.jpg'),
  ('pheromone', 'Pesticide_application.jpg'),
  ('herbicide', 'Pesticide_application.jpg'),
  ('fungicide', 'Pesticide_application.jpg'),
  ('biofungicide', 'Neem_leaves.jpg'),
  ('sprayer', 'Knapsack_sprayer.jpg'),
  ('drip', 'Drip_irrigation_system.JPG'),
  ('mulch', 'Corn_field_2007.jpg'),
  ('wheelbarrow', 'Wheelbarrow.jpg'),
  ('hose', 'Drip_irrigation_system.JPG'),
  ('rain gun', 'Drip_irrigation_system.JPG'),
  ('shade net', 'Corn_field_2007.jpg'),
  ('coir', 'Coconut.jpg'),
  ('sickle', 'Knapsack_sprayer.jpg'),
  ('secateur', 'Pruning_shears.jpg'),
  ('pruning', 'Pruning_shears.jpg'),
  ('trowel', 'Knapsack_sprayer.jpg'),
  ('crate', 'Patates.jpg'),
  ('sprinkler', 'Drip_irrigation_system.JPG'),
  ('weeder', 'Knapsack_sprayer.jpg'),
  ('ph ', 'Fertilizer.jpg'),
  ('soil', 'Fertilizer.jpg'),
  ('cylinder', 'Graduated_cylinder.jpg'),
];

String _fallbackCategory(String category) {
  return switch (category) {
    'Seeds' => _kFallbackSeeds,
    'Fertilizers' => _kFallbackFertilizers,
    'Pesticides' => _kFallbackPesticides,
    'Tools' => _kFallbackTools,
    _ => _kFallbackSeeds,
  };
}

/// Admin image URL wins; then product-name keywords; then category stock shot.
String resolveAgriProductStockImage({
  required String productName,
  required String category,
  String? imageUrlOverride,
}) {
  final trimmed = imageUrlOverride?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    return trimmed;
  }
  final n = productName.toLowerCase();
  for (final entry in _kKeywordImages) {
    if (n.contains(entry.$1)) return _fp(entry.$2);
  }
  return _fallbackCategory(category);
}
