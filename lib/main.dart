import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'di.dart';
import 'core/routers/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase using the default configuration files
    await Firebase.initializeApp();
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
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Once Upon A Line',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Pretendard',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3498DB),
          primary: const Color(0xFF3498DB),
          secondary: const Color(0xFF2C3E50),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFF2C3E50),
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
            color: Color(0xFF3498DB),
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
            borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
          ),
          hintStyle: const TextStyle(color: Color(0xFFB0B8C1)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3498DB),
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
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF3498DB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
