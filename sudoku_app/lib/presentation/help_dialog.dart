import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  static void show(BuildContext context) {
    showDialog<void>(context: context, builder: (_) => const HelpDialog());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.72;
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520, maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.help, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Section(title: l10n.helpRulesTitle, children: [
                        _Body(l10n.helpRulesText),
                        const SizedBox(height: 10),
                        _SubTitle(l10n.helpHowFormedTitle),
                        _Body(l10n.helpHowFormedText),
                        const SizedBox(height: 10),
                        _SubTitle(l10n.helpDifficultyTitle),
                        _Body(l10n.helpDifficultyText),
                      ]),
                      _Section(title: l10n.helpToolbarTitle, children: [
                        _ToolbarRow(Icons.edit_note_outlined,    l10n.notes,                    l10n.helpToolbarNotesDesc),
                        _ToolbarRow(Icons.undo_outlined,         '${l10n.undo} / ${l10n.redo}', l10n.helpToolbarUndoDesc),
                        _ToolbarRow(Icons.backspace_outlined,    l10n.clearCell,                l10n.helpToolbarClearDesc),
                        _ToolbarRow(Icons.replay_outlined,       l10n.resetPuzzle,              l10n.helpToolbarResetDesc),
                        _ToolbarRow(Icons.casino_outlined,       l10n.newGame,                  l10n.helpToolbarNewGameDesc),
                        _ToolbarRow(Icons.flag_outlined,         l10n.saveMilestone,            l10n.helpToolbarCheckpointSaveDesc),
                        _ToolbarRow(Icons.history,               l10n.restoreMilestone,         l10n.helpToolbarCheckpointRestoreDesc),
                      ]),
                      if (Platform.isMacOS)
                        _Section(title: l10n.helpKeyboardTitle, children: [
                          _KeyboardTable(rows: [
                            ('1–9',                   l10n.helpKeyboardDigitsDesc),
                            ('N',                     l10n.helpKeyboardNDesc),
                            ('↑ ↓ ← →',              l10n.helpKeyboardArrowsDesc),
                            ('Backspace / Delete',     l10n.helpKeyboardBackspaceDesc),
                            ('⌘Z',                    l10n.helpKeyboardUndoDesc),
                            ('⇧⌘Z',                  l10n.helpKeyboardRedoDesc),
                          ]),
                        ]),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  final String text;
  const _SubTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Theme.of(context).textTheme.bodyMedium);
  }
}

class _ToolbarRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;

  const _ToolbarRow(this.icon, this.label, this.description);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                      text: '$label — ',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyboardTable extends StatelessWidget {
  final List<(String, String)> rows;
  const _KeyboardTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    final monoStyle = style?.copyWith(
        fontFamily: 'monospace', fontWeight: FontWeight.w600);
    return Table(
      columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows.map((r) {
        final (key, desc) = r;
        return TableRow(children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
            child: Text(key, style: monoStyle),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
            child: Text(desc, style: style),
          ),
        ]);
      }).toList(),
    );
  }
}
