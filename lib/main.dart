import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'di.dart';
import 'core/routers/app_router.dart';
import 'core/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[main] start');

  try {
    if (kDebugMode) {
      debugPrint('[Startup] kDebugMode=true');
    }
    debugPrint('[Startup] Before Firebase.initializeApp');
    // Initialize Firebase using the default configuration files
    try {
      await Firebase.initializeApp().timeout(const Duration(seconds: 20));
    } on TimeoutException catch (_) {
      debugPrint('[Startup][Error] Firebase.initializeApp TIMEOUT (20s)');
      rethrow;
    } catch (e, st) {
      debugPrint('[Startup][Error] Firebase.initializeApp failed: $e');
      debugPrint('$st');
      rethrow;
    }
    debugPrint('[Startup] Firebase.initializeApp OK');
    // Ensure the user is authenticated (anonymous) to satisfy Firestore rules
    try {
      debugPrint('[Auth] Before signInAnonymously');
      await FirebaseAuth.instance.signInAnonymously().timeout(const Duration(seconds: 15));
      debugPrint('[Auth] signInAnonymously OK');
    } catch (_) {
      // If sign-in fails, continue; reads/writes that require auth will fail gracefully
      debugPrint('[Auth] signInAnonymously failed (continuing anonymously-restricted)');
    }

    // Debug-only: log current user and perform a lightweight Firestore healthcheck
    if (kDebugMode) {
      final logger = Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 8,
          lineLength: 100,
          colors: true,
          printEmojis: true,
        ),
      );
      final user = FirebaseAuth.instance.currentUser;
      debugPrint('[Auth] isAnonymous=${user?.isAnonymous} uid=${user?.uid}');
      try {
        // Note: Firestore disallows collection IDs that begin and end with double underscores
        // (e.g., `__healthchecks__`). Use a normal name to avoid `invalid-argument` errors.
        final docRef = FirebaseFirestore.instance.collection('healthchecks').doc('startup');
        await docRef.set({
          'ts': FieldValue.serverTimestamp(),
          'uid': user?.uid,
          'platform': 'flutter',
        }, SetOptions(merge: true));
        final snap = await docRef.get();
        debugPrint('[Healthcheck] Firestore write+read ok, exists=${snap.exists}');
      } catch (e, st) {
        debugPrint('[Healthcheck] Firestore failed: $e');
        debugPrint('$st');
      }

      // Debug-only probe: create/read a document in 'storySentences' to ensure the
      // collection is auto-created in Firestore when a write occurs.
      try {
        final probeDoc = FirebaseFirestore.instance
            .collection('story_sentences')
            .doc('debug_probe_startup');
        await probeDoc.set({
          '_debugProbe': true,
          'ts': FieldValue.serverTimestamp(),
          'uid': user?.uid,
        }, SetOptions(merge: true));
        final probeSnap = await probeDoc.get();
        logger.i("[Probe] storySentences created/read ok, exists=${probeSnap.exists}");
      } catch (e, st) {
        logger.e('[Probe] storySentences write/read failed: $e', error: e, stackTrace: st);
      }
    }
    await DiConfig.init();
  } catch (e) {
    // If Firebase initialization fails, continue without Firebase
    // Initialize DI without Firebase dependencies
    await DiConfig.initWithoutFirebase();
  }

  runApp(const OnceUponALineApp());
}

class OnceUponALineApp extends StatelessWidget {
  const OnceUponALineApp({super.key});

  @override
  Widget build(BuildContext context) {
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
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.logoEnd,
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
            color: AppColors.primary,
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
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          hintStyle: const TextStyle(color: Color(0xFFB0B8C1)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
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
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            foregroundColor: AppColors.primary,
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
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
        cardTheme: CardTheme(
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
