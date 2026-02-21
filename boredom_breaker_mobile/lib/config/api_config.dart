class ApiConfig {
  static String get baseUrl {
    // Changed to 127.0.0.1 which works in iOS Simulator.
    // NOTE: If using a real iPhone device, you MUST restart your backend with:
    // uvicorn app.main:app --reload --host 0.0.0.0
    // and use your Mac's IP (e.g., 172.20.10.3) instead.
    return 'http://127.0.0.1:8000/api';
  }
}
