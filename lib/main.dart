import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'di.dart';
import 'core/firebase_initializer.dart';
import 'core/auth_manager.dart';
import 'core/error_handlers.dart';
import 'core/app.dart';
import 'core/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 전역 에러 핸들러 설정
  ErrorHandlers.setupGlobalErrorHandlers();

  logger.i('[main] start');

  try {
    if (kDebugMode) {
      logger.i('[Startup] kDebugMode=true');
    }

    // Firebase 초기화
    await FirebaseInitializer.initialize();

    // 익명 인증 시도
    await AuthManager.signInAnonymouslyIfNotAuthenticated();

    // Debug healthcheck disabled to avoid early crashes before DI/runApp during iOS debugging.
    if (kDebugMode) {
      AuthManager.debugHealthcheck();
      logger.i('[Healthcheck] Skipped in debug build');
    }

    // 의존성 주입 초기화
    logger.i('[Startup] DiConfig.init start');
    await DiConfig.init();
    logger.i('[Startup] DiConfig.init done');
  } catch (e) {
    // If Firebase initialization fails, continue without Firebase
    // Initialize DI without Firebase dependencies
    logger.w('[Startup] Firebase initialization failed: $e, switching to local mode');
    try {
      await DiConfig.initWithoutFirebase();
      logger.i('[Startup] DiConfig.initWithoutFirebase completed');
    } catch (initError, initStackTrace) {
      logger.e(
        '[Startup] DiConfig.initWithoutFirebase failed: $initError',
        error: initError,
        stackTrace: initStackTrace,
      );
      // Don't rethrow, continue with app startup even if local DI fails
      logger.w('[Startup] Continuing with limited functionality');
    }
  }

  logger.i('[Startup] Before runApp');
  runApp(const OnceUponALineApp());
}
