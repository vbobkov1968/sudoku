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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: notifier,
      builder: (context, settings, _) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
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
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          content: SizedBox(
            width: 400,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _SettingsColumn(label: l10n.theme, children: [
                    _RadioItem<ThemeMode>(
                      label: l10n.themeLight,
                      value: ThemeMode.light,
                      groupValue: settings.themeMode,
                      onChanged: (v) =>
                          notifier.update(settings.withTheme(v)),
                    ),
                    _RadioItem<ThemeMode>(
                      label: l10n.themeDark,
                      value: ThemeMode.dark,
                      groupValue: settings.themeMode,
                      onChanged: (v) =>
                          notifier.update(settings.withTheme(v)),
                    ),
                    _RadioItem<ThemeMode>(
                      label: l10n.themeSystem,
                      value: ThemeMode.system,
                      groupValue: settings.themeMode,
                      onChanged: (v) =>
                          notifier.update(settings.withTheme(v)),
                    ),
                  ]),
                ),
                Expanded(
                  child: _SettingsColumn(label: l10n.language, children: [
                    _RadioItem<String>(
                      label: l10n.languageEnglish,
                      value: 'en',
                      groupValue: settings.locale.languageCode,
                      onChanged: (v) =>
                          notifier.update(settings.withLocale(Locale(v))),
                    ),
                    _RadioItem<String>(
                      label: l10n.languageRussian,
                      value: 'ru',
                      groupValue: settings.locale.languageCode,
                      onChanged: (v) =>
                          notifier.update(settings.withLocale(Locale(v))),
                    ),
                  ]),
                ),
                Expanded(
                  child: _SettingsColumn(label: l10n.difficulty, children: [
                    _RadioItem<Difficulty>(
                      label: l10n.difficultyEasy,
                      value: Difficulty.easy,
                      groupValue: settings.difficulty,
                      onChanged: (v) =>
                          notifier.update(settings.withDifficulty(v)),
                    ),
                    _RadioItem<Difficulty>(
                      label: l10n.difficultyMedium,
                      value: Difficulty.medium,
                      groupValue: settings.difficulty,
                      onChanged: (v) =>
                          notifier.update(settings.withDifficulty(v)),
                    ),
                    _RadioItem<Difficulty>(
                      label: l10n.difficultyHard,
                      value: Difficulty.hard,
                      groupValue: settings.difficulty,
                      onChanged: (v) =>
                          notifier.update(settings.withDifficulty(v)),
                    ),
                    _RadioItem<Difficulty>(
                      label: l10n.difficultyExpert,
                      value: Difficulty.expert,
                      groupValue: settings.difficulty,
                      onChanged: (v) =>
                          notifier.update(settings.withDifficulty(v)),
                    ),
                  ]),
                ),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.zero,
        );
      },
    );
  }
}

class _SettingsColumn extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _SettingsColumn({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _SectionLabel(label),
        const SizedBox(height: 6),
        ...children,
      ],
    );
  }
}

class _RadioItem<T> extends StatelessWidget {
  final String label;
  final T value;
  final T groupValue;
  final void Function(T) onChanged;

  const _RadioItem({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        children: [
          Radio<T>(
            value: value,
            groupValue: groupValue,
            onChanged: (_) => onChanged(value),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
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
