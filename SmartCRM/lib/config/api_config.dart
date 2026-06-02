import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'http://localhost:3333';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:3333';
      default:
        return 'http://localhost:3333';
    }
  }
}
