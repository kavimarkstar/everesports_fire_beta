import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  Locale? _currentLocale;
  Locale? get currentLocale => _currentLocale;

  static const List<Locale> supportedLocales = [Locale('en'), Locale('si')];

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      _currentLocale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_currentLocale?.languageCode == locale.languageCode) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    _currentLocale = locale;
    notifyListeners();
  }

  Future<void> setLanguageCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  String get currentLanguageCode => _currentLocale?.languageCode ?? 'en';
}
