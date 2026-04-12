/// Difficulty levels for Sudoku puzzles.
///
/// Controls how many cells are removed from the solved board.
enum Difficulty {
  easy,
  medium,
  hard,
  expert;

  /// Number of cells to remove for this difficulty.
  int get cellsToRemove {
    switch (this) {
      case Difficulty.easy:
        return 30; // ~51 given cells
      case Difficulty.medium:
        return 40; // ~41 given cells
      case Difficulty.hard:
        return 48; // ~33 given cells
      case Difficulty.expert:
        return 54; // ~27 given cells
    }
  }

  /// Human-readable label.
  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
    }
  }
}
