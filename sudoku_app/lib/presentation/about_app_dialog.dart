import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../l10n/generated/app_localizations.dart';

class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({super.key});

  static void show(BuildContext context) => showDialog<void>(
        context: context,
        builder: (_) => const AboutAppDialog(),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRu = Localizations.localeOf(context).languageCode == 'ru';
    final author = isRu ? 'Вячеслав Бобков' : 'Viacheslav Bobkov';
    final copyright = isRu
        ? '© 2026 $author.\nВсе права защищены.'
        : 'Copyright © 2026 $author.\nAll rights reserved.';

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      actionsPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/icons/app_icon.png',
              width: 80,
              height: 80,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.appTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '';
              return Text(
                version,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            copyright,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}
