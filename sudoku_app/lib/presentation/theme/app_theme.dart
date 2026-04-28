import 'package:flutter/material.dart';

/// Centralized theme definitions.
abstract final class AppTheme {
  static const _seedColor = Colors.blue;
  static const _useMaterial3 = true;

  static final _scrollbarTheme = ScrollbarThemeData(
    thumbVisibility: WidgetStateProperty.all(false),
  );

  static final lightTheme = ThemeData(
    useMaterial3: _useMaterial3,
    colorSchemeSeed: _seedColor,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: Colors.transparent,
    scrollbarTheme: _scrollbarTheme,
  );

  static final darkTheme = ThemeData(
    useMaterial3: _useMaterial3,
    colorSchemeSeed: _seedColor,
    brightness: Brightness.dark,
    // Semi-transparent dark overlay so the NSVisualEffectView blur
    // reads as a dark frosted-glass rather than the lighter system default.
    scaffoldBackgroundColor: const Color(0xAA000000),
    canvasColor: Colors.transparent,
    scrollbarTheme: _scrollbarTheme,
  );
}
