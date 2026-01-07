import 'package:firebase_core/firebase_core.dart';
import '../core/logger.dart';
import 'constants/timeouts.dart';

class FirebaseInitializer {
  static Future<void> initialize() async {
    logger.i('[Startup] Before Firebase.initializeApp');

    try {
      // Firebase가 이미 초기화되었는지 확인
      Firebase.app(); // 자동 초기화된 앱 확인
      logger.i('[Startup] Firebase auto-initialized successfully');
    } catch (e) {
      // 자동 초기화가 안된 경우 수동으로 초기화
      logger.i('[Startup] Firebase not auto-initialized, initializing manually');
      try {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyARW5YGOtexRzcTrRnR-Hvi3jE9_eSr3DY",
            appId: "1:979113860830:ios:984768359dfdb5931eac4f",
            messagingSenderId: "979113860830",
            projectId: "once-upon-a-line",
            storageBucket: "once-upon-a-line.firebasestorage.app",
          ),
        ).timeout(AppTimeouts.firebaseInit);
        logger.i('[Startup] Firebase.initializeApp OK (manual initialization)');
      } catch (initError, initStack) {
        logger.e(
          '[Startup][Error] Firebase.initializeApp failed: $initError',
          error: initError,
          stackTrace: initStack,
        );
        rethrow;
      }
    }

    logger.i('[Startup] Firebase.initializeApp OK');
  }
}
