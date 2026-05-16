import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Fetches short encyclopaedic context from Wikipedia (no API key).
/// Used as an optional “live web” layer on top of on-device heuristics / models.
class LiveScanWebInsightService {
  LiveScanWebInsightService._();
  static final LiveScanWebInsightService instance = LiveScanWebInsightService._();

  static const _userAgent =
      'AgriSmartLiveScan/1.0 (https://github.com/iaminputalisadak-ops/Agrismart; educational app)';

  String? _lastKey;
  String? _lastExtract;
  DateTime _lastAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Returns a short extract if Wikipedia has a summary for [title].
  /// [title] should be a simple English article title, e.g. "Brown_planthopper".
  Future<String?> fetchSummary(String title) async {
    final t = title.trim();
    if (t.isEmpty) return null;
    final uri = Uri.parse(
      'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(t)}',
    );
    try {
      final res = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final map = jsonDecode(res.body) as Map<String, dynamic>?;
      if (map == null) return null;
      final extract = map['extract'] as String?;
      if (extract == null || extract.trim().isEmpty) return null;
      return extract.trim();
    } catch (e, st) {
      debugPrint('Wikipedia summary fetch failed: $e\n$st');
      return null;
    }
  }

  /// Picks a reasonable page title from crop + optional insect, with throttling.
  Future<String?> fetchInsightForScan({
    required String crop,
    required String insectName,
    required bool plausible,
  }) async {
    if (!plausible) return null;
    final key = '${crop.toLowerCase()}|${insectName.toLowerCase()}';
    if (_lastKey == key &&
        DateTime.now().difference(_lastAt) < const Duration(minutes: 2)) {
      return _lastExtract;
    }
    _lastKey = key;
    _lastAt = DateTime.now();

    String? fromInsect = await _tryInsectArticle(insectName);
    if (fromInsect != null) {
      _lastExtract = fromInsect;
      return fromInsect;
    }
    final cropPage = await fetchSummary('$crop production');
    _lastExtract = cropPage;
    return cropPage;
  }

  Future<String?> _tryInsectArticle(String insect) async {
    final lower = insect.toLowerCase().trim();
    if (lower.isEmpty ||
        lower.contains('no clear') ||
        lower.contains('unknown')) {
      return null;
    }
    final titled = lower
        .split(RegExp(r'\s+'))
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join('_');
    return fetchSummary(titled);
  }

  void clearCache() {
    _lastKey = null;
    _lastExtract = null;
  }
}
