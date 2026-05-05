import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

// On web: triggers a browser download of the given bytes.
Future<bool> saveFileBytes(String suggestedName, Uint8List bytes) async {
  final blob = Blob(
    [bytes.toJS].toJS,
    BlobPropertyBag(type: 'application/octet-stream'),
  );
  final url = URL.createObjectURL(blob);
  final anchor = document.createElement('a') as HTMLAnchorElement
    ..href = url
    ..download = suggestedName;
  document.body!.appendChild(anchor);
  anchor.click();
  document.body!.removeChild(anchor);
  URL.revokeObjectURL(url);
  return true;
}
