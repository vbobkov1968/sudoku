import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import 'core/localization/app_locale.dart';
import 'core/generator/puzzle_generator.dart';
import 'core/models/game_state.dart';
import 'core/models/difficulty.dart';
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

  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate a sample easy puzzle for demonstration
    final generator = PuzzleGenerator(seed: 42); // Fixed seed for consistent demo
    final puzzle = generator.generate(Difficulty.easy);
    final gameState = GameState(
      initialBoard: puzzle.puzzle,
      solutionBoard: puzzle.solution,
    );

    return MaterialApp(
      title: 'Sudoku',
      debugShowCheckedModeBanner: false,

      // Localization setup
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      localeResolutionCallback: localeResolutionCallback,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Game screen
      home: GameScreen(gameState: gameState),
    );
  }
}
