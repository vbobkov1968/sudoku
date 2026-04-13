import 'package:test/test.dart';
import 'package:sudoku_app/core/validator/sudoku_validator.dart';

void main() {
  group('SudokuValidator', () {
    late List<List<int>> emptyBoard;

    setUp(() {
      emptyBoard = List.generate(9, (_) => List.filled(9, 0));
    });

    test('allows placing a number in an empty cell', () {
      expect(SudokuValidator.isValidMove(emptyBoard, 0, 0, 5), isTrue);
    });

    test('rejects invalid numbers (0, 10)', () {
      expect(SudokuValidator.isValidMove(emptyBoard, 0, 0, 0), isFalse);
      expect(SudokuValidator.isValidMove(emptyBoard, 0, 0, 10), isFalse);
    });

    group('isWin', () {
      test('returns false for empty board', () {
        expect(SudokuValidator.isWin(emptyBoard), isFalse);
      });

      test('returns false for partially filled board', () {
        final board = List.generate(9, (_) => List.filled(9, 0));
        board[0][0] = 5;
        expect(SudokuValidator.isWin(board), isFalse);
      });

      test('returns false for full board with conflicts', () {
        final board = List.generate(9, (_) => List.filled(9, 1));
        expect(SudokuValidator.isWin(board), isFalse);
      });

      test('returns true for valid complete board', () {
        // Valid solved Sudoku
        final board = [
          [5, 3, 4, 6, 7, 8, 9, 1, 2],
          [6, 7, 2, 1, 9, 5, 3, 4, 8],
          [1, 9, 8, 3, 4, 2, 5, 6, 7],
          [8, 5, 9, 7, 6, 1, 4, 2, 3],
          [4, 2, 6, 8, 5, 3, 7, 9, 1],
          [7, 1, 3, 9, 2, 4, 8, 5, 6],
          [9, 6, 1, 5, 3, 7, 2, 8, 4],
          [2, 8, 7, 4, 1, 9, 6, 3, 5],
          [3, 4, 5, 2, 8, 6, 1, 7, 9],
        ];
        expect(SudokuValidator.isWin(board), isTrue);
      });
    });

    test('rejects duplicate in row', () {
      final board = List.generate(9, (_) => List.filled(9, 0));
      board[0][5] = 3;
      expect(SudokuValidator.isValidMove(board, 0, 8, 3), isFalse);
      expect(SudokuValidator.isValidMove(board, 0, 8, 7), isTrue);
    });

    test('rejects duplicate in column', () {
      final board = List.generate(9, (_) => List.filled(9, 0));
      board[4][0] = 6;
      expect(SudokuValidator.isValidMove(board, 8, 0, 6), isFalse);
    });

    test('rejects duplicate in 3x3 block', () {
      final board = List.generate(9, (_) => List.filled(9, 0));
      board[1][1] = 9;
      expect(SudokuValidator.isValidMove(board, 2, 2, 9), isFalse);
    });

    test('rejects out-of-bounds positions', () {
      expect(SudokuValidator.isValidMove(emptyBoard, -1, 0, 1), isFalse);
      expect(SudokuValidator.isValidMove(emptyBoard, 9, 0, 1), isFalse);
      expect(SudokuValidator.isValidMove(emptyBoard, 0, -1, 1), isFalse);
      expect(SudokuValidator.isValidMove(emptyBoard, 0, 9, 1), isFalse);
    });

    test('finds conflicts on a board with duplicates', () {
      final board = List.generate(9, (_) => List.filled(9, 0));
      // Duplicate 5s in row 0
      board[0][0] = 5;
      board[0][8] = 5;

      final conflicts = SudokuValidator.getConflicts(board);
      expect(conflicts.length, greaterThanOrEqualTo(2));
    });

    test('no conflicts on empty board', () {
      expect(SudokuValidator.getConflicts(emptyBoard), isEmpty);
    });
  });
}
