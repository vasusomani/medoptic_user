import 'dart:convert';
import 'dart:io';

class gZipCompression {
  static String compress(String data) {
    final enCodedJson = utf8.encode(data);
    final gZipJson = gzip.encode(enCodedJson);
    return base64.encode(gZipJson);
  }

  static String decompress(String data) {
    final decodeBase64Json = base64.decode(data);
    final decodegZipJson = gzip.decode(decodeBase64Json);
    return utf8.decode(decodegZipJson);
  }
}
