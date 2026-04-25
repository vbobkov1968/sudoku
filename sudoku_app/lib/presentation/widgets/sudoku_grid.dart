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
          border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1.5),
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

  bool _isHighlighted(int row, int col, (int, int)? selected) {
    if (selected == null) return false;
    final (selectedRow, selectedCol) = selected;
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

    Color backgroundColor;
    if (isSelected) {
      backgroundColor = colorScheme.primaryContainer;
    } else if (isHighlighted) {
      backgroundColor = colorScheme.surfaceVariant.withOpacity(0.3);
    } else {
      backgroundColor = colorScheme.surface;
    }

    final borderColor = colorScheme.outline;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            top:    BorderSide(color: borderColor, width: cell.row % 3 == 0 ? 1.5 : 0.3),
            left:   BorderSide(color: borderColor, width: cell.col % 3 == 0 ? 1.5 : 0.3),
            right:  BorderSide(color: borderColor, width: (cell.col + 1) % 3 == 0 ? 1.5 : 0.3),
            bottom: BorderSide(color: borderColor, width: (cell.row + 1) % 3 == 0 ? 1.5 : 0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: _buildCellContent(theme),
        ),
      ),
    );
  }

  Widget _buildCellContent(ThemeData theme) {
    if (cell.value != null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          cell.value.toString(),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: cell.isGiven ? FontWeight.w600 : FontWeight.w400,
            color: cell.isGiven
                ? theme.colorScheme.onSurface
                : theme.colorScheme.primary,
          ),
        ),
      );
    } else if (cell.notes.isNotEmpty) {
      return _buildNotesGrid(theme);
    }
    return const SizedBox.shrink();
  }

  Widget _buildNotesGrid(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth / 3;
        final cellHeight = constraints.maxHeight / 3;

        return Wrap(
          spacing: 0,
          runSpacing: 0,
          children: List.generate(9, (index) {
            final digit = index + 1;
            final hasNote = cell.notes.contains(digit);
            return SizedBox(
              width: cellWidth,
              height: cellHeight,
              child: Center(
                child: Text(
                  hasNote ? digit.toString() : '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: hasNote
                        ? theme.colorScheme.onSurfaceVariant.withOpacity(0.8)
                        : Colors.transparent,
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
