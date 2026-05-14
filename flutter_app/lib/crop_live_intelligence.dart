/// Curated agronomic guidance for the live scan UI (offline-first, IPM-oriented).
/// Pair with [CropRiskDatabase] for pest lists; this layer adds disease context,
/// prevention, treatment framing, and general recommendations.
library crop_live_intelligence;

class LiveScanInsightBundle {
  const LiveScanInsightBundle({
    required this.insectRiskSummary,
    required this.diseaseRisks,
    required this.preventionSteps,
    required this.treatmentNotes,
    required this.recommendations,
  });

  final String insectRiskSummary;
  final List<String> diseaseRisks;
  final List<String> preventionSteps;
  final List<String> treatmentNotes;
  final List<String> recommendations;
}

class CropLiveIntelligence {
  CropLiveIntelligence._();

  static LiveScanInsightBundle build({
    required String crop,
    required String insectLabel,
    required bool plausibleFrame,
    required bool modelReady,
    required bool harmfulInsect,
    required bool isDemo,
    required double confidence,
  }) {
    final c = crop.trim();
    final insect = insectLabel.trim();
    final diseases = _diseasesForCrop(c);
    final prevention = _preventionFor(c, harmfulInsect, plausibleFrame);
    final treatment = _treatmentFor(c, harmfulInsect);
    final recs = _recommendationsFor(c);
    final insectSummary = _insectNarrative(
      crop: c,
      insect: insect,
      plausible: plausibleFrame,
      modelReady: modelReady,
      harmful: harmfulInsect,
      isDemo: isDemo,
      confidence: confidence,
    );
    return LiveScanInsightBundle(
      insectRiskSummary: insectSummary,
      diseaseRisks: diseases,
      preventionSteps: prevention,
      treatmentNotes: treatment,
      recommendations: recs,
    );
  }

  static String _insectNarrative({
    required String crop,
    required String insect,
    required bool plausible,
    required bool modelReady,
    required bool harmful,
    required bool isDemo,
    required double confidence,
  }) {
    if (!modelReady) {
      return 'Insect model is not loaded. Add a trained TFLite model to enable species-level risk.';
    }
    if (!plausible) {
      return 'Frame does not look like crop foliage or a clear insect close-up. '
          'Aim at leaves, fruit, or the pest itself so risk scoring is meaningful.';
    }
    final demoTag = isDemo ? ' (demo estimate — not a trained classifier)' : '';
    if (harmful) {
      return '$insect$demoTag is on the watch list for $crop. Treat as a potential pest '
          'if infestation is confirmed in the field (confidence ${(confidence * 100).toStringAsFixed(0)}%).';
    }
    if (insect.toLowerCase().contains('no clear')) {
      return 'No stable insect label for this frame. Keep scanning or move closer to the target.';
    }
    return '$insect$demoTag is not in the app’s short list of major pests for $crop. '
        'Still scout regularly — secondary pests and misclassifications happen.';
  }

  static List<String> _diseasesForCrop(String crop) {
    switch (crop.toLowerCase()) {
      case 'rice':
        return const [
          'Blast (Magnaporthe) — leaf & neck phases; favours dew, split N doses.',
          'Bacterial leaf blight (Xanthomonas) — warm humid nights, wounded leaf tips.',
          'Sheath blight (Rhizoctonia) — dense canopies, high humidity.',
          'Brown spot / narrow brown spot — nutrient stress and residue-borne inoculum.',
          'Tungro complex (virus) — vectored by green leafhoppers; stunted orange-yellow leaves.',
        ];
      case 'maize':
        return const [
          'Turcicum leaf blight — cool, wet periods in the whorl stage.',
          'Maydis leaf blight — warm, humid maize belts; residue management matters.',
          'Post-flowering stalk rots (Fusarium / charcoal rot) — drought stress at grain fill.',
          'Downy mildews / rusts — hybrid-dependent; scout lower canopy.',
        ];
      case 'wheat':
        return const [
          'Stripe / leaf / stem rust — wind-borne spores; varietal resistance varies.',
          'Loose smut / flag smut — certified seed & seed treatment reduce risk.',
          'Septoria tritici blotch — prolonged leaf wetness in cool springs.',
          'Karnal bunt — quarantine significance; avoid late irrigation on susceptible types.',
        ];
      case 'potato':
        return const [
          'Late blight (Phytophthora) — cool nights + high RH; destroy cull piles.',
          'Early blight (Alternaria) — senescing leaves, micronutrient stress.',
          'Black scurf / stem canker (Rhizoctonia) — seed-borne; avoid cold wet planting.',
          'PVY / PLRV complexes — aphid-vectored; use clean seed & oil sprays where allowed.',
        ];
      case 'tomato':
        return const [
          'Early blight / Septoria leaf spot — lower canopy wetness.',
          'Late blight — rapid defoliation in cool wet tunnels or monsoon fields.',
          'TYLCV / ToMV complexes — whitefly & mechanical transmission; resistant varieties help.',
          'Bacterial wilt / Ralstonia — soil & water movement; avoid flood irrigation from infested sources.',
        ];
      case 'mustard':
        return const [
          'Alternaria blight — humid flowering canopy.',
          'White rust (Albugo) — cool moist weather on leaves & inflorescences.',
          'Sclerotinia stem rot — tight rotations with host crops increase risk.',
          'Downy mildew — oilseed rape / mustard belts in damp springs.',
        ];
      case 'sugarcane':
        return const [
          'Red rot (Colletotrichum falcatum) — internal stalk reddening; avoid infected setts.',
          'Smuts (whip / grassy) — varietal susceptibility; rogue infected stools.',
          'Ratoon stunting disease (phytoplasma) — leafhopper vectors; hot-water treated setts.',
          'Pokkah boeng — nutritional / environmental stress complex on young leaves.',
        ];
      case 'cotton':
        return const [
          'Bacterial blight (Xanthomonas) — rain splash, overhead irrigation.',
          'Alternaria / Cercospora leaf spots — senescence & potassium stress.',
          'Cotton leaf curl virus — whitefly-mediated; resistant Bt packages still need virus management.',
          'Root rots in heavy soils — drainage & nematode interactions.',
        ];
      default:
        return const [
          'Scout for dominant regional diseases on this crop and verify with local extension.',
        ];
    }
  }

  static List<String> _preventionFor(String crop, bool harmful, bool plausible) {
    final base = <String>[
      'Rotate crops where regulations allow to break pest–disease cycles.',
      'Use certified seed / clean planting material and destroy cull piles.',
      'Calibrate irrigation to reduce leaf wetness duration (disease) while avoiding drought stress.',
      'Keep field records: variety, sowing date, sprays, and weather around symptom onset.',
    ];
    if (!plausible) {
      return [
        'Centre the subject in frame: canopy mid-tier leaves or a single insect in focus.',
        ...base,
      ];
    }
    if (harmful) {
      return [
        'Inspect 5–10 spots along a “W” transect; count pests per plant or per hill.',
        'Encourage natural enemies: avoid broad-spectrum sprays until thresholds are exceeded.',
        'Time sprays to label PHI and respect bee-forage buffers where required.',
        ...base,
      ];
    }
    return [
      'Maintain regular scouting even when the current label is “low risk”.',
      'Sanitize tools and sprayers between blocks to limit virus / bacterial spread.',
      ...base,
    ];
  }

  static List<String> _treatmentFor(String crop, bool harmful) {
    final ipm = <String>[
      'Follow label rates, PPE, re-entry intervals, and PHI for every product.',
      'Prefer targeted modes of action; rotate MOA groups to slow resistance.',
      'Combine chemical control with cultural tactics (spacing, nutrition, drainage).',
    ];
    if (!harmful) {
      return [
        'No automatic pesticide recommendation — confirm pest identity and thresholds first.',
        'If symptoms resemble disease more than insect damage, collect samples for lab ID where available.',
        ...ipm,
      ];
    }
    return [
      'Economic threshold: treat when local extension thresholds for $crop are exceeded, not on a single camera frame.',
      'Start with approved molecules for the detected pest complex on $crop in your region.',
      'Where labels allow, integrate biocontrols (e.g., NPV, Bt-based products, neem) into the programme.',
      ...ipm,
    ];
  }

  static List<String> _recommendationsFor(String crop) {
    return [
      'Cross-check with your state agriculture department / KVK advisory for $crop this season.',
      'Run soil & petiole tests to rule out hidden hunger that mimics biotic stress.',
      'Log GPS-tagged photos in a notebook app — useful if an agronomist reviews remotely.',
      'Enable field hygiene: bund cleaning, balanced N, and timely drainage around $crop.',
      'Pair live scan with the in-app crop disease photo check for leaf lesions.',
    ];
  }
}
