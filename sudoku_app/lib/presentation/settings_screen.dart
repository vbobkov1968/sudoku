import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../core/models/app_settings.dart';
import '../core/models/difficulty.dart';
import 'app_settings_scope.dart';

class SettingsDialog extends StatelessWidget {
  final AppSettingsNotifier notifier;

  const SettingsDialog({super.key, required this.notifier});

  static void show(BuildContext context) => showDialog<void>(
        context: context,
        builder: (_) => SettingsDialog(notifier: AppSettingsScope.read(context)),
      );

  static String _difficultyLabel(Difficulty d, AppLocalizations l10n) {
    switch (d) {
      case Difficulty.easy:   return l10n.difficultyEasy;
      case Difficulty.medium: return l10n.difficultyMedium;
      case Difficulty.hard:   return l10n.difficultyHard;
      case Difficulty.expert: return l10n.difficultyExpert;
    }
  }

  static const _segmentStyle = ButtonStyle(
    visualDensity: VisualDensity.compact,
    textStyle: MaterialStatePropertyAll(TextStyle(fontSize: 12)),
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: notifier,
      builder: (context, settings, _) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          // Smaller inset so the dialog can use more of a narrow window.
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          title: Row(
            children: [
              Icon(Icons.settings_outlined,
                  size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Text(l10n.settings),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(64, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  textStyle: const TextStyle(fontSize: 13),
                ),
                child: Text(l10n.done),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(l10n.theme),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                          value: ThemeMode.light,
                          label: Text(l10n.themeLight)),
                      ButtonSegment(
                          value: ThemeMode.dark, label: Text(l10n.themeDark)),
                      ButtonSegment(
                          value: ThemeMode.system,
                          label: Text(l10n.themeSystem)),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (s) =>
                        notifier.update(settings.withTheme(s.first)),
                    style: _segmentStyle,
                  ),
                ),
                const SizedBox(height: 20),
                _SectionLabel(l10n.language),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                          value: 'en', label: Text(l10n.languageEnglish)),
                      ButtonSegment(
                          value: 'ru', label: Text(l10n.languageRussian)),
                    ],
                    selected: {settings.locale.languageCode},
                    onSelectionChanged: (s) =>
                        notifier.update(settings.withLocale(Locale(s.first))),
                    style: _segmentStyle,
                  ),
                ),
                const SizedBox(height: 20),
                _SectionLabel(l10n.difficulty),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final d in Difficulty.values)
                      ChoiceChip(
                        label: Text(_difficultyLabel(d, l10n)),
                        selected: settings.difficulty == d,
                        showCheckmark: false,
                        onSelected: (_) =>
                            notifier.update(settings.withDifficulty(d)),
                        labelStyle: const TextStyle(fontSize: 12),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.zero,
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}
