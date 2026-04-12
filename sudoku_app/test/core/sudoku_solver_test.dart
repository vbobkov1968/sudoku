import 'package:test/test.dart';
import 'package:sudoku_app/core/validator/sudoku_solver.dart';

void main() {
  group('SudokuSolver', () {
    test('solves a simple puzzle', () {
      // A partially filled board with a known solution
      final board = [
        [5, 3, 0, 0, 7, 0, 0, 0, 0],
        [6, 0, 0, 1, 9, 5, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 6, 0],
        [8, 0, 0, 0, 6, 0, 0, 0, 3],
        [4, 0, 0, 8, 0, 3, 0, 0, 1],
        [7, 0, 0, 0, 2, 0, 0, 0, 6],
        [0, 6, 0, 0, 0, 0, 2, 8, 0],
        [0, 0, 0, 4, 1, 9, 0, 0, 5],
        [0, 0, 0, 0, 8, 0, 0, 7, 9],
      ];

      expect(SudokuSolver.solve(board), isTrue);

      // Check board is full
      for (var r = 0; r < 9; r++) {
        for (var c = 0; c < 9; c++) {
          expect(board[r][c], inInclusiveRange(1, 9));
        }
      }
    });

    test('returns false for unsolvable board', () {
      final board = [
        [5, 3, 0, 0, 7, 0, 0, 0, 0],
        [6, 0, 0, 1, 9, 5, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 6, 0],
        [8, 0, 0, 0, 6, 0, 0, 0, 3],
        [4, 0, 0, 8, 0, 3, 0, 0, 1],
        [7, 0, 0, 0, 2, 0, 0, 0, 6],
        [0, 6, 0, 0, 0, 0, 2, 8, 0],
        [0, 0, 0, 4, 1, 9, 0, 0, 5],
        [0, 0, 0, 0, 8, 0, 0, 7, 9],
      ];
      // Add a conflict that makes it unsolvable
      board[0][1] = 5; // Duplicate 5 in row 0

      expect(SudokuSolver.solve(board), isFalse);
    });

    test('detects unique solution', () {
      final board = [
        [5, 3, 0, 0, 7, 0, 0, 0, 0],
        [6, 0, 0, 1, 9, 5, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 6, 0],
        [8, 0, 0, 0, 6, 0, 0, 0, 3],
        [4, 0, 0, 8, 0, 3, 0, 0, 1],
        [7, 0, 0, 0, 2, 0, 0, 0, 6],
        [0, 6, 0, 0, 0, 0, 2, 8, 0],
        [0, 0, 0, 4, 1, 9, 0, 0, 5],
        [0, 0, 0, 0, 8, 0, 0, 7, 9],
      ];

      expect(SudokuSolver.hasUniqueSolution(board), isTrue);
    });

    test('detects multiple solutions', () {
      // Almost empty board — definitely has multiple solutions
      final board = List.generate(9, (_) => List.filled(9, 0));

      expect(SudokuSolver.countSolutions(board, maxSolutions: 2), 2);
    });

    test('countSolutions returns 0 for invalid board', () {
      final board = [
        [5, 5, 0, 0, 0, 0, 0, 0, 0], // Duplicate in row
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0],
      ];

      expect(SudokuSolver.countSolutions(board), 0);
    });

    test('copyBoard creates independent copy', () {
      final original = List.generate(9, (r) => List.generate(9, (c) => r + c));
      final copy = SudokuSolver.copyBoard(original);
      copy[0][0] = 99;
      expect(original[0][0], 0);
      expect(copy[0][0], 99);
    });
  });
}
