import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  /// UI-only mode: no Firebase, backend, or API keys required.
  static const bool demoMode = false;

  static String get backendUrl => dotenv.env['BACKEND_URL'] ?? 'http://10.0.2.2:8000';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get openWeatherApiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  // API Endpoints
  static String get authVerifyEndpoint => '/api/auth/verify';
  static String get moodEndpoint => '/api/mood';
  static String get predictionEndpoint => '/api/predict/burnout';
  static String get chatEndpoint => '/api/chat/message';
  static String get recommendationsEndpoint => '/api/recommendations';

  // Responsive Breakpoints
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 1024.0;
}
