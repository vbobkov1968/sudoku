/// Represents a single cell in the Sudoku board.
class Cell {
  final int row;
  final int col;
  final int? value;
  final bool isGiven;
  final Set<int> notes;

  const Cell({
    required this.row,
    required this.col,
    this.value,
    this.isGiven = false,
    this.notes = const {},
  });

  /// Creates an empty cell at the given position.
  const Cell.empty({required int row, required int col})
      : this(row: row, col: col, value: null, isGiven: false);

  /// Creates a cell with a value.
  Cell withValue(int val) {
    return Cell(
      row: row,
      col: col,
      value: val,
      isGiven: isGiven,
      notes: notes,
    );
  }

  /// Creates a cleared cell (no value, no notes).
  Cell cleared() {
    return Cell(row: row, col: col, isGiven: isGiven);
  }

  /// Returns a copy with the note toggled.
  Cell withNote(int digit) {
    final newNotes = Set<int>.from(notes);
    if (newNotes.contains(digit)) {
      newNotes.remove(digit);
    } else {
      newNotes.add(digit);
    }
    return Cell(
      row: row,
      col: col,
      value: value,
      isGiven: isGiven,
      notes: newNotes,
    );
  }

  Cell clearNotes() {
    return Cell(
      row: row,
      col: col,
      value: value,
      isGiven: isGiven,
      notes: {},
    );
  }

  @override
  String toString() {
    if (value != null) return value.toString();
    if (notes.isNotEmpty) return '{${notes.toList().join()}}';
    return '.';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cell &&
          row == other.row &&
          col == other.col &&
          value == other.value &&
          isGiven == other.isGiven &&
          _setsEqual(notes, other.notes);

  @override
  int get hashCode => Object.hash(
        row,
        col,
        value,
        isGiven,
        notes.isEmpty ? 0 : notes.fold(0, (h, e) => (h as int) ^ e.hashCode),
      );

  static bool _setsEqual(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }
}
