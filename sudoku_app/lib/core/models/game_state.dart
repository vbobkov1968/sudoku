import 'board.dart';
import '../validator/sudoku_validator.dart';

/// Manages the current Sudoku board state, undo/redo history and note mode.
class GameState {
  final Board initialBoard;
  final Board solutionBoard;
  final int historyLimit;

  Board _currentBoard;
  final List<Board> _undoStack = [];
  final List<Board> _redoStack = [];
  bool noteMode;
  (int, int)? _selectedCell; // (row, col) tuple, null if no selection

  GameState({
    required this.initialBoard,
    required this.solutionBoard,
    Board? currentBoard,
    this.noteMode = false,
    this.historyLimit = 50,
    (int, int)? selectedCell,
    List<Board>? undoStack,
    List<Board>? redoStack,
  }) : _currentBoard = currentBoard ?? initialBoard.copy(),
       _selectedCell = selectedCell {
    if (undoStack != null) _undoStack.addAll(undoStack);
    if (redoStack != null) _redoStack.addAll(redoStack);
  }

  Board get currentBoard => _currentBoard;

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  List<Board> get undoStack => List.unmodifiable(_undoStack);
  List<Board> get redoStack => List.unmodifiable(_redoStack);

  /// True when any non-given cell has a value or notes (game has user progress).
  bool get hasProgress => _currentBoard.allCells.any(
    (c) => !c.isGiven && (c.value != null || c.notes.isNotEmpty),
  );

  /// Returns true if the board is completely filled with no conflicts.
  bool get isWin => SudokuValidator.isWin(_currentBoard.toInts());

  /// Gets the currently selected cell position, null if none selected.
  (int, int)? get selectedCell => _selectedCell;

  /// Selects a cell at the given position.
  void selectCell(int row, int col) {
    if (row >= 0 && row < 9 && col >= 0 && col < 9) {
      _selectedCell = (row, col);
    }
  }

  /// Clears the current cell selection.
  void clearSelection() {
    _selectedCell = null;
  }

  /// Returns the set of cells that currently violate Sudoku rules.
  Set<(int, int)> get conflictCells =>
      SudokuValidator.getConflicts(_currentBoard.toInts()).toSet();

  /// Applies a normal digit entry to the board.
  /// Conflicts (row/col/block duplicates) are allowed and shown in the UI.
  /// Returns true when the cell was writable and the value is in range.
  bool setValue(int row, int col, int value) {
    final cell = _currentBoard.getCell(row, col);
    if (cell.isGiven || value < 1 || value > 9) return false;

    _recordState();
    _currentBoard = _currentBoard.copyWithCell(row, col, cell.withValue(value).clearNotes());
    return true;
  }

  /// Clears the value of the specified cell.
  bool clearCell(int row, int col) {
    final cell = _currentBoard.getCell(row, col);
    if (cell.isGiven) return false;
    if (cell.value == null && cell.notes.isEmpty) return false;

    _recordState();
    _currentBoard = _currentBoard.copyWithCell(row, col, cell.cleared());
    return true;
  }

  /// Applies digit input based on the current note mode.
  bool applyInput(int digit) {
    final selected = _selectedCell;
    if (selected == null) return false;
    final (row, col) = selected;

    if (noteMode) {
      return toggleNote(row, col, digit);
    }
    return setValue(row, col, digit);
  }

  /// Clears the currently selected cell.
  bool clearSelected() {
    final selected = _selectedCell;
    if (selected == null) return false;
    final (row, col) = selected;
    return clearCell(row, col);
  }

  /// Toggles a note digit in the selected cell.
  bool toggleNote(int row, int col, int digit) {
    final cell = _currentBoard.getCell(row, col);
    if (cell.isGiven || cell.value != null || digit < 1 || digit > 9) return false;

    _recordState();
    _currentBoard = _currentBoard.copyWithCell(row, col, cell.withNote(digit));
    return true;
  }

  /// Switches between normal entry and note mode.
  void toggleNoteMode() {
    noteMode = !noteMode;
  }

  /// Undoes the last board change.
  bool undo() {
    if (!canUndo) return false;
    _redoStack.add(_currentBoard.copy());
    _currentBoard = _undoStack.removeLast();
    return true;
  }

  /// Redoes the last undone board change.
  bool redo() {
    if (!canRedo) return false;
    _undoStack.add(_currentBoard.copy());
    _currentBoard = _redoStack.removeLast();
    return true;
  }

  void _recordState() {
    _undoStack.add(_currentBoard.copy());
    if (_undoStack.length > historyLimit) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }
}
