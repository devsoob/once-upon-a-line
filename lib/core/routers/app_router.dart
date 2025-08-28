import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/write/presentation/pages/write_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return const MaterialPage<void>(child: HomePage());
        },
      ),
      GoRoute(
        path: '/write',
        name: 'write',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return const MaterialPage<void>(child: WritePage());
        },
      ),
    ],
  );
}

