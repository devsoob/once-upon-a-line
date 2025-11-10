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
        backgroundColor: const Color(0xFFF2F2F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            '피드',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)),
          ),
          titleSpacing: 20,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE5E5EA), width: 0.5)),
              ),
              child: const TabBar(
                isScrollable: false,
                labelColor: Color(0xFF1C1C1E),
                unselectedLabelColor: Color(0xFF8E8E93),
                indicatorColor: Color(0xFF007AFF),
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                tabs: [Tab(text: '팔로잉'), Tab(text: '트렌딩'), Tab(text: '최신')],
              ),
            ),
          ),
        ),
        body: const TabBarView(children: [FollowingFeedPage(), TrendingFeedPage(), NewFeedPage()]),
      ),
    );
  }
}
