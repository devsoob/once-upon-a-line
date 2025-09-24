import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_line/features/story_rooms/presentation/pages/story_rooms_home_page.dart';
import 'package:once_upon_a_line/features/story_rooms/presentation/pages/story_room_detail_page.dart';
import 'package:once_upon_a_line/app/data/models/story_room.dart';
import 'package:once_upon_a_line/features/splash/presentation/pages/splash_page.dart';
import 'package:once_upon_a_line/core/routers/router_name.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: splashRoutePath,
    routes: <RouteBase>[
      GoRoute(
        path: splashRoutePath,
        name: 'slash',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return const MaterialPage<void>(child: SplashPage());
        },
      ),
      GoRoute(
        path: homeRoutePath,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return const MaterialPage<void>(child: StoryRoomsHomePage());
        },
      ),
      GoRoute(
        path: storyDetailRoutePath,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final StoryRoom? room = state.extra as StoryRoom?;
          if (room == null) {
            return const MaterialPage<void>(child: Scaffold(body: Center(child: Text('잘못된 경로'))));
          }
          return MaterialPage<void>(child: StoryRoomDetailPage(room: room));
        },
      ),
    ],
  );
}
