import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/app_settings.dart';
import '../../core/models/difficulty.dart';

class SettingsPersistence {
  static const _themeKey = 'settings_theme';
  static const _localeKey = 'settings_locale';
  static const _difficultyKey = 'settings_difficulty';

  static Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, settings.themeMode.name);
    await prefs.setString(_localeKey, settings.locale.languageCode);
    await prefs.setString(_difficultyKey, settings.difficulty.name);
  }

  static Future<AppSettings> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == (prefs.getString(_themeKey) ?? ''),
        orElse: () => ThemeMode.system,
      );
      final localeCode = prefs.getString(_localeKey);
      final locale = localeCode != null ? Locale(localeCode) : const Locale('en');
      final difficulty = Difficulty.values.firstWhere(
        (d) => d.name == (prefs.getString(_difficultyKey) ?? ''),
        orElse: () => Difficulty.easy,
      );
      return AppSettings(themeMode: themeMode, locale: locale, difficulty: difficulty);
    } catch (_) {
      return const AppSettings();
    }
  }
}
