import 'package:flutter/material.dart';

/// A virtual numeric keypad for Sudoku input.
class NumberPad extends StatelessWidget {
  final void Function(int digit) onDigitPressed;
  final VoidCallback onClearPressed;
  final bool compact;

  const NumberPad({
    super.key,
    required this.onDigitPressed,
    required this.onClearPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // For desktop/compact mode, use fixed size
    if (compact) {
      return SizedBox(
        width: 240,
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: EdgeInsets.zero,
          children: [
            ...List.generate(9, (index) {
              final digit = index + 1;
              return _NumberPadButton(
                key: ValueKey('number_pad_$digit'),
                label: digit.toString(),
                onPressed: () => onDigitPressed(digit),
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                compact: compact,
              );
            }),
            _NumberPadButton(
              key: const ValueKey('number_pad_clear'),
              label: 'Clear',
              onPressed: onClearPressed,
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.onErrorContainer,
              compact: compact,
            ),
          ],
        ),
      );
    }
    
    // For mobile mode, allow flexible sizing
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.all(4),
      children: [
        ...List.generate(9, (index) {
          final digit = index + 1;
          return _NumberPadButton(
            key: ValueKey('number_pad_$digit'),
            label: digit.toString(),
            onPressed: () => onDigitPressed(digit),
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            compact: compact,
          );
        }),
        _NumberPadButton(
          key: const ValueKey('number_pad_clear'),
          label: 'Clear',
          onPressed: onClearPressed,
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
          compact: compact,
        ),
      ],
    );
  }
}

class _NumberPadButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool compact;

  const _NumberPadButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: compact ? 18 : null,
        ),
        padding: compact 
            ? const EdgeInsets.symmetric(vertical: 8, horizontal: 12)
            : const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(compact ? 6 : 8),
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
