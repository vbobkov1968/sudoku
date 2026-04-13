import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_app/core/generator/puzzle_generator.dart';
import 'package:sudoku_app/core/models/difficulty.dart';
import 'package:sudoku_app/core/models/game_state.dart';
import 'package:sudoku_app/presentation/game_screen.dart';

int _findFirstEmptyCellRow(List<List<int>> ints) {
  for (var row = 0; row < 9; row++) {
    for (var col = 0; col < 9; col++) {
      if (ints[row][col] == 0) return row;
    }
  }
  return 0;
}

int _findFirstEmptyCellCol(List<List<int>> ints) {
  for (var row = 0; row < 9; row++) {
    for (var col = 0; col < 9; col++) {
      if (ints[row][col] == 0) return col;
    }
  }
  return 0;
}

void main() {
  late GameState gameState;

  setUp(() {
    final generator = PuzzleGenerator(seed: 42);
    final puzzle = generator.generate(Difficulty.easy);
    gameState = GameState(
      initialBoard: puzzle.puzzle,
      solutionBoard: puzzle.solution,
    );
  });

  testWidgets('uses numpad buttons to input selected value', (WidgetTester tester) async {
    final emptyInts = gameState.currentBoard.toInts();
    final row = _findFirstEmptyCellRow(emptyInts);
    final col = _findFirstEmptyCellCol(emptyInts);

    gameState.selectCell(row, col);

    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(gameState: gameState),
      ),
    );
    await tester.pumpAndSettle();

    final digit = gameState.solutionBoard.getCell(row, col).value!;
    final digitFinder = find.byKey(ValueKey('number_pad_$digit'));
    expect(digitFinder, findsOneWidget);
    await tester.tap(digitFinder);
    await tester.pumpAndSettle();

    expect(gameState.currentBoard.getCell(row, col).value, equals(digit));
  });

  testWidgets('uses keyboard digits to input selected value', (WidgetTester tester) async {
    final emptyInts = gameState.currentBoard.toInts();
    final row = _findFirstEmptyCellRow(emptyInts);
    final col = _findFirstEmptyCellCol(emptyInts);

    gameState.selectCell(row, col);

    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(gameState: gameState),
      ),
    );
    await tester.pumpAndSettle();

    final digit = gameState.solutionBoard.getCell(row, col).value!;
    final key = digit == 1
        ? LogicalKeyboardKey.digit1
        : digit == 2
            ? LogicalKeyboardKey.digit2
            : digit == 3
                ? LogicalKeyboardKey.digit3
                : digit == 4
                    ? LogicalKeyboardKey.digit4
                    : digit == 5
                        ? LogicalKeyboardKey.digit5
                        : digit == 6
                            ? LogicalKeyboardKey.digit6
                            : digit == 7
                                ? LogicalKeyboardKey.digit7
                                : digit == 8
                                    ? LogicalKeyboardKey.digit8
                                    : LogicalKeyboardKey.digit9;

    await tester.sendKeyEvent(key);
    await tester.pumpAndSettle();

    expect(gameState.currentBoard.getCell(row, col).value, equals(digit));
  });

  testWidgets('clear button removes selected cell value', (WidgetTester tester) async {
    final emptyInts = gameState.currentBoard.toInts();
    final row = _findFirstEmptyCellRow(emptyInts);
    final col = _findFirstEmptyCellCol(emptyInts);

    gameState.selectCell(row, col);
    gameState.setValue(row, col, 2);

    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(gameState: gameState),
      ),
    );

    final clearButtonFinder = find.byKey(const ValueKey('number_pad_clear'));
    expect(clearButtonFinder, findsOneWidget);
    await tester.tap(clearButtonFinder);
    await tester.pumpAndSettle();

    expect(gameState.currentBoard.getCell(row, col).value, isNull);
  });
}
