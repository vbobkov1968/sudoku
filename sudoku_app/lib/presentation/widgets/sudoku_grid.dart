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
    final conflicts = gameState.conflictCells;
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Sudoku puzzle grid',
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline, width: 2.0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                GridView.builder(
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
                      isConflict: conflicts.contains((row, col)),
                      onTap: () => onCellTap?.call(row, col),
                    );
                  },
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _GridLinePainter(
                        thinColor: colorScheme.outlineVariant,
                        thickColor: colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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

class _GridLinePainter extends CustomPainter {
  final Color thinColor;
  final Color thickColor;

  const _GridLinePainter({required this.thinColor, required this.thickColor});

  @override
  void paint(Canvas canvas, Size size) {
    final thin = Paint()
      ..color = thinColor
      ..strokeWidth = 1.0
      ..isAntiAlias = false;

    final thick = Paint()
      ..color = thickColor
      ..strokeWidth = 2.0
      ..isAntiAlias = false;

    for (int i = 1; i < 9; i++) {
      final paint = i % 3 == 0 ? thick : thin;
      final pos = (size.width * i / 9).roundToDouble();
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), paint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), paint);
    }
  }

  @override
  bool shouldRepaint(_GridLinePainter old) =>
      thinColor != old.thinColor || thickColor != old.thickColor;
}

/// A single cell in the Sudoku grid.
class SudokuCell extends StatelessWidget {
  final Cell cell;
  final bool isSelected;
  final bool isHighlighted;
  final bool isConflict;
  final VoidCallback? onTap;

  const SudokuCell({
    super.key,
    required this.cell,
    this.isSelected = false,
    this.isHighlighted = false,
    this.isConflict = false,
    this.onTap,
  });

  String _semanticsLabel() {
    final pos = 'Row ${cell.row + 1}, Column ${cell.col + 1}';
    if (isConflict) return '$pos. Conflict: ${cell.value}.';
    if (cell.value != null) {
      return cell.isGiven ? '$pos. Given: ${cell.value}.' : '$pos. Entered: ${cell.value}.';
    }
    if (cell.notes.isNotEmpty) {
      final sorted = cell.notes.toList()..sort();
      return '$pos. Notes: ${sorted.join(', ')}.';
    }
    return '$pos. Empty.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;
    Color backgroundColor;
    if (isConflict && isSelected) {
      backgroundColor = colorScheme.errorContainer;
    } else if (isConflict) {
      backgroundColor = colorScheme.errorContainer.withValues(alpha: 0.5);
    } else if (isSelected) {
      backgroundColor = colorScheme.primaryContainer;
    } else if (isHighlighted) {
      backgroundColor = Color.alphaBlend(
        colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
        colorScheme.surface,
      );
    } else {
      backgroundColor = colorScheme.surface;
    }

    return Semantics(
      label: _semanticsLabel(),
      selected: isSelected,
      button: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: backgroundColor),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: _buildCellContent(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildCellContent(ThemeData theme) {
    if (cell.value != null) {
      final Color textColor;
      if (isConflict) {
        textColor = theme.colorScheme.error;
      } else if (cell.isGiven) {
        textColor = theme.colorScheme.onSurface;
      } else {
        textColor = theme.colorScheme.primary;
      }
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          cell.value.toString(),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: cell.isGiven ? FontWeight.w600 : FontWeight.w400,
            color: textColor,
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
                        ? theme.colorScheme.onSurfaceVariant
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
