import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;

void main() {
  final base64String = "gZdLu8o1/rNDKeOB2e7PXtaD9Rv4IVGaSvlDHz9UoD6uQTuHvM49enIHUnudRK3L";
  final keyString = "123456".padRight(32, '0');
  final key = enc.Key.fromUtf8(keyString);
  
  // Test 1: SIC mode, zero IV, with padding
  try {
    final encrypter = enc.Encrypter(enc.AES(key));
    final iv = enc.IV.fromLength(16);
    print("Test 1 (SIC, zero IV, padding): " + encrypter.decrypt64(base64String, iv: iv));
  } catch (e) {
    print("Test 1 failed: $e");
  }

  // Test 2: CBC mode
  try {
    final iv = enc.IV.fromUtf8(keyString.substring(0, 16));
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    print("Test 2 (CBC, key IV, padding): " + encrypter.decrypt64(base64String, iv: iv));
  } catch (e) {
    print("Test 2 failed: $e");
  }
}
