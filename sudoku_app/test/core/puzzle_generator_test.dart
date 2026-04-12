import 'package:test/test.dart';
import 'package:sudoku_app/core/generator/puzzle_generator.dart';
import 'package:sudoku_app/core/models/difficulty.dart';
import 'package:sudoku_app/core/validator/sudoku_solver.dart';

void main() {
  group('PuzzleGenerator', () {
    late PuzzleGenerator generator;

    setUp(() {
      generator = PuzzleGenerator(seed: 42); // Deterministic for tests
    });

    test('generates a puzzle for each difficulty', () {
      for (final difficulty in Difficulty.values) {
        final puzzle = generator.generate(difficulty);
        expect(puzzle.difficulty, difficulty);
        expect(puzzle.puzzle, isNotNull);
        expect(puzzle.solution, isNotNull);
      }
    });

    test('generated puzzle has a unique solution', () {
      final puzzle = generator.generate(Difficulty.medium);
      final ints = puzzle.puzzle.toInts();

      expect(SudokuSolver.hasUniqueSolution(ints), isTrue);
    });

    test('solution matches the puzzle where cells are filled', () {
      final puzzle = generator.generate(Difficulty.easy);
      final puzzleInts = puzzle.puzzle.toInts();
      final solutionInts = puzzle.solution.toInts();

      for (var r = 0; r < 9; r++) {
        for (var c = 0; c < 9; c++) {
          if (puzzleInts[r][c] != 0) {
            expect(
              puzzleInts[r][c],
              solutionInts[r][c],
              reason: 'Puzzle and solution mismatch at ($r,$c)',
            );
          }
        }
      }
    });

    test('difficulty controls number of empty cells', () {
      final easyPuzzle = generator.generate(Difficulty.easy);
      final expertPuzzle = generator.generate(Difficulty.expert);

      final easyEmpty = _countEmpty(easyPuzzle.puzzle.toInts());
      final expertEmpty = _countEmpty(expertPuzzle.puzzle.toInts());

      // Expert should have fewer given cells (more empty)
      expect(expertEmpty, greaterThanOrEqualTo(easyEmpty));
    });

    test('generated solution is a valid full board', () {
      final puzzle = generator.generate(Difficulty.hard);
      final solutionInts = puzzle.solution.toInts();

      // Check all cells filled
      for (var r = 0; r < 9; r++) {
        for (var c = 0; c < 9; c++) {
          expect(
            solutionInts[r][c],
            inInclusiveRange(1, 9),
            reason: 'Solution cell ($r,$c) should be 1-9',
          );
        }
      }

      // Check unique solution
      expect(SudokuSolver.hasUniqueSolution(solutionInts), isTrue);
    });

    test('generates different puzzles with different seeds', () {
      final gen1 = PuzzleGenerator(seed: 1);
      final gen2 = PuzzleGenerator(seed: 2);

      final puzzle1 = gen1.generate(Difficulty.medium);
      final puzzle2 = gen2.generate(Difficulty.medium);

      expect(
        puzzle1.puzzle.toInts(),
        isNot(equals(puzzle2.puzzle.toInts())),
      );
    });

    test('puzzle board is not completely filled', () {
      final puzzle = generator.generate(Difficulty.medium);
      final ints = puzzle.puzzle.toInts();

      var hasEmpty = false;
      for (var r = 0; r < 9 && !hasEmpty; r++) {
        for (var c = 0; c < 9 && !hasEmpty; c++) {
          if (ints[r][c] == 0) hasEmpty = true;
        }
      }
      expect(hasEmpty, isTrue, reason: 'Puzzle should have empty cells');
    });
  });
}

int _countEmpty(List<List<int>> board) {
  var count = 0;
  for (var r = 0; r < 9; r++) {
    for (var c = 0; c < 9; c++) {
      if (board[r][c] == 0) count++;
    }
  }
  return count;
}
