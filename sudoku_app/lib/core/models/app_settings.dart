import 'package:flutter/material.dart';
import 'difficulty.dart';

class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;
  final Difficulty difficulty;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
    this.difficulty = Difficulty.easy,
  });

  AppSettings withTheme(ThemeMode mode) =>
      AppSettings(themeMode: mode, locale: locale, difficulty: difficulty);

  AppSettings withLocale(Locale l) =>
      AppSettings(themeMode: themeMode, locale: l, difficulty: difficulty);

  AppSettings withDifficulty(Difficulty d) =>
      AppSettings(themeMode: themeMode, locale: locale, difficulty: d);
}
