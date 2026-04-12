/// Backtracking Sudoku solver with solution counting.
class SudokuSolver {
  /// Solves the [board] in-place using backtracking.
  ///
  /// [board] is a 9x9 grid where 0 means empty.
  /// Returns true if a solution is found, false otherwise.
  static bool solve(List<List<int>> board) {
    final empty = _findEmpty(board);
    if (empty == null) return true; // Board is full and valid

    final (row, col) = empty;
    for (var num = 1; num <= 9; num++) {
      if (_isValid(board, row, col, num)) {
        board[row][col] = num;
        if (solve(board)) return true;
        board[row][col] = 0; // Backtrack
      }
    }
    return false;
  }

  /// Counts the number of solutions for the [board].
  ///
  /// Stops counting after [maxSolutions] (default 2) for performance.
  /// Returns the number of distinct solutions (capped at [maxSolutions]).
  static int countSolutions(List<List<int>> board, {int maxSolutions = 2}) {
    return _count(board, 0, maxSolutions);
  }

  /// Returns true if the board has exactly one solution.
  static bool hasUniqueSolution(List<List<int>> board) {
    return countSolutions(board, maxSolutions: 2) == 1;
  }

  /// Creates a deep copy of the board.
  static List<List<int>> copyBoard(List<List<int>> board) {
    return board.map((row) => List<int>.from(row)).toList();
  }

  static (int, int)? _findEmpty(List<List<int>> board) {
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (board[row][col] == 0) return (row, col);
      }
    }
    return null;
  }

  static bool _isValid(List<List<int>> board, int row, int col, int value) {
    // Check row
    for (var c = 0; c < 9; c++) {
      if (c != col && board[row][c] == value) return false;
    }
    // Check column
    for (var r = 0; r < 9; r++) {
      if (r != row && board[r][col] == value) return false;
    }
    // Check 3x3 block
    final blockRow = (row ~/ 3) * 3;
    final blockCol = (col ~/ 3) * 3;
    for (var r = blockRow; r < blockRow + 3; r++) {
      for (var c = blockCol; c < blockCol + 3; c++) {
        if ((r != row || c != col) && board[r][c] == value) return false;
      }
    }
    return true;
  }

  static int _count(
    List<List<int>> board,
    int currentCount,
    int maxSolutions,
  ) {
    if (currentCount >= maxSolutions) return currentCount;

    final empty = _findEmpty(board);
    if (empty == null) return currentCount + 1; // Found a solution

    final (row, col) = empty;
    for (var num = 1; num <= 9; num++) {
      if (_isValid(board, row, col, num)) {
        board[row][col] = num;
        currentCount = _count(board, currentCount, maxSolutions);
        board[row][col] = 0; // Backtrack
        if (currentCount >= maxSolutions) return currentCount;
      }
    }
    return currentCount;
  }
}
