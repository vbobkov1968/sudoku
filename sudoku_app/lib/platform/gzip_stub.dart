import 'dart:typed_data';

// On web GZipCodec is unavailable; store raw bytes (no compression).
Uint8List gzipEncode(List<int> bytes) => Uint8List.fromList(bytes);
List<int> gzipDecode(List<int> bytes) => bytes;
