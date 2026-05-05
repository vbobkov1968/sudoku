import 'dart:io';
import 'dart:typed_data';

Uint8List gzipEncode(List<int> bytes) =>
    Uint8List.fromList(GZipCodec().encode(bytes));

List<int> gzipDecode(List<int> bytes) => GZipCodec().decode(bytes);
