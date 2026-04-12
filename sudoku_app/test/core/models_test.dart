import 'package:test/test.dart';
import 'package:sudoku_app/core/models/models.dart';

void main() {
  group('Cell', () {
    test('creates an empty cell', () {
      const cell = Cell.empty(row: 0, col: 0);
      expect(cell.value, isNull);
      expect(cell.isGiven, isFalse);
      expect(cell.notes, isEmpty);
    });

    test('creates a given cell', () {
      const givenCell = Cell(row: 0, col: 0, value: 5, isGiven: true);
      expect(givenCell.isGiven, isTrue);
      expect(givenCell.value, 5);
    });

    test('withValue returns a new cell', () {
      const cell = Cell.empty(row: 0, col: 0);
      final newValued = cell.withValue(3);
      expect(cell.value, isNull);
      expect(newValued.value, 3);
    });

    test('toggles notes', () {
      const cell = Cell.empty(row: 0, col: 0);
      final withNote = cell.withNote(5);
      expect(withNote.notes, {5});

      final removed = withNote.withNote(5);
      expect(removed.notes, isEmpty);
    });

    test('clearNotes removes all notes', () {
      final cell = const Cell.empty(row: 0, col: 0).withNote(1).withNote(3);
      final cleared = cell.clearNotes();
      expect(cleared.notes, isEmpty);
      expect(cell.notes, {1, 3}); // Original unchanged
    });
  });

  group('Board', () {
    test('creates from ints', () {
      final values = List.generate(9, (_) => List.filled(9, 0));
      values[0][0] = 5;
      final board = Board.fromInts(values);

      expect(board.getValue(0, 0), 5);
      expect(board.getValue(0, 1), isNull);
      expect(board.isGiven(0, 0), isTrue);
    });

    test('getRow, getColumn, getBlock', () {
      final values = List.generate(9, (_) => List.filled(9, 0));
      for (var c = 0; c < 9; c++) {
        values[0][c] = c + 1;
      }
      final board = Board.fromInts(values);

      expect(board.getRow(0), [1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(board.getColumn(0).whereType<int>().toList(), [1]);
    });

    test('isFull returns true when all cells filled', () {
      final values = List.generate(9, (r) => List.generate(9, (c) => (r + c) % 9 + 1));
      final board = Board.fromInts(values);
      expect(board.isFull, isTrue);
    });

    test('copy creates independent copy', () {
      final values = List.generate(9, (_) => List.filled(9, 0));
      values[0][0] = 1;
      final board = Board.fromInts(values);
      final copied = board.copy();

      expect(copied.getValue(0, 0), 1);
      expect(board == copied, isTrue);
    });

    test('toInts round-trip', () {
      final values = [
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
      final board = Board.fromInts(values);
      expect(board.toInts(), values);
    });
  });

  group('Difficulty', () {
    test('cellsToRemove increases with difficulty', () {
      expect(Difficulty.easy.cellsToRemove, 30);
      expect(Difficulty.medium.cellsToRemove, 40);
      expect(Difficulty.hard.cellsToRemove, 48);
      expect(Difficulty.expert.cellsToRemove, 54);
    });

    test('labels are correct', () {
      expect(Difficulty.easy.label, 'Easy');
      expect(Difficulty.medium.label, 'Medium');
      expect(Difficulty.hard.label, 'Hard');
      expect(Difficulty.expert.label, 'Expert');
    });
  });
}
