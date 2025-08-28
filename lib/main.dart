import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'di.dart';
import 'core/routers/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DiConfig.init();
  runApp(const OnceUponALineApp());
}

class OnceUponALineApp extends StatelessWidget {
  const OnceUponALineApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 시스템 UI 스타일 지정
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Platform.isAndroid ? Brightness.dark : Brightness.light,
        statusBarBrightness: Platform.isAndroid ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Once Upon A Line',
      theme: ThemeData(scaffoldBackgroundColor: Colors.white, fontFamily: 'Pretendard'),
      routerConfig: AppRouter.router,
    );
  }
}
