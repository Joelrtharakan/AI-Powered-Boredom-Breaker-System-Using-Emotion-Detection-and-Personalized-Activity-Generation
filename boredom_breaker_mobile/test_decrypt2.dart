import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;

void main() {
  final base64String =
      "gZdLu8o1/rNDKeOB2e7PXtaD9Rv4IVGaSvlDHz9UoD6uQTuHvM49enIHUnudRK3L";
  final keyString = "123456".padRight(32, '0');
  final key = enc.Key.fromUtf8(keyString);

  // Test 3: SIC mode, zero IV, NO padding
  try {
    final encrypter = enc.Encrypter(
      enc.AES(key, mode: enc.AESMode.sic, padding: null),
    );
    final iv = enc.IV.fromLength(16);
    print(
      "Test 3 (SIC, zero IV, no padding): " +
          encrypter.decrypt64(base64String, iv: iv),
    );
  } catch (e) {
    print("Test 3 failed: $e");
  }
}
