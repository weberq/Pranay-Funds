// lib/configs/app_config.dart

class AppConfig {
  // Base URL for your API
  // Base URL for your API
  static const String baseUrl = 'https://apis-funds.xweber.in';
  // static const String baseUrl =
  // 'http://10.0.2.2/apis-funds'; // Localhost for Android Emulator
  // static const String baseUrl =
  // 'http://localhost/apis-funds'; // <-- Use your local server URL for development

  // Your X-API-KEY
  // Defined in launch.json or passed via --dart-define
  static const String apiKey = String.fromEnvironment('API_KEY');
}
