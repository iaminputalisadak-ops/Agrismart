import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Heuristic gate: is this photo plausibly **foliage / crop tissue** (healthy or
/// diseased), as opposed to electronics, faces, vehicles, blank walls, etc.?
///
/// This is **not** a replacement for a trained “plant vs background” classifier;
/// it blocks obvious non-crop uploads before disease TFLite runs. Tighten or
/// replace with an OOD / binary model when you ship one.
class CropDiseaseImageGate {
  CropDiseaseImageGate._();

  /// 0–1 higher = more plant-like (green, yellow crop, brown lesions, some purple).
  static double foliarLikeRatio(img.Image im) {
    final w = im.width;
    final h = im.height;
    if (w == 0 || h == 0) return 0;
    var hit = 0;
    var n = 0;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = im.getPixel(x, y);
        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();
        n++;
        final greenLeaf = g > r + 12 && g > b + 12 && g > 48;
        final yellowCrop =
            r > 95 && g > 78 && b < 120 && r + g > b + 70 && (r - g).abs() < 62;
        final brownTissue = r > 55 &&
            g > 28 &&
            b < 95 &&
            r > g - 25 &&
            r < 220 &&
            (r + g) > b + 40;
        final purpleLesion = r > 50 && b > r + 12 && g < 170 && b > 55;
        if (greenLeaf || yellowCrop || brownTissue || purpleLesion) hit++;
      }
    }
    return hit / n;
  }

  /// High when image looks like blue‑grey screens / office light, low on leaves.
  static double screenBlueBias(img.Image im) {
    final w = im.width;
    final h = im.height;
    if (w == 0 || h == 0) return 0;
    var sumB = 0.0;
    var sumR = 0.0;
    var n = 0;
    for (var y = 0; y < h; y += 2) {
      for (var x = 0; x < w; x += 2) {
        final p = im.getPixel(x, y);
        sumR += p.r;
        sumB += p.b;
        n++;
      }
    }
    final mr = sumR / n;
    final mb = sumB / n;
    return ((mb - mr) / 72).clamp(0.0, 1.0);
  }

  /// Std dev of luminance (detects flat UI / walls vs natural texture).
  static double luminanceStdDev(img.Image im) {
    final vals = <double>[];
    for (var y = 0; y < im.height; y += 2) {
      for (var x = 0; x < im.width; x += 2) {
        final p = im.getPixel(x, y);
        vals.add(0.299 * p.r + 0.587 * p.g + 0.114 * p.b);
      }
    }
    if (vals.isEmpty) return 0;
    final mean = vals.reduce((a, b) => a + b) / vals.length;
    var v = 0.0;
    for (final e in vals) {
      final d = e - mean;
      v += d * d;
    }
    return math.sqrt(v / vals.length);
  }

  /// Rough skin-tone proxy (reject portraits centered on hands/face).
  static double skinLikeRatio(img.Image im) {
    final w = im.width;
    final h = im.height;
    if (w == 0 || h == 0) return 0;
    var hit = 0;
    var n = 0;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = im.getPixel(x, y);
        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();
        n++;
        final skin = r > 95 &&
            g > 40 &&
            b > 20 &&
            r > g &&
            r > b &&
            (r - g) < 95 &&
            (r - b) < 120;
        if (skin) hit++;
      }
    }
    return hit / n;
  }

  /// Returns null if the image passes the crop/plant relevance gate.
  static String? rejectionReason(img.Image rgb) {
    final thumb = img.copyResize(rgb, width: 160, height: 160);
    final foliar = foliarLikeRatio(thumb);
    final blueBias = screenBlueBias(thumb);
    final std = luminanceStdDev(thumb);
    final skin = skinLikeRatio(thumb);

    if (skin > 0.32 && foliar < 0.12) {
      return 'This image does not belong to crop disease detection. '
          'It looks like a person or skin — please photograph affected leaves instead.';
    }
    if (blueBias > 0.58 && foliar < 0.09) {
      return 'This image does not belong to crop disease detection. '
          'It looks like a screen, indoor scene, or object — use a clear outdoor or field photo of plant leaves.';
    }
    if (std < 11 && foliar < 0.06) {
      return 'This image does not belong to crop disease detection. '
          'The scene is too flat or uniform (e.g. walls, plastic, devices). Capture natural leaf detail.';
    }
    if (foliar < 0.038) {
      return 'This image does not belong to crop disease detection. '
          'No plant-like colours or tissue were found — include green, yellow, or brown leaf material in frame.';
    }
    if (foliar < 0.065 && std < 16) {
      return 'This image does not belong to crop disease detection. '
          'Leaf/plant signal is too weak compared with background — move closer to the affected leaf.';
    }
    return null;
  }
}
