import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;

void main() {
  final base64String =
      "gZdLu8o1/rNDKeOB2e7PXtaD9Rv4IVGaSvlDHz9UoD6uQTuHvM49enIHUnudRK3L";

  final candidates = ["000000", "123456", "111111", "999999", "123123"];

  for (final passcode in candidates) {
    print("Trying $passcode");
    try {
      final keyString = passcode.padRight(32, '0');
      final key = enc.Key.fromUtf8(keyString);
      final encrypterSIC = enc.Encrypter(enc.AES(key));
      final zeroIv = enc.IV.fromLength(16);
      final decrypted = encrypterSIC.decrypt64(base64String, iv: zeroIv);
      print("SUCCESS! Passcode: $passcode, value: $decrypted");
      return;
    } catch (e) {
      // Ignored
    }
  }
}
