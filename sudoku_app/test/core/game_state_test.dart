import 'package:test/test.dart';
import 'package:sudoku_app/core/generator/puzzle_generator.dart';
import 'package:sudoku_app/core/models/game_state.dart';
import 'package:sudoku_app/core/models/board.dart';
import 'package:sudoku_app/core/models/cell.dart';
import 'package:sudoku_app/core/models/difficulty.dart';
import 'package:sudoku_app/core/validator/sudoku_validator.dart';

void main() {
  group('GameState', () {
    late GameState gameState;
    late Board initialBoard;
    late Board solutionBoard;

    setUp(() {
      final puzzle = PuzzleGenerator(seed: 123).generate(Difficulty.easy);
      initialBoard = puzzle.puzzle;
      solutionBoard = puzzle.solution;
      gameState = GameState(
        initialBoard: initialBoard,
        solutionBoard: solutionBoard,
      );
    });

    test('starts with puzzle board and solution board', () {
      expect(gameState.currentBoard, equals(initialBoard));
      expect(gameState.solutionBoard, equals(solutionBoard));
    });

    test('can place a valid value and then undo/redo it', () {
      final firstMove = _findFirstValidMove(initialBoard);
      expect(firstMove, isNotNull);

      final (target, value) = firstMove!;

      final result = gameState.setValue(target.row, target.col, value);
      expect(result, isTrue);
      expect(gameState.currentBoard.getValue(target.row, target.col), equals(value));
      expect(gameState.canUndo, isTrue);
      expect(gameState.undo(), isTrue);
      expect(gameState.currentBoard.getValue(target.row, target.col), isNull);
      expect(gameState.canRedo, isTrue);
      expect(gameState.redo(), isTrue);
      expect(gameState.currentBoard.getValue(target.row, target.col), equals(value));
    });

    test('does not modify a given cell', () {
      final coords = initialBoard.allCells.firstWhere((c) => c.isGiven);
      final result = gameState.setValue(coords.row, coords.col, 5);
      expect(result, isFalse);
      expect(gameState.currentBoard.getValue(coords.row, coords.col), equals(coords.value));
    });

    test('toggle notes on empty cell and undo them', () {
      final target = initialBoard.allCells.firstWhere((c) => !c.isGiven);
      expect(gameState.toggleNote(target.row, target.col, 4), isTrue);
      expect(gameState.currentBoard.getCell(target.row, target.col).notes, contains(4));
      expect(gameState.undo(), isTrue);
      expect(gameState.currentBoard.getCell(target.row, target.col).notes, isEmpty);
    });

    test('clear cell works and preserves history', () {
      final firstMove = _findFirstValidMove(initialBoard);
      expect(firstMove, isNotNull);

      final (target, value) = firstMove!;

      expect(gameState.setValue(target.row, target.col, value), isTrue);
      expect(gameState.clearCell(target.row, target.col), isTrue);
      expect(gameState.currentBoard.getValue(target.row, target.col), isNull);
      expect(gameState.undo(), isTrue);
      expect(gameState.currentBoard.getValue(target.row, target.col), equals(value));
    });
  });
}

/// Finds the first valid move on the board and returns the position and value.
/// If no valid move is available, returns null.
(Cell, int)? _findFirstValidMove(Board board) {
  for (final cell in board.allCells) {
    if (cell.isGiven) continue;
    for (var digit = 1; digit <= 9; digit++) {
      final ints = board.toInts();
      if (SudokuValidator.isValidMove(ints, cell.row, cell.col, digit)) {
        return (cell, digit);
      }
    }
  }
  return null;
}
