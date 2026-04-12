import 'package:flutter/material.dart';

/// Centralized theme definitions.
abstract final class AppTheme {
  static const _seedColor = Colors.blue;
  static const _useMaterial3 = true;

  static final lightTheme = ThemeData(
    useMaterial3: _useMaterial3,
    colorSchemeSeed: _seedColor,
    brightness: Brightness.light,
  );

  static final darkTheme = ThemeData(
    useMaterial3: _useMaterial3,
    colorSchemeSeed: _seedColor,
    brightness: Brightness.dark,
  );
}
