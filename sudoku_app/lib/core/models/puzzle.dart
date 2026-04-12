import 'board.dart';
import 'difficulty.dart';

/// Represents a generated Sudoku puzzle with its solution.
class Puzzle {
  /// The puzzle board (some cells filled, some empty).
  final Board puzzle;

  /// The fully solved board.
  final Board solution;

  /// Difficulty level.
  final Difficulty difficulty;

  const Puzzle({
    required this.puzzle,
    required this.solution,
    required this.difficulty,
  });

  @override
  String toString() {
    return 'Puzzle(${difficulty.label})\n$puzzle';
  }
}
