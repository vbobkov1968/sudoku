import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_app/core/generator/puzzle_generator.dart';
import 'package:sudoku_app/core/models/difficulty.dart';
import 'package:sudoku_app/core/models/game_state.dart';
import 'package:sudoku_app/presentation/widgets/sudoku_grid.dart';

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

  group('SudokuGrid', () {
    testWidgets('renders 9x9 grid', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SudokuGrid(
              gameState: gameState,
              onCellTap: (row, col) {},
            ),
          ),
        ),
      );

      // Should have 81 cells
      expect(find.byType(SudokuCell), findsNWidgets(81));
    });

    testWidgets('highlights selected cell', (WidgetTester tester) async {
      gameState.selectCell(0, 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SudokuGrid(
              gameState: gameState,
              onCellTap: (row, col) {},
            ),
          ),
        ),
      );

      // The first cell should be selected
      final sudokuCells = find.byType(SudokuCell);
      final firstCell = tester.widget<SudokuCell>(sudokuCells.first);
      expect(firstCell.isSelected, isTrue);
    });

    testWidgets('highlights row, column, and block when cell selected', (WidgetTester tester) async {
      gameState.selectCell(1, 1); // Select cell at row 1, col 1

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SudokuGrid(
              gameState: gameState,
              onCellTap: (row, col) {},
            ),
          ),
        ),
      );

      final sudokuCells = find.byType(SudokuCell);

      // Check that cells in the same row, column, and block are highlighted
      for (int i = 0; i < 81; i++) {
        final row = i ~/ 9;
        final col = i % 9;
        final cell = tester.widget<SudokuCell>(sudokuCells.at(i));

        final shouldBeHighlighted = row == 1 || col == 1 || (row ~/ 3 == 1 ~/ 3 && col ~/ 3 == 1 ~/ 3);
        expect(cell.isHighlighted, shouldBeHighlighted || (row == 1 && col == 1), reason: 'Cell ($row, $col)');
      }
    });

    testWidgets('calls onCellTap when cell is tapped', (WidgetTester tester) async {
      int? tappedRow;
      int? tappedCol;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SudokuGrid(
              gameState: gameState,
              onCellTap: (row, col) {
                tappedRow = row;
                tappedCol = col;
              },
            ),
          ),
        ),
      );

      // Tap the first cell (0, 0)
      await tester.tap(find.byType(SudokuCell).first);
      await tester.pump();

      expect(tappedRow, equals(0));
      expect(tappedCol, equals(0));
    });
  });
}