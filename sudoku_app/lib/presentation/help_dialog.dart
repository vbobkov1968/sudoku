import 'dart:io';

import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class HelpPanel extends StatefulWidget {
  const HelpPanel({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => const HelpPanel(),
      );

  @override
  State<HelpPanel> createState() => _HelpPanelState();
}

class _HelpPanelState extends State<HelpPanel> {
  final _ctrl = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _buildRulesMarkdown(AppLocalizations l10n) {
    final buf = StringBuffer();
    buf.writeln('## ${l10n.helpRulesTitle}');
    buf.writeln();
    buf.writeln(l10n.helpRulesText);
    buf.writeln();
    buf.writeln('### ${l10n.helpHowFormedTitle}');
    buf.writeln();
    buf.writeln(l10n.helpHowFormedText);
    buf.writeln();
    buf.writeln('### ${l10n.helpDifficultyTitle}');
    buf.writeln();
    buf.writeln(l10n.helpDifficultyText
        .replaceAll('\n  • ', '\n- ')
        .replaceAll('\n• ', '\n- '));
    return buf.toString();
  }

  String _buildKeyboardMarkdown(AppLocalizations l10n) {
    final buf = StringBuffer();
    buf.writeln('## ${l10n.helpKeyboardTitle}');
    buf.writeln();
    for (final (key, desc) in [
      ('`1–9`', l10n.helpKeyboardDigitsDesc),
      ('`N`', l10n.helpKeyboardNDesc),
      ('`↑ ↓ ← →`', l10n.helpKeyboardArrowsDesc),
      ('`Backspace / Delete`', l10n.helpKeyboardBackspaceDesc),
      ('`⌘Z`', l10n.helpKeyboardUndoDesc),
      ('`⇧⌘Z`', l10n.helpKeyboardRedoDesc),
    ]) {
      buf.writeln('$key — $desc');
      buf.writeln();
    }
    return buf.toString();
  }

  Widget _buildToolbarSection(AppLocalizations l10n, ThemeData theme) {
    final style = theme.textTheme.bodyMedium;
    final boldStyle = style?.copyWith(fontWeight: FontWeight.bold);

    final items = <(List<IconData>, String, String)>[
      ([Icons.edit_note_outlined], l10n.notes, l10n.helpToolbarNotesDesc),
      ([Icons.highlight], l10n.highlightSameDigit, l10n.helpToolbarHighlightDesc),
      ([Icons.undo_outlined, Icons.redo_outlined], '${l10n.undo} / ${l10n.redo}', l10n.helpToolbarUndoDesc),
      ([Icons.backspace_outlined], l10n.clearCell, l10n.helpToolbarClearDesc),
      ([Icons.replay_outlined], l10n.resetPuzzle, l10n.helpToolbarResetDesc),
      ([Icons.casino_outlined], l10n.newGame, l10n.helpToolbarNewGameDesc),
      ([Icons.flag_outlined], l10n.saveMilestone, l10n.helpToolbarCheckpointSaveDesc),
      ([Icons.history], l10n.restoreMilestone, l10n.helpToolbarCheckpointRestoreDesc),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.helpToolbarTitle,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        ...items.map((item) {
          final (icons, label, desc) = item;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: icons.length > 1 ? 40 : 22,
                  child: Row(
                    children: icons.map((ic) => Icon(ic, size: 18)).toList(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: style,
                      children: [
                        TextSpan(text: label, style: boldStyle),
                        TextSpan(text: ' — $desc'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop =
        Platform.isMacOS || Platform.isWindows || Platform.isLinux;

    final styleSheet = MarkdownStyleSheet.fromTheme(theme).copyWith(
      h2: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      h3: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      p: theme.textTheme.bodyMedium,
      code: theme.textTheme.bodyMedium?.copyWith(
        fontFamily: 'monospace',
        fontWeight: FontWeight.w600,
        backgroundColor: theme.colorScheme.surface,
      ),
    );

    final double panelWidth = isDesktop ? 520 : size.width - 32;
    final double panelHeight = isDesktop
        ? (size.height * 0.72).clamp(420.0, 660.0)
        : size.height * 0.88;

    return Dialog(
      insetPadding: EdgeInsets.zero,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      child: SizedBox(
        width: panelWidth,
        height: panelHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.help, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Expanded(
                child: Scrollbar(
                  controller: _ctrl,
                  thumbVisibility: isDesktop,
                  child: SingleChildScrollView(
                    controller: _ctrl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MarkdownBody(
                          data: _buildRulesMarkdown(l10n),
                          styleSheet: styleSheet,
                        ),
                        const SizedBox(height: 12),
                        _buildToolbarSection(l10n, theme),
                        if (Platform.isMacOS) ...[
                          const SizedBox(height: 12),
                          MarkdownBody(
                            data: _buildKeyboardMarkdown(l10n),
                            styleSheet: styleSheet,
                          ),
                        ],
                      ],
                    ),
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
