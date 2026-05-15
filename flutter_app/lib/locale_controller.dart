import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted UI language (English, Hindi, Nepali, Russian).
class LocaleController extends ChangeNotifier {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  static const _prefsKey = 'app_locale_language_code';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('ne'),
    Locale('ru'),
  ];

  Locale _locale = supportedLocales.first;

  Locale get locale => _locale;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = (p.getString(_prefsKey) ?? 'en').toLowerCase();
    _locale = Locale(_normalize(raw));
    notifyListeners();
  }

  String _normalize(String code) {
    if (code.startsWith('hi')) return 'hi';
    if (code.startsWith('ne')) return 'ne';
    if (code.startsWith('ru')) return 'ru';
    return 'en';
  }

  Future<void> setLanguageCode(String code) async {
    final c = _normalize(code);
    _locale = Locale(c);
    final p = await SharedPreferences.getInstance();
    await p.setString(_prefsKey, c);
    notifyListeners();
  }

  /// Short label for pickers (Latin script for consistency in UI chrome).
  static String pickerLabel(String code) {
    switch (_normalizeStatic(code)) {
      case 'hi':
        return 'Hindi (हिन्दी)';
      case 'ne':
        return 'Nepali (नेपाली)';
      case 'ru':
        return 'Russian (Русский)';
      default:
        return 'English';
    }
  }

  static String _normalizeStatic(String code) {
    final c = code.toLowerCase();
    if (c.startsWith('hi')) return 'hi';
    if (c.startsWith('ne')) return 'ne';
    if (c.startsWith('ru')) return 'ru';
    return 'en';
  }
}
