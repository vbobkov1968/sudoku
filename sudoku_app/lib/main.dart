import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import 'core/localization/app_locale.dart';
import 'core/generator/puzzle_generator.dart';
import 'core/models/game_state.dart';
import 'core/models/difficulty.dart';
import 'core/models/app_settings.dart';
import 'data/persistence/game_persistence.dart';
import 'data/persistence/settings_persistence.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/game_screen.dart';
import 'presentation/app_settings_scope.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // macOS: window transparency is configured in Swift (MainFlutterWindow.swift).
  if (!Platform.isAndroid && !Platform.isMacOS) {
    await Window.initialize();
    if (Platform.isWindows) {
      await Window.setEffect(effect: WindowEffect.acrylic);
    } else {
      await Window.setEffect(effect: WindowEffect.transparent);
    }
  }

  final results = await Future.wait([
    GamePersistence.load(),
    SettingsPersistence.load(),
  ]);

  final saved = results[0] as SavedGame?;
  final settings = results[1] as AppSettings;

  final GameState initialState;
  final Difficulty initialDifficulty;

  if (saved != null) {
    initialState = saved.state;
    initialDifficulty = saved.difficulty;
  } else {
    initialDifficulty = settings.difficulty;
    final puzzle = PuzzleGenerator(seed: DateTime.now().millisecondsSinceEpoch)
        .generate(initialDifficulty);
    initialState = GameState(
      initialBoard: puzzle.puzzle,
      solutionBoard: puzzle.solution,
    );
  }

  runApp(SudokuApp(
    initialState: initialState,
    initialDifficulty: initialDifficulty,
    initialSettings: settings,
  ));
}

class SudokuApp extends StatefulWidget {
  final GameState initialState;
  final Difficulty initialDifficulty;
  final AppSettings initialSettings;

  const SudokuApp({
    super.key,
    required this.initialState,
    required this.initialDifficulty,
    required this.initialSettings,
  });

  @override
  State<SudokuApp> createState() => _SudokuAppState();
}

class _SudokuAppState extends State<SudokuApp> {
  late final AppSettingsNotifier _settingsNotifier;

  @override
  void initState() {
    super.initState();
    _settingsNotifier = AppSettingsNotifier(widget.initialSettings);
  }

  @override
  void dispose() {
    _settingsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      notifier: _settingsNotifier,
      child: ValueListenableBuilder<AppSettings>(
        valueListenable: _settingsNotifier,
        builder: (_, settings, __) => MaterialApp(
          title: 'Sudoku',
          debugShowCheckedModeBanner: false,
          locale: settings.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: supportedLocales,
          localeResolutionCallback: localeResolutionCallback,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          home: GameScreen(
            gameState: widget.initialState,
            difficulty: widget.initialDifficulty,
          ),
        ),
      ),
    );
  }
}
