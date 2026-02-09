import 'package:flutter/foundation.dart'; // Safe for Web & Mobile, provides defaultTargetPlatform

class ApiConfig {
  static String get baseUrl {
    // 1. Web Check First (Important!)
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    
    // 2. Mobile Platform Checks using defaultTargetPlatform (Safe)
    if (defaultTargetPlatform == TargetPlatform.android) {
       return 'http://10.0.2.2:8000/api';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
       return 'http://127.0.0.1:8000/api';
    }
    
    // Default fallback (Linux, Windows, macOS)
    return 'http://localhost:8000/api';
  }
}
