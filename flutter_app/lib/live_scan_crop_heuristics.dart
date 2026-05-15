import 'package:image/image.dart' as img;

/// Colour- and texture-based crop guess for live scan (no extra model).
/// This is a **best-effort field aid** — for reliable crop ID, ship a small
/// `crop_classifier.tflite` and wire it the same way as [InsectClassifier].
class LiveScanCropEstimate {
  const LiveScanCropEstimate({required this.crop, required this.confidence});

  final String crop;
  /// 0–1 where higher means the colour cues agree more strongly.
  final double confidence;
}

class LiveScanCropHeuristics {
  LiveScanCropHeuristics._();

  static const List<String> crops = [
    'Rice',
    'Maize',
    'Wheat',
    'Potato',
    'Tomato',
    'Mustard',
    'Sugarcane',
    'Cotton',
  ];

  /// Picks the most likely crop from a down-scaled RGB frame.
  static LiveScanCropEstimate estimate(img.Image rgb) {
    final im = img.copyResize(rgb, width: 96, height: 96);
    final w = im.width;
    final h = im.height;
    if (w == 0 || h == 0) {
      return const LiveScanCropEstimate(crop: 'Rice', confidence: 0.25);
    }

    var n = 0;
    var green = 0.0;
    var yellow = 0.0;
    var redTom = 0.0;
    var brown = 0.0;
    var bright = 0.0;

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = im.getPixel(x, y);
        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();
        n++;
        final yl = (0.299 * r + 0.587 * g + 0.114 * b);
        if (yl > 175) bright++;

        final greenLeaf = g > r + 14 && g > b + 14 && g > 52;
        final yellowCrop =
            r > 118 && g > 98 && b < 105 && r + g > b + 80 && (r - g).abs() < 55;
        final tomatoRed = r > g + 22 && r > b + 22 && r > 88 && g > 35;
        final soilBrown = r > 55 &&
            g > 35 &&
            b > 18 &&
            (r + g + b) < 420 &&
            (r - g).abs() < 55 &&
            b < r - 5;

        if (greenLeaf) green++;
        if (yellowCrop) yellow++;
        if (tomatoRed) redTom++;
        if (soilBrown) brown++;
      }
    }

    final inv = 1.0 / n;
    green *= inv;
    yellow *= inv;
    redTom *= inv;
    brown *= inv;
    bright *= inv;

    double score(String name) {
      switch (name) {
        case 'Rice':
          return green * 1.25 - yellow * 0.35 + 0.08;
        case 'Maize':
          return yellow * 1.15 + green * 0.55 + brown * 0.12;
        case 'Wheat':
          return yellow * 0.95 + green * 0.45 + brown * 0.22;
        case 'Potato':
          return brown * 0.95 + green * 0.45;
        case 'Tomato':
          return redTom * 1.65 + green * 0.35;
        case 'Mustard':
          return yellow * 1.05 + green * 0.4 + bright * 0.08;
        case 'Sugarcane':
          return green * 1.35 - bright * 0.15 + 0.05;
        case 'Cotton':
          return green * 0.95 + bright * 0.35;
        default:
          return 0;
      }
    }

    final raw = <String, double>{for (final c in crops) c: score(c)};
    final sorted = crops.map((c) => raw[c]!).toList()..sort();
    final bestV = sorted.last;
    final second = sorted.length >= 2 ? sorted[sorted.length - 2] : 0.0;
    final best = crops.reduce((a, b) => (raw[a] ?? 0) >= (raw[b] ?? 0) ? a : b);

    final margin = (bestV - second).clamp(0.0, 10.0);
    final base = (bestV + 0.12).clamp(0.08, 1.2);
    var conf = (margin / base).clamp(0.0, 1.0);
    if (green + yellow + redTom < 0.045) {
      conf *= 0.55;
    }
    conf = conf.clamp(0.22, 0.92);

    return LiveScanCropEstimate(crop: best, confidence: conf);
  }
}
