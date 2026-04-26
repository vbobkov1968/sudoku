import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_app/core/models/app_settings.dart';
import 'package:sudoku_app/core/models/difficulty.dart';
import 'package:sudoku_app/data/persistence/settings_persistence.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsPersistence', () {
    test('load returns defaults when nothing saved', () async {
      final settings = await SettingsPersistence.load();

      expect(settings.themeMode, ThemeMode.system);
      expect(settings.locale.languageCode, 'en');
      expect(settings.difficulty, Difficulty.easy);
    });

    test('save and load roundtrip preserves themeMode light', () async {
      const s = AppSettings(themeMode: ThemeMode.light);
      await SettingsPersistence.save(s);
      final loaded = await SettingsPersistence.load();

      expect(loaded.themeMode, ThemeMode.light);
    });

    test('save and load roundtrip preserves themeMode dark', () async {
      const s = AppSettings(themeMode: ThemeMode.dark);
      await SettingsPersistence.save(s);
      final loaded = await SettingsPersistence.load();

      expect(loaded.themeMode, ThemeMode.dark);
    });

    test('save and load roundtrip preserves locale ru', () async {
      const s = AppSettings(locale: Locale('ru'));
      await SettingsPersistence.save(s);
      final loaded = await SettingsPersistence.load();

      expect(loaded.locale.languageCode, 'ru');
    });

    test('save and load roundtrip preserves difficulty expert', () async {
      const s = AppSettings(difficulty: Difficulty.expert);
      await SettingsPersistence.save(s);
      final loaded = await SettingsPersistence.load();

      expect(loaded.difficulty, Difficulty.expert);
    });

    test('save all fields and load them back together', () async {
      const s = AppSettings(
        themeMode: ThemeMode.dark,
        locale: Locale('ru'),
        difficulty: Difficulty.hard,
      );
      await SettingsPersistence.save(s);
      final loaded = await SettingsPersistence.load();

      expect(loaded.themeMode, ThemeMode.dark);
      expect(loaded.locale.languageCode, 'ru');
      expect(loaded.difficulty, Difficulty.hard);
    });
  });
}
