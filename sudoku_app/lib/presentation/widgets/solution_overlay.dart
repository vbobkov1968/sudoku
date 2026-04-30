import 'package:flutter/material.dart';
import '../../core/models/game_state.dart';

/// Renders the 9x9 solution grid (no background, no positioning).
/// Positioning and dark background are handled by the caller.
class SolutionGrid extends StatelessWidget {
  final GameState gameState;

  const SolutionGrid({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: Colors.black)),
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
            return _buildCell(context, row, col);
          },
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _SolutionGridPainter()),
          ),
        ),
      ],
    );
  }

  Widget _buildCell(BuildContext context, int row, int col) {
    final solutionValue = gameState.solutionBoard.getCell(row, col).value!;
    final currentValue = gameState.currentBoard.getCell(row, col).value;
    final isGiven = gameState.initialBoard.getCell(row, col).isGiven;

    final Color textColor;
    if (isGiven) {
      textColor = Colors.white.withValues(alpha: 0.45);
    } else if (currentValue == solutionValue) {
      textColor = Colors.white.withValues(alpha: 0.80);
    } else {
      textColor = Colors.amber;
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          solutionValue.toString(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: textColor,
            fontWeight: isGiven ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SolutionGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final thin = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..strokeWidth = 0.5
      ..isAntiAlias = false;

    final thick = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1.5
      ..isAntiAlias = false;

    for (int i = 1; i < 9; i++) {
      final paint = i % 3 == 0 ? thick : thin;
      final pos = (size.width * i / 9).roundToDouble();
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), paint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), paint);
    }
  }

  @override
  bool shouldRepaint(_SolutionGridPainter old) => false;
}
