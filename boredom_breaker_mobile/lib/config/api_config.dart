class ApiConfig {
  static String get baseUrl {
    // 1. Used Mac's local network IP so physical devices (like iPhone) can connect
    return 'http://172.20.10.3:8000/api';
  }
}
