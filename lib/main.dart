import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
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
        statusBarIconBrightness:
            Platform.isAndroid ? Brightness.dark : Brightness.light,
        statusBarBrightness:
            Platform.isAndroid ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Once Upon A Line',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Pretendard',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Once Upon A Line'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          '하루에 한 문장,\n릴레이 소설을 시작해보세요.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
