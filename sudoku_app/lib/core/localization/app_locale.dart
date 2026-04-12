import 'package:flutter/material.dart';

/// Supported locales for the Sudoku app.
const supportedLocales = [
  Locale('en'),
  Locale('ru'),
];

/// Locale resolution strategy: falls back to English if locale unsupported.
Locale localeResolutionCallback(Locale? locale, Iterable<Locale> supportedLocales) {
  if (locale == null) return const Locale('en');

  // Exact match
  for (final supported in supportedLocales) {
    if (supported.languageCode == locale.languageCode) {
      return supported;
    }
  }

  // Fallback to English
  return const Locale('en');
}
