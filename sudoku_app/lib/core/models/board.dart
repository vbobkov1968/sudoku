import 'cell.dart';

/// Represents the full 9x9 Sudoku board.
class Board {
  final List<List<Cell>> _grid;

  Board(this._grid) : assert(_grid.length == 9 && _grid.every((r) => r.length == 9));

  /// Creates a board from a 2D list of integers (0 means empty).
  factory Board.fromInts(List<List<int>> values, {List<List<Set<int>>>? notes}) {
    final grid = List.generate(
      9,
      (row) => List.generate(
        9,
        (col) {
          final val = values[row][col];
          return Cell(
            row: row,
            col: col,
            value: val == 0 ? null : val,
            isGiven: val != 0,
            notes: notes?[row][col] ?? {},
          );
        },
      ),
    );
    return Board(grid);
  }

  /// Creates an empty board.
  factory Board.empty() {
    return Board.fromInts(List.generate(9, (_) => List.filled(9, 0)));
  }

  /// Gets the cell at [row], [col].
  Cell getCell(int row, int col) => _grid[row][col];

  /// Gets the 2D grid of cells.
  List<List<Cell>> get grid => List.unmodifiable(_grid.map(List.unmodifiable));

  /// Gets the value at [row], [col] (null if empty).
  int? getValue(int row, int col) => _grid[row][col].value;

  /// Returns true if the cell at [row], [col] is given (not editable).
  bool isGiven(int row, int col) => _grid[row][col].isGiven;

  /// Returns the row as a list of values (null for empty).
  List<int?> getRow(int row) => _grid[row].map((c) => c.value).toList();

  /// Returns the column as a list of values (null for empty).
  List<int?> getColumn(int col) => List.generate(9, (row) => _grid[row][col].value);

  /// Returns the 3x3 block values containing [row], [col].
  List<int?> getBlock(int row, int col) {
    final blockRow = (row ~/ 3) * 3;
    final blockCol = (col ~/ 3) * 3;
    final values = <int?>[];
    for (var r = blockRow; r < blockRow + 3; r++) {
      for (var c = blockCol; c < blockCol + 3; c++) {
        values.add(_grid[r][c].value);
      }
    }
    return values;
  }

  /// Returns all cells as a flat list.
  List<Cell> get allCells => _grid.expand((row) => row).toList();

  /// Returns cells in the same row, column, or block as [row], [col].
  List<Cell> getPeers(int row, int col) {
    final peers = <Cell>{};
    final blockRow = (row ~/ 3) * 3;
    final blockCol = (col ~/ 3) * 3;

    for (var i = 0; i < 9; i++) {
      if (i != col) peers.add(_grid[row][i]);
      if (i != row) peers.add(_grid[i][col]);
    }
    for (var r = blockRow; r < blockRow + 3; r++) {
      for (var c = blockCol; c < blockCol + 3; c++) {
        if (r != row || c != col) {
          peers.add(_grid[r][c]);
        }
      }
    }
    return peers.toList();
  }

  /// Returns true if the board is completely filled.
  bool get isFull => allCells.every((c) => c.value != null);

  /// Returns true if the board has no conflicts.
  bool get isValid {
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        final val = _grid[row][col].value;
        if (val == null) continue;
        if (_hasConflict(row, col, val)) return false;
      }
    }
    return true;
  }

  bool _hasConflict(int row, int col, int value) {
    // Check row
    for (var c = 0; c < 9; c++) {
      if (c != col && _grid[row][c].value == value) return true;
    }
    // Check column
    for (var r = 0; r < 9; r++) {
      if (r != row && _grid[r][col].value == value) return true;
    }
    // Check 3x3 block
    final blockRow = (row ~/ 3) * 3;
    final blockCol = (col ~/ 3) * 3;
    for (var r = blockRow; r < blockRow + 3; r++) {
      for (var c = blockCol; c < blockCol + 3; c++) {
        if ((r != row || c != col) && _grid[r][c].value == value) return true;
      }
    }
    return false;
  }

  /// Returns the board as a 2D list of integers (0 for empty).
  List<List<int>> toInts() {
    return List.generate(
      9,
      (row) => List.generate(
        9,
        (col) => _grid[row][col].value ?? 0,
      ),
    );
  }

  /// Returns a deep copy of the board.
  Board copy() {
    return Board(
      List.generate(
        9,
        (row) => List.generate(
          9,
          (col) {
            final cell = _grid[row][col];
            return Cell(
              row: row,
              col: col,
              value: cell.value,
              isGiven: cell.isGiven,
              notes: Set<int>.from(cell.notes),
            );
          },
        ),
      ),
    );
  }

  /// Returns a board with a single cell replaced.
  Board copyWithCell(int row, int col, Cell cell) {
    final grid = List.generate(
      9,
      (r) => List.generate(
        9,
        (c) {
          if (r == row && c == col) return cell;
          final existing = _grid[r][c];
          return Cell(
            row: existing.row,
            col: existing.col,
            value: existing.value,
            isGiven: existing.isGiven,
            notes: Set<int>.from(existing.notes),
          );
        },
      ),
    );
    return Board(grid);
  }

  /// Returns a copy with only the given cells marked.
  Board copyWithGiven(List<List<bool>> givenMask) {
    return Board(
      List.generate(
        9,
        (row) => List.generate(
          9,
          (col) {
            final cell = _grid[row][col];
            return Cell(
              row: row,
              col: col,
              value: cell.value,
              isGiven: givenMask[row][col],
              notes: Set<int>.from(cell.notes),
            );
          },
        ),
      ),
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    for (var row = 0; row < 9; row++) {
      if (row % 3 == 0 && row != 0) buffer.writeln('------+-------+------');
      final cells = _grid[row].map((c) => c.value?.toString() ?? '.').toList();
      buffer.writeln('${cells.sublist(0, 3).join(' ')} | ${cells.sublist(3, 6).join(' ')} | ${cells.sublist(6, 9).join(' ')}');
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Board) return false;
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (_grid[row][col] != other._grid[row][col]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(allCells);
}
