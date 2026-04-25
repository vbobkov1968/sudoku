import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import 'core/localization/app_locale.dart';
import 'core/generator/puzzle_generator.dart';
import 'core/models/game_state.dart';
import 'core/models/difficulty.dart';
import 'data/persistence/game_persistence.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // macOS: window transparency and titlebar are configured entirely in Swift
  // (MainFlutterWindow.swift) to avoid conflicts with macos_window_utils.
  if (!Platform.isAndroid && !Platform.isMacOS) {
    await Window.initialize();
    if (Platform.isWindows) {
      await Window.setEffect(effect: WindowEffect.acrylic);
    } else {
      await Window.setEffect(effect: WindowEffect.transparent);
    }
  }

  final saved = await GamePersistence.load();

  final GameState initialState;
  final Difficulty initialDifficulty;

  if (saved != null) {
    initialState = saved.state;
    initialDifficulty = saved.difficulty;
  } else {
    initialDifficulty = Difficulty.easy;
    final puzzle = PuzzleGenerator(seed: DateTime.now().millisecondsSinceEpoch)
        .generate(initialDifficulty);
    initialState = GameState(
      initialBoard: puzzle.puzzle,
      solutionBoard: puzzle.solution,
    );
  }

  runApp(SudokuApp(initialState: initialState, initialDifficulty: initialDifficulty));
}

class SudokuApp extends StatelessWidget {
  final GameState initialState;
  final Difficulty initialDifficulty;

  const SudokuApp({
    super.key,
    required this.initialState,
    required this.initialDifficulty,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku',
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      localeResolutionCallback: localeResolutionCallback,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      home: GameScreen(gameState: initialState, difficulty: initialDifficulty),
    );
  }
}
