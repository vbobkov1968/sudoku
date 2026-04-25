import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../core/models/difficulty.dart';

class DifficultyPickerDialog extends StatefulWidget {
  final Difficulty initial;

  const DifficultyPickerDialog({super.key, required this.initial});

  /// Shows the picker and returns the chosen [Difficulty], or null if cancelled.
  static Future<Difficulty?> show(
    BuildContext context,
    Difficulty initial,
  ) =>
      showDialog<Difficulty>(
        context: context,
        builder: (_) => DifficultyPickerDialog(initial: initial),
      );

  @override
  State<DifficultyPickerDialog> createState() => _DifficultyPickerDialogState();
}

class _DifficultyPickerDialogState extends State<DifficultyPickerDialog> {
  late Difficulty _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final labels = {
      Difficulty.easy:   l10n.difficultyEasy,
      Difficulty.medium: l10n.difficultyMedium,
      Difficulty.hard:   l10n.difficultyHard,
      Difficulty.expert: l10n.difficultyExpert,
    };

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Row(children: [
        Icon(Icons.casino_outlined, size: 20, color: colorScheme.primary),
        const SizedBox(width: 10),
        Text(l10n.newGame),
      ]),
      // Zero horizontal padding so radio tiles reach the edges naturally.
      contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: Difficulty.values
            .map((d) => RadioListTile<Difficulty>(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(labels[d]!),
                  value: d,
                  groupValue: _selected,
                  activeColor: colorScheme.primary,
                  onChanged: (v) => setState(() => _selected = v!),
                ))
            .toList(),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          style: FilledButton.styleFrom(
            minimumSize: const Size(64, 32),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            textStyle: const TextStyle(fontSize: 13),
          ),
          child: Text(l10n.newGame),
        ),
      ],
    );
  }
}
