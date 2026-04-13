import 'package:flutter/material.dart';
import '../../core/models/game_state.dart';
import '../../core/models/cell.dart';

/// A widget that renders the 9x9 Sudoku grid with highlighting.
class SudokuGrid extends StatelessWidget {
  final GameState gameState;
  final Function(int row, int col)? onCellTap;

  const SudokuGrid({
    super.key,
    required this.gameState,
    this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
            childAspectRatio: 1.0,
          ),
          itemCount: 81,
          itemBuilder: (context, index) {
            final row = index ~/ 9;
            final col = index % 9;
            return SudokuCell(
              cell: gameState.currentBoard.getCell(row, col),
              isSelected: gameState.selectedCell == (row, col),
              isHighlighted: _isHighlighted(row, col, gameState.selectedCell),
              onTap: () => onCellTap?.call(row, col),
            );
          },
        ),
      ),
    );
  }

  /// Returns true if the cell at [row], [col] should be highlighted based on selection.
  bool _isHighlighted(int row, int col, (int, int)? selected) {
    if (selected == null) return false;
    final (selectedRow, selectedCol) = selected;

    // Highlight same row, column, or 3x3 block
    return row == selectedRow ||
           col == selectedCol ||
           (row ~/ 3 == selectedRow ~/ 3 && col ~/ 3 == selectedCol ~/ 3);
  }
}

/// A single cell in the Sudoku grid.
class SudokuCell extends StatelessWidget {
  final Cell cell;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const SudokuCell({
    super.key,
    required this.cell,
    this.isSelected = false,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine background color based on state
    Color backgroundColor;
    if (isSelected) {
      backgroundColor = colorScheme.primaryContainer;
    } else if (isHighlighted) {
      backgroundColor = colorScheme.surfaceVariant.withOpacity(0.3);
    } else {
      backgroundColor = colorScheme.surface;
    }

    // Determine border color and width for 3x3 block separation
    final borderColor = colorScheme.outline;
    final isThickBorder = _hasThickBorder(cell.row, cell.col);
    final borderWidth = isThickBorder ? 2.0 : 0.5;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            top: BorderSide(
              color: borderColor,
              width: cell.row % 3 == 0 ? 2.0 : 0.5,
            ),
            left: BorderSide(
              color: borderColor,
              width: cell.col % 3 == 0 ? 2.0 : 0.5,
            ),
            right: BorderSide(
              color: borderColor,
              width: (cell.col + 1) % 3 == 0 ? 2.0 : 0.5,
            ),
            bottom: BorderSide(
              color: borderColor,
              width: (cell.row + 1) % 3 == 0 ? 2.0 : 0.5,
            ),
          ),
        ),
        child: Center(
          child: _buildCellContent(theme),
        ),
      ),
    );
  }

  Widget _buildCellContent(ThemeData theme) {
    if (cell.value != null) {
      // Show the digit
      return Text(
        cell.value.toString(),
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: cell.isGiven ? FontWeight.bold : FontWeight.normal,
          color: cell.isGiven
              ? theme.colorScheme.onSurface
              : theme.colorScheme.primary,
        ),
      );
    } else if (cell.notes.isNotEmpty) {
      // Show notes in a 3x3 grid
      return _buildNotesGrid(theme);
    }
    return const SizedBox.shrink();
  }

  Widget _buildNotesGrid(ThemeData theme) {
    return GridView.count(
      crossAxisCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: List.generate(9, (index) {
        final digit = index + 1;
        final hasNote = cell.notes.contains(digit);
        return Center(
          child: Text(
            hasNote ? digit.toString() : '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        );
      }),
    );
  }

  /// Returns true if this cell should have thick borders (3x3 block separation).
  bool _hasThickBorder(int row, int col) {
    return row % 3 == 2 || col % 3 == 2;
  }
}