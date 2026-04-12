import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:sudoku_app/core/localization/app_locale.dart';

void main() {
  group('AppLocale', () {
    test('supportedLocales contains en and ru', () {
      expect(supportedLocales.length, 2);
      expect(supportedLocales.map((l) => l.languageCode), contains('en'));
      expect(supportedLocales.map((l) => l.languageCode), contains('ru'));
    });

    test('localeResolutionCallback returns exact match for en', () {
      final result = localeResolutionCallback(
        const Locale('en'),
        supportedLocales,
      );
      expect(result.languageCode, 'en');
    });

    test('localeResolutionCallback returns exact match for ru', () {
      final result = localeResolutionCallback(
        const Locale('ru'),
        supportedLocales,
      );
      expect(result.languageCode, 'ru');
    });

    test('localeResolutionCallback falls back to en for unsupported', () {
      final result = localeResolutionCallback(
        const Locale('fr'),
        supportedLocales,
      );
      expect(result.languageCode, 'en');
    });

    test('localeResolutionCallback falls back to en for null locale', () {
      final result = localeResolutionCallback(null, supportedLocales);
      expect(result.languageCode, 'en');
    });

    test('localeResolutionCallback handles regional variants', () {
      // en-US should resolve to en
      final result = localeResolutionCallback(
        const Locale('en', 'US'),
        supportedLocales,
      );
      expect(result.languageCode, 'en');
    });
  });
}
