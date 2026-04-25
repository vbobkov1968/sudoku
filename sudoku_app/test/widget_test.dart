// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_app/core/generator/puzzle_generator.dart';
import 'package:sudoku_app/core/models/app_settings.dart';
import 'package:sudoku_app/core/models/difficulty.dart';
import 'package:sudoku_app/core/models/game_state.dart';
import 'package:sudoku_app/main.dart';

void main() {
  testWidgets('SudokuApp renders without crashing', (WidgetTester tester) async {
    final puzzle = PuzzleGenerator(seed: 42).generate(Difficulty.easy);
    final state = GameState(
      initialBoard: puzzle.puzzle,
      solutionBoard: puzzle.solution,
    );
    await tester.pumpWidget(SudokuApp(
      initialState: state,
      initialDifficulty: Difficulty.easy,
      initialSettings: const AppSettings(),
    ));
    expect(find.byType(SudokuApp), findsOneWidget);
  });
}
