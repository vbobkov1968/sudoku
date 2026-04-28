import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
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
                  child: RadioGroup<ThemeMode>(
                    groupValue: settings.themeMode,
                    onChanged: (v) {
                      if (v != null) notifier.update(settings.withTheme(v));
                    },
                    child: _SettingsColumn(label: l10n.theme, children: [
                      _RadioItem<ThemeMode>(
                        label: l10n.themeLight,
                        value: ThemeMode.light,
                        onChanged: (v) => notifier.update(settings.withTheme(v)),
                      ),
                      _RadioItem<ThemeMode>(
                        label: l10n.themeDark,
                        value: ThemeMode.dark,
                        onChanged: (v) => notifier.update(settings.withTheme(v)),
                      ),
                      _RadioItem<ThemeMode>(
                        label: l10n.themeSystem,
                        value: ThemeMode.system,
                        onChanged: (v) => notifier.update(settings.withTheme(v)),
                      ),
                    ]),
                  ),
                ),
                Expanded(
                  child: RadioGroup<String>(
                    groupValue: settings.locale.languageCode,
                    onChanged: (v) {
                      if (v != null) notifier.update(settings.withLocale(Locale(v)));
                    },
                    child: _SettingsColumn(label: l10n.language, children: [
                      _RadioItem<String>(
                        label: l10n.languageEnglish,
                        value: 'en',
                        onChanged: (v) => notifier.update(settings.withLocale(Locale(v))),
                      ),
                      _RadioItem<String>(
                        label: l10n.languageRussian,
                        value: 'ru',
                        onChanged: (v) => notifier.update(settings.withLocale(Locale(v))),
                      ),
                    ]),
                  ),
                ),
                Expanded(
                  child: RadioGroup<Difficulty>(
                    groupValue: settings.difficulty,
                    onChanged: (v) {
                      if (v != null) notifier.update(settings.withDifficulty(v));
                    },
                    child: _SettingsColumn(label: l10n.difficulty, children: [
                      _RadioItem<Difficulty>(
                        label: l10n.difficultyEasy,
                        value: Difficulty.easy,
                        onChanged: (v) => notifier.update(settings.withDifficulty(v)),
                      ),
                      _RadioItem<Difficulty>(
                        label: l10n.difficultyMedium,
                        value: Difficulty.medium,
                        onChanged: (v) => notifier.update(settings.withDifficulty(v)),
                      ),
                      _RadioItem<Difficulty>(
                        label: l10n.difficultyHard,
                        value: Difficulty.hard,
                        onChanged: (v) => notifier.update(settings.withDifficulty(v)),
                      ),
                      _RadioItem<Difficulty>(
                        label: l10n.difficultyExpert,
                        value: Difficulty.expert,
                        onChanged: (v) => notifier.update(settings.withDifficulty(v)),
                      ),
                    ]),
                  ),
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
  final void Function(T) onChanged;

  const _RadioItem({
    super.key,
    required this.label,
    required this.value,
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
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 11)),
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
