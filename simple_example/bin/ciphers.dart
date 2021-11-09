import 'dart:convert';
import 'dart:typed_data';

import 'package:suo/suo.dart';

class B64Cipher implements Cipher {
  @override
  Uint8List decrypt(Uint8List data) => base64.decode(utf8.decode(data));

  @override
  Uint8List encrypt(Uint8List data) =>
      Uint8List.fromList(utf8.encode(base64.encode(data)));
}

class ReverseCipher implements Cipher {
  @override
  Uint8List decrypt(Uint8List data) =>
      Uint8List.fromList(List.from(data.reversed));

  @override
  Uint8List encrypt(Uint8List data) =>
      Uint8List.fromList(List.from(data.reversed));
}
