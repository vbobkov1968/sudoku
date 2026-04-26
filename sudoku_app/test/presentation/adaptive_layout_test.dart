import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_app/core/generator/puzzle_generator.dart';
import 'package:sudoku_app/core/models/difficulty.dart';
import 'package:sudoku_app/core/models/game_state.dart';
import 'package:sudoku_app/presentation/game_screen.dart';
import 'package:sudoku_app/presentation/widgets/number_pad.dart';
import 'package:sudoku_app/presentation/widgets/sudoku_grid.dart';

void main() {
  late GameState gameState;

  setUp(() {
    final puzzle = PuzzleGenerator(seed: 42).generate(Difficulty.easy);
    gameState = GameState(
      initialBoard: puzzle.puzzle,
      solutionBoard: puzzle.solution,
    );
  });

  Future<void> pumpGameScreen(
    WidgetTester tester, {
    double width = 1200,
    double height = 900,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: GameScreen(gameState: gameState, difficulty: Difficulty.easy),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Adaptive layout', () {
    testWidgets('renders SudokuGrid at standard desktop size', (tester) async {
      await pumpGameScreen(tester, width: 1200, height: 900);
      expect(find.byType(SudokuGrid), findsOneWidget);
    });

    testWidgets('renders NumberPad at standard desktop size', (tester) async {
      await pumpGameScreen(tester, width: 1200, height: 900);
      expect(find.byType(NumberPad), findsOneWidget);
    });

    testWidgets('renders all 81 cells at standard desktop size', (tester) async {
      await pumpGameScreen(tester, width: 1200, height: 900);
      expect(find.byType(SudokuCell), findsNWidgets(81));
    });

    testWidgets('renders SudokuGrid at narrow window', (tester) async {
      await pumpGameScreen(tester, width: 400, height: 700);
      expect(find.byType(SudokuGrid), findsOneWidget);
    });

    testWidgets('renders NumberPad at narrow window', (tester) async {
      await pumpGameScreen(tester, width: 400, height: 700);
      expect(find.byType(NumberPad), findsOneWidget);
    });

    testWidgets('renders all 81 cells at narrow window', (tester) async {
      await pumpGameScreen(tester, width: 400, height: 700);
      expect(find.byType(SudokuCell), findsNWidgets(81));
    });

    testWidgets('renders 9 numpad buttons (1–9)', (tester) async {
      await pumpGameScreen(tester);
      for (var digit = 1; digit <= 9; digit++) {
        expect(find.byKey(ValueKey('number_pad_$digit')), findsOneWidget,
            reason: 'Numpad button $digit should be present');
      }
    });

    testWidgets('undo and redo buttons are present', (tester) async {
      await pumpGameScreen(tester);
      expect(find.byIcon(Icons.undo_outlined), findsOneWidget);
      expect(find.byIcon(Icons.redo_outlined), findsOneWidget);
    });

    testWidgets('note mode toggle button is present', (tester) async {
      await pumpGameScreen(tester);
      expect(
        find.byIcon(Icons.edit_off_outlined).evaluate().isNotEmpty ||
            find.byIcon(Icons.edit_note_outlined).evaluate().isNotEmpty,
        isTrue,
        reason: 'Note mode button should be present',
      );
    });
  });
}
