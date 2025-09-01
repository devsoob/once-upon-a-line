import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/works/presentation/pages/works_home_page.dart';
import '../../features/work/presentation/pages/work_detail_page.dart';
import '../../app/data/works_repository.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return const MaterialPage<void>(child: WorksHomePage());
        },
      ),
      GoRoute(
        path: '/work/:id',
        name: 'work_detail',
        pageBuilder: (BuildContext context, GoRouterState state) {
          final WorkDto? work = state.extra as WorkDto?;
          if (work == null) {
            return const MaterialPage<void>(child: Scaffold(body: Center(child: Text('잘못된 경로'))));
          }
          return MaterialPage<void>(child: WorkDetailPage(work: work));
        },
      ),
    ],
  );
}
