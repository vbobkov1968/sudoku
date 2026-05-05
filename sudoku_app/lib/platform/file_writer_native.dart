import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<bool> saveFileBytes(String suggestedName, Uint8List bytes) async {
  final path = await FilePicker.platform.saveFile(
    dialogTitle: 'Export Game',
    fileName: suggestedName,
    type: FileType.custom,
    allowedExtensions: ['sudoku'],
  );
  if (path == null) return false;
  await File(path).writeAsBytes(bytes);
  return true;
}
