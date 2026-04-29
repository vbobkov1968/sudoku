import 'package:flutter/material.dart';
import '../../core/models/game_state.dart';
import '../../l10n/generated/app_localizations.dart';

class SolutionOverlay extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onDismiss;

  const SolutionOverlay({
    super.key,
    required this.gameState,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.85),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: _buildGrid(context),
                    ),
                  ),
                ),
              ),
              Text(
                l10n.tapToClose,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white38,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return Stack(
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

    return Center(
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
