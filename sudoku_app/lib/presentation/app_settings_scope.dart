import 'package:flutter/widgets.dart';
import '../core/models/app_settings.dart';
import '../data/persistence/settings_persistence.dart';

class AppSettingsNotifier extends ValueNotifier<AppSettings> {
  AppSettingsNotifier(super.value);

  void update(AppSettings newSettings) {
    value = newSettings;
    SettingsPersistence.save(newSettings);
  }
}

class AppSettingsScope extends InheritedNotifier<AppSettingsNotifier> {
  const AppSettingsScope({
    super.key,
    required AppSettingsNotifier super.notifier,
    required super.child,
  });

  static AppSettingsNotifier read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppSettingsScope>()!.notifier!;
}
