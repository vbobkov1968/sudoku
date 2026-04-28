import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku_app/l10n/generated/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

  Future<void> pumpGameScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: GameScreen(gameState: gameState, difficulty: Difficulty.easy),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('uses numpad buttons to input selected value', (WidgetTester tester) async {
    final emptyInts = gameState.currentBoard.toInts();
    final row = _findFirstEmptyCellRow(emptyInts);
    final col = _findFirstEmptyCellCol(emptyInts);

    gameState.selectCell(row, col);
    await pumpGameScreen(tester);

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
    await pumpGameScreen(tester);

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
    await pumpGameScreen(tester);

    final clearButtonFinder = find.byIcon(Icons.backspace_outlined);
    expect(clearButtonFinder, findsOneWidget);
    await tester.tap(clearButtonFinder);
    await tester.pumpAndSettle();

    expect(gameState.currentBoard.getCell(row, col).value, isNull);
  });

  testWidgets('toggle note mode with button', (WidgetTester tester) async {
    await pumpGameScreen(tester);

    expect(gameState.noteMode, isFalse);

    final noteModeButton = find.byIcon(Icons.edit_off_outlined);
    expect(noteModeButton, findsOneWidget);
    await tester.tap(noteModeButton);
    await tester.pumpAndSettle();

    expect(gameState.noteMode, isTrue);

    final noteModeButtonActive = find.byIcon(Icons.edit_note_outlined);
    expect(noteModeButtonActive, findsOneWidget);
  });

  testWidgets('toggle note mode with keyboard', (WidgetTester tester) async {
    await pumpGameScreen(tester);

    expect(gameState.noteMode, isFalse);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.pumpAndSettle();
    expect(gameState.noteMode, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.pumpAndSettle();
    expect(gameState.noteMode, isFalse);
  });

  testWidgets('input digit in note mode adds note', (WidgetTester tester) async {
    final emptyInts = gameState.currentBoard.toInts();
    final row = _findFirstEmptyCellRow(emptyInts);
    final col = _findFirstEmptyCellCol(emptyInts);

    gameState.selectCell(row, col);
    await pumpGameScreen(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.pumpAndSettle();
    expect(gameState.noteMode, isTrue);

    const digit = 5;
    final digitFinder = find.byKey(const ValueKey('number_pad_$digit'));
    await tester.tap(digitFinder);
    await tester.pumpAndSettle();

    final cell = gameState.currentBoard.getCell(row, col);
    expect(cell.value, isNull);
    expect(cell.notes, contains(digit));
  });

  testWidgets('win detection when board is complete and valid', (WidgetTester tester) async {
    // Fill all empty cells with solution values using setValue
    final solutionInts = gameState.solutionBoard.toInts();
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (gameState.currentBoard.getCell(row, col).value == null &&
            !gameState.currentBoard.getCell(row, col).isGiven) {
          gameState.setValue(row, col, solutionInts[row][col]);
        }
      }
    }
    expect(gameState.isWin, isTrue);
  });

  testWidgets('no win when board has empty cells', (WidgetTester tester) async {
    expect(gameState.isWin, isFalse);
  });
}
