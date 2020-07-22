import 'dart:convert';

import 'package:suo/suo.dart';

class B64Cipher implements Cipher {
  @override
  String decrypt(String data) => utf8.decode(base64.decode(data));

  @override
  String encrypt(String data) => base64.encode(utf8.encode(data));
}

class ReverseCipher implements Cipher {
  @override
  String decrypt(String data) => data.split('').reversed.join();

  @override
  String encrypt(String data) => data.split('').reversed.join();
}
