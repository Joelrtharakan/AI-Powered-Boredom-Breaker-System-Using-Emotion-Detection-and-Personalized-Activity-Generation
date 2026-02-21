import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;

void main() {
  final base64String =
      "gZdLu8o1/rNDKeOB2e7PXtaD9Rv4IVGaSvlDHz9UoD6uQTuHvM49enIHUnudRK3L";

  final keyString = "000000".padRight(32, '0');
  final key = enc.Key.fromUtf8(keyString);
  final encrypterSIC = enc.Encrypter(enc.AES(key));
  final zeroIv = enc.IV.fromLength(16);

  try {
    final decrypted = encrypterSIC.decrypt64(base64String, iv: zeroIv);
    print("SUCCESS! value: $decrypted");
  } catch (e) {
    print("Failed: $e");
  }
}
