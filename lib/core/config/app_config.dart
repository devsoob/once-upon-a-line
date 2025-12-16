import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Firebase 관련 설정
  static String get firebaseApiKey => _get('FIREBASE_API_KEY');
  static String get firebaseAuthDomain => _get('FIREBASE_AUTH_DOMAIN');
  static String get firebaseProjectId => _get('FIREBASE_PROJECT_ID');
  static String get firebaseStorageBucket => _get('FIREBASE_STORAGE_BUCKET');
  static String get firebaseMessagingSenderId => _get('FIREBASE_MESSAGING_SENDER_ID');
  static String get firebaseAppId => _get('FIREBASE_APP_ID');
  static String get firebaseMeasurementId => _get('FIREBASE_MEASUREMENT_ID');

  // 앱 설정
  static String get appName => _get('APP_NAME', 'Once Upon A Line');
  static String get appVersion => _get('APP_VERSION', '1.0.0');
  static bool get isProduction => _get('ENV', 'development') == 'production';

  // API 엔드포인트
  static String get apiBaseUrl => _get('API_BASE_URL', 'https://api.example.com');

  // 기타 설정
  static int get defaultPageSize => int.tryParse(_get('DEFAULT_PAGE_SIZE', '20')) ?? 20;

  // 환경 변수 로드
  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
  }

  // 환경 변수 가져오기 (기본값 제공 가능)
  static String _get(String key, [String? defaultValue]) {
    final value = dotenv.env[key];
    if (value != null && value.isNotEmpty) {
      return value;
    }
    if (defaultValue != null) {
      return defaultValue;
    }
    throw Exception('환경 변수 $key가 설정되지 않았습니다.');
  }
}

// 사용 예시:
// 1. main() 함수에서 로드:
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await AppConfig.load();
//   runApp(MyApp());
// }
//
// 2. 사용:
// final apiKey = AppConfig.firebaseApiKey;
// final isProd = AppConfig.isProduction;
