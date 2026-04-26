import 'package:flutter/material.dart';

/// A virtual numeric keypad for Sudoku input.
class NumberPad extends StatelessWidget {
  final void Function(int digit) onDigitPressed;

  const NumberPad({
    super.key,
    required this.onDigitPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(4),
      children: List.generate(9, (index) {
        final digit = index + 1;
        return _NumberPadButton(
          key: ValueKey('number_pad_$digit'),
          label: digit.toString(),
          onPressed: () => onDigitPressed(digit),
          borderColor: colorScheme.outline,
        );
      }),
    );
  }
}

class _NumberPadButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color borderColor;

  const _NumberPadButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        side: BorderSide(
          color: borderColor.withOpacity(0.3),
          width: 1.0,
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 1.0,
        ),
      ),
    );
  }
}
