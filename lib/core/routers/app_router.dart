import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_line/features/story_rooms/presentation/pages/story_rooms_home_page.dart';
import 'package:once_upon_a_line/features/story_rooms/presentation/pages/story_room_detail_page.dart';
import 'package:once_upon_a_line/app/data/models/story_room.dart';
import 'package:once_upon_a_line/features/splash/presentation/pages/splash_page.dart';
import 'package:once_upon_a_line/core/routers/router_name.dart';
import 'package:once_upon_a_line/features/my_stories/presentation/pages/my_stories_page.dart';
import 'package:once_upon_a_line/features/root/presentation/pages/root_shell.dart';
import 'package:once_upon_a_line/features/search/presentation/pages/search_page.dart';
import 'package:once_upon_a_line/features/search/presentation/pages/search_results_page.dart';
import 'package:once_upon_a_line/features/search/presentation/pages/search_tag_feed_page.dart';
import 'package:once_upon_a_line/features/feed/presentation/pages/feed_page.dart';
import 'package:once_upon_a_line/features/story_analytics/presentation/pages/story_analytics_page.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: splashRoutePath,
    routes: <RouteBase>[
      GoRoute(
        path: splashRoutePath,
        name: splashRouteName,
        pageBuilder: (BuildContext context, GoRouterState state) {
          return const MaterialPage<void>(child: SplashPage());
        },
      ),
      ShellRoute(
        builder: (context, state, child) => RootShell(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: searchRoutePath,
            name: searchRouteName,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const MaterialPage<void>(child: SearchPage());
            },
          ),
          GoRoute(
            path: searchResultsRoutePath,
            name: searchResultsRouteName,
            pageBuilder: (BuildContext context, GoRouterState state) {
              final String q = state.uri.queryParameters['q'] ?? '';
              return MaterialPage<void>(child: SearchResultsPage(query: q));
            },
          ),
          GoRoute(
            path: '$searchTagRoutePath/:tag',
            name: searchTagRouteName,
            pageBuilder: (BuildContext context, GoRouterState state) {
              final String tag = state.pathParameters['tag'] ?? '';
              return MaterialPage<void>(child: SearchTagFeedPage(tag: tag));
            },
          ),
          GoRoute(
            path: homeRoutePath,
            name: homeRouteName,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const MaterialPage<void>(child: StoryRoomsHomePage());
            },
          ),
          GoRoute(
            path: feedRoutePath,
            name: feedRouteName,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const MaterialPage<void>(child: FeedPage());
            },
          ),
          GoRoute(
            path: myStoriesRoutePath,
            name: myStoriesRouteName,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return const MaterialPage<void>(child: MyStoriesPage());
            },
          ),
        ],
      ),
      GoRoute(
        path: storyDetailRoutePath,
        name: storyDetailRouteName,
        pageBuilder: (context, state) {
          final StoryRoom? room = state.extra as StoryRoom?;
          if (room == null) {
            return const MaterialPage<void>(child: Scaffold(body: Center(child: Text('잘못된 경로'))));
          }
          return MaterialPage<void>(child: StoryRoomDetailPage(room: room));
        },
      ),
      GoRoute(
        path: storyAnalyticsRoutePath,
        name: storyAnalyticsRouteName,
        pageBuilder: (context, state) {
          final StoryRoom? room = state.extra as StoryRoom?;
          if (room == null) {
            return const MaterialPage<void>(child: Scaffold(body: Center(child: Text('잘못된 경로'))));
          }
          return MaterialPage<void>(child: StoryAnalyticsPage(room: room));
        },
      ),
    ],
  );
}
