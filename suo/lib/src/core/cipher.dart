import 'dart:typed_data';

abstract class Cipher {
  Uint8List encrypt(Uint8List data);
  Uint8List decrypt(Uint8List data);
}

class CipherException implements Exception {
  final String message;
  final dynamic parent;

  const CipherException(this.message, [this.parent]);
}
