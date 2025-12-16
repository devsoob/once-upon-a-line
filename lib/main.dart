import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'di.dart';
import 'core/routers/app_router.dart';
import 'core/constants/app_colors.dart';
import 'core/logger.dart';
import 'core/constants/timeouts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Global error handlers (minimal, for crash diagnostics)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    logger.e(
      '[GlobalError][FlutterError] ${details.exceptionAsString()}',
      error: details.exception,
      stackTrace: details.stack,
    );
  };
  WidgetsBinding.instance.platformDispatcher.onError = (Object error, StackTrace stack) {
    logger.e('[GlobalError][Platform] $error', error: error, stackTrace: stack);
    return true; // prevent silent crash to surface logs
  };
  logger.i('[main] start');

  try {
    if (kDebugMode) {
      logger.i('[Startup] kDebugMode=true');
    }
    logger.i('[Startup] Before Firebase.initializeApp');

    // Initialize Firebase with options
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "YOUR_API_KEY", // 실제 값으로 대체 필요
          appId: "YOUR_APP_ID", // 실제 값으로 대체 필요
          messagingSenderId: "YOUR_SENDER_ID", // 실제 값으로 대체 필요
          projectId: "YOUR_PROJECT_ID", // 실제 값으로 대체 필요
          // 다른 필요한 옵션들 추가
        ),
      ).timeout(AppTimeouts.firebaseInit);
    } on TimeoutException catch (_) {
      logger.e(
        '[Startup][Error] Firebase.initializeApp TIMEOUT (${AppTimeouts.firebaseInit.inSeconds}s)',
      );
      rethrow;
    } catch (e, st) {
      logger.e('[Startup][Error] Firebase.initializeApp failed: $e', error: e, stackTrace: st);
      rethrow;
    }

    logger.i('[Startup] Firebase.initializeApp OK');

    // 익명 인증 시도
    try {
      logger.i('[Auth] Before signInAnonymously');
      final auth = FirebaseAuth.instance;

      // 이미 로그인된 사용자가 있는지 확인
      if (auth.currentUser == null) {
        await auth.signInAnonymously().timeout(const Duration(seconds: 10));
        logger.i('[Auth] signInAnonymously success: ${auth.currentUser?.uid}');
      } else {
        logger.i('[Auth] Already signed in: ${auth.currentUser?.uid}');
      }
      await FirebaseAuth.instance.signInAnonymously().timeout(AppTimeouts.anonymousSignIn);
      logger.i('[Auth] signInAnonymously OK');

      // Verify authentication succeeded
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || !user.isAnonymous) {
        logger.e('[Auth] Authentication failed - no valid user after signInAnonymously');
        throw Exception('Authentication failed - no valid user');
      }
      logger.i('[Auth] Successfully authenticated anonymously: ${user.uid}');
    } catch (e, st) {
      logger.e('[Auth] signInAnonymously failed: $e', error: e, stackTrace: st);

      // Check if user is already authenticated (might be a cached session)
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.isAnonymous) {
        logger.i('[Auth] Using existing anonymous session: ${currentUser.uid}');
        // Continue with existing session
      } else {
        // If sign-in fails and no existing session, switch to local mode
        logger.w(
          '[Auth] No existing session and signInAnonymously failed, switching to local mode',
        );
        // Don't throw error, continue with local mode initialization
      }
    }

    // Debug healthcheck disabled to avoid early crashes before DI/runApp during iOS debugging.
    if (kDebugMode) {
      final user = FirebaseAuth.instance.currentUser;
      logger.i('[Auth] isAnonymous=${user?.isAnonymous} uid=${user?.uid}');
      logger.i('[Healthcheck] Skipped in debug build');
    }
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

class OnceUponALineApp extends StatelessWidget {
  const OnceUponALineApp({super.key});

  @override
  Widget build(BuildContext context) {
    logger.d('[UI] OnceUponALineApp.build');
    // 시스템 UI 스타일 지정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Once Upon A Line',
      builder: (BuildContext context, Widget? child) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            final FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          },
          child: child,
        );
      },
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Pretendard',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF222222),
          primary: const Color(0xFF222222),
          secondary: const Color(0xFF4A4A4A),
          surface: AppColors.surface,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF222222),
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Color(0xFF222222),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w800,
            fontSize: 32,
            color: Color(0xFF222222),
          ),
          titleLarge: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: Color(0xFF222222),
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Color(0xFF222222),
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF222222),
          ),
          labelLarge: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF222222),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF7F8FA),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF222222), width: 2),
          ),
          hintStyle: const TextStyle(color: Color(0xFFB0B8C1)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF222222),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF222222), width: 1.5),
            foregroundColor: const Color(0xFF222222),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF222222),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
