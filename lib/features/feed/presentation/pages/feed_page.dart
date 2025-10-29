import 'package:flutter/material.dart';
import 'package:once_upon_a_line/features/feed/presentation/pages/following_feed_page.dart';
import 'package:once_upon_a_line/features/feed/presentation/pages/trending_feed_page.dart';
import 'package:once_upon_a_line/features/feed/presentation/pages/new_feed_page.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            '피드',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          titleSpacing: 16,
          bottom: const TabBar(
            isScrollable: false,
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: [Tab(text: '팔로잉'), Tab(text: '트렌딩'), Tab(text: '최신')],
          ),
        ),
        body: const TabBarView(children: [FollowingFeedPage(), TrendingFeedPage(), NewFeedPage()]),
      ),
    );
  }
}
