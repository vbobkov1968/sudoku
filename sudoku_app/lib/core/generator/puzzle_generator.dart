import 'dart:math';

import '../models/difficulty.dart';
import '../models/puzzle.dart';
import '../models/board.dart';
import '../validator/sudoku_solver.dart';

/// Generates valid Sudoku puzzles with a guaranteed unique solution.
///
/// Algorithm:
/// 1. Generate a fully solved board using randomized backtracking.
/// 2. Remove cells one at a time, checking that the puzzle still has
///    exactly one solution after each removal.
/// 3. Stop when the target number of cells has been removed for the
///    chosen difficulty.
class PuzzleGenerator {
  final Random _random;

  PuzzleGenerator({int? seed}) : _random = seed != null ? Random(seed) : Random();

  /// Generates a puzzle for the given [difficulty].
  Puzzle generate(Difficulty difficulty) {
    // Step 1: Generate a full solved board
    final solved = _generateSolvedBoard();

    // Step 2: Remove cells while maintaining unique solution
    final puzzle = _removeCells(solved, difficulty.cellsToRemove);

    return Puzzle(
      puzzle: Board.fromInts(puzzle),
      solution: Board.fromInts(solved),
      difficulty: difficulty,
    );
  }

  /// Generates a fully solved Sudoku board using randomized backtracking.
  List<List<int>> _generateSolvedBoard() {
    final board = List.generate(9, (_) => List.filled(9, 0));
    _fillBoard(board);
    return board;
  }

  /// Fills the [board] using randomized backtracking.
  bool _fillBoard(List<List<int>> board) {
    final empty = _findEmpty(board);
    if (empty == null) return true;

    final (row, col) = empty;
    final numbers = _shuffledNumbers();

    for (final num in numbers) {
      if (_isValid(board, row, col, num)) {
        board[row][col] = num;
        if (_fillBoard(board)) return true;
        board[row][col] = 0;
      }
    }
    return false;
  }

  /// Removes [count] cells from the board while ensuring a unique solution.
  ///
  /// Uses a randomized order to remove cells for variety.
  List<List<int>> _removeCells(List<List<int>> solvedBoard, int count) {
    final board = SudokuSolver.copyBoard(solvedBoard);
    final positions = _allPositions()..shuffle(_random);
    var removed = 0;

    for (final (row, col) in positions) {
      if (removed >= count) break;
      if (board[row][col] == 0) continue;

      final backup = board[row][col];
      board[row][col] = 0;

      if (SudokuSolver.hasUniqueSolution(board)) {
        removed++;
      } else {
        board[row][col] = backup; // Restore — removal would break uniqueness
      }
    }

    return board;
  }

  (int, int)? _findEmpty(List<List<int>> board) {
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (board[row][col] == 0) return (row, col);
      }
    }
    return null;
  }

  bool _isValid(List<List<int>> board, int row, int col, int value) {
    for (var c = 0; c < 9; c++) {
      if (c != col && board[row][c] == value) return false;
    }
    for (var r = 0; r < 9; r++) {
      if (r != row && board[r][col] == value) return false;
    }
    final blockRow = (row ~/ 3) * 3;
    final blockCol = (col ~/ 3) * 3;
    for (var r = blockRow; r < blockRow + 3; r++) {
      for (var c = blockCol; c < blockCol + 3; c++) {
        if ((r != row || c != col) && board[r][c] == value) return false;
      }
    }
    return true;
  }

  List<int> _shuffledNumbers() {
    final nums = List.generate(9, (i) => i + 1);
    nums.shuffle(_random);
    return nums;
  }

  List<(int, int)> _allPositions() {
    final positions = <(int, int)>[];
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        positions.add((row, col));
      }
    }
    return positions;
  }
}
