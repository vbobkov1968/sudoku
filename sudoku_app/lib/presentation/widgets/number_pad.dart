import 'package:flutter/material.dart';

/// A virtual numeric keypad for Sudoku input.
class NumberPad extends StatelessWidget {
  final void Function(int digit) onDigitPressed;

  /// Digits that are valid for the selected cell and not yet noted — full highlight.
  final Set<int>? availableDigits;

  /// Digits that are valid for the selected cell and already in notes — border-only highlight.
  final Set<int>? notedAvailableDigits;

  const NumberPad({
    super.key,
    required this.onDigitPressed,
    this.availableDigits,
    this.notedAvailableDigits,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark ? const Color(0xFF66BB6A) : const Color(0xFF43A047);

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      padding: const EdgeInsets.all(2),
      children: List.generate(9, (index) {
        final digit = index + 1;
        final isFullHint = availableDigits?.contains(digit) ?? false;
        final isBorderHint = notedAvailableDigits?.contains(digit) ?? false;
        return _NumberPadButton(
          key: ValueKey('number_pad_$digit'),
          label: digit.toString(),
          onPressed: () => onDigitPressed(digit),
          borderColor: (isFullHint || isBorderHint) ? hintColor : colorScheme.outline,
          highlightBorder: isFullHint || isBorderHint,
          highlightBackground: isFullHint,
        );
      }),
    );
  }
}

class _NumberPadButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color borderColor;
  final bool highlightBorder;
  final bool highlightBackground;

  const _NumberPadButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.borderColor,
    this.highlightBorder = false,
    this.highlightBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: highlightBackground
            ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
            : colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(
          color: highlightBorder ? borderColor : borderColor.withValues(alpha: 0.3),
          width: highlightBorder ? 2.5 : 1.0,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
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
