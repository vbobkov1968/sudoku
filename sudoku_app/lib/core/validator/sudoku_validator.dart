/// Validates Sudoku moves and board state.
class SudokuValidator {
  /// Checks if placing [value] at [row], [col] is valid given the [board].
  ///
  /// [board] is a 9x9 grid where 0 means empty.
  static bool isValidMove(List<List<int>> board, int row, int col, int value) {
    if (value < 1 || value > 9) return false;
    if (row < 0 || row >= 9 || col < 0 || col >= 9) return false;

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

  /// Checks if the [board] has any conflicts.
  ///
  /// Returns a list of (row, col) positions that have conflicts.
  static List<(int, int)> getConflicts(List<List<int>> board) {
    final conflicts = <(int, int)>[];
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        final val = board[row][col];
        if (val == 0) continue;
        if (!_isPositionValid(board, row, col, val)) {
          conflicts.add((row, col));
        }
      }
    }
    return conflicts;
  }

  /// Returns true if the board is completely filled and has no conflicts.
  /// This means the player has won the game.
  static bool isWin(List<List<int>> board) {
    // Check if all cells are filled
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (board[row][col] == 0) return false;
      }
    }
    // Check for any conflicts
    return getConflicts(board).isEmpty;
  }

  static bool _isPositionValid(
    List<List<int>> board,
    int row,
    int col,
    int value,
  ) {
    // Check row (excluding self)
    for (var c = 0; c < 9; c++) {
      if (c != col && board[row][c] == value) return false;
    }
    // Check column
    for (var r = 0; r < 9; r++) {
      if (r != row && board[r][col] == value) return false;
    }
    // Check block
    final blockRow = (row ~/ 3) * 3;
    final blockCol = (col ~/ 3) * 3;
    for (var r = blockRow; r < blockRow + 3; r++) {
      for (var c = blockCol; c < blockCol + 3; c++) {
        if ((r != row || c != col) && board[r][c] == value) return false;
      }
    }
    return true;
  }
}
