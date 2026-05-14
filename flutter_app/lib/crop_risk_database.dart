/// Maps each crop to the set of insect names known to be harmful to it.
/// Matching is case-insensitive and uses substring matching so labels like
/// "fall armyworm" still match a database entry for "armyworm".
class CropRiskDatabase {
  static const Map<String, List<String>> _harmful = {
    'rice': [
      'brown planthopper',
      'leaf folder',
      'stem borer',
      'rice bug',
      'grasshopper',
      'aphid',
    ],
    'maize': [
      'fall armyworm',
      'stem borer',
      'cutworm',
      'aphid',
      'grasshopper',
    ],
    'wheat': ['aphid', 'armyworm', 'termite', 'grasshopper'],
    'potato': [
      'potato tuber moth',
      'aphid',
      'whitefly',
      'cutworm',
      'beetle',
    ],
    'tomato': [
      'whitefly',
      'aphid',
      'fruit borer',
      'leaf miner',
      'thrips',
      'caterpillar',
    ],
    'mustard': ['aphid', 'sawfly', 'painted bug', 'leaf miner'],
    'sugarcane': [
      'early shoot borer',
      'top borer',
      'termite',
      'whitefly',
      'scale insect',
    ],
    'cotton': ['bollworm', 'whitefly', 'aphid', 'jassid', 'thrips'],
  };

  bool isHarmful(String insect, String crop) {
    final i = insect.toLowerCase().trim();
    final c = crop.toLowerCase().trim();
    final list = _harmful[c];
    if (list == null || i.isEmpty) return false;
    for (final h in list) {
      if (i.contains(h) || h.contains(i)) return true;
    }
    return false;
  }

  String getAdvice(String insect, String crop, bool harmful) {
    if (!harmful) {
      return 'This insect is not listed as a major harmful pest for $crop. '
          'Still monitor the field regularly.';
    }
    return 'This insect may damage $crop. Recommended action: inspect nearby '
        'plants, check infestation level, remove heavily affected leaves if '
        'possible, and contact an agriculture expert before using pesticide.';
  }
}
