import 'dart:io';

class ApiConfig {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web.
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else if (Platform.isIOS) {
      return 'http://127.0.0.1:8000/api';
    }
    return 'http://localhost:8000/api';
  }
}
