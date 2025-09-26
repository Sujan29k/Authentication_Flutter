import 'dart:io';

class ApiConfig {
  // Configure base URL based on platform and environment
  static const String _localhostAndroid = 'http://10.0.2.2:3000';
  static const String _localhostiOS = 'http://127.0.0.1:3000';
  static const String _production = 'https://your-production-url.com';

  static String get baseUrl {
    // Automatically detect platform
    if (Platform.isAndroid) {
      return _localhostAndroid;
    } else if (Platform.isIOS) {
      return _localhostiOS;
    } else {
      // For web or other platforms, you might want to use production
      return _production;
    }
  }

  static String get authBaseUrl => '$baseUrl/api/auth';
  static String get itemsBaseUrl => '$baseUrl/api/items';
}
