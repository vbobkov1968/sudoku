import 'dart:io';

import 'package:flutter_acrylic/flutter_acrylic.dart';

Future<void> initWindowEffects() async {
  if (Platform.isMacOS || Platform.isAndroid || Platform.isIOS) return;
  await Window.initialize();
  await Window.setEffect(
    effect: Platform.isWindows ? WindowEffect.acrylic : WindowEffect.transparent,
  );
}
