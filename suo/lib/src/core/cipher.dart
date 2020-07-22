abstract class Cipher {
  String encrypt(String data);
  String decrypt(String data);
}

class CipherException implements Exception {
  final String message;
  final dynamic parent;

  const CipherException(this.message, [this.parent]);
}
