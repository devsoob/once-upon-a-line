import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_line/app/data/models/story_room.dart';
import 'package:once_upon_a_line/core/routers/router_name.dart';

class TrendingFeedPage extends StatelessWidget {
  const TrendingFeedPage({super.key});

  StoryRoom _createMockStoryRoom(int index) {
    return StoryRoom(
      id: 'trending_$index',
      title: '지금 뜨는 이야기 #${index + 1}',
      description: '모든 사람이 읽고 있는 인기 콘텐츠',
      creatorNickname: '트렌드 작가',
      createdAt: DateTime.now().subtract(Duration(hours: 1 + index)),
      lastUpdatedAt: DateTime.now().subtract(Duration(hours: 1 + index)),
      participants: ['트렌드 작가', '참여자${index + 1}'],
      totalSentences: 10 + index * 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      itemCount: 10,
      separatorBuilder: (_, __) => const SizedBox(height: 1),
      itemBuilder: (context, index) {
        final storyRoom = _createMockStoryRoom(index);

        return InkWell(
          onTap: () {
            context.pushNamed(storyDetailRouteName, extra: storyRoom);
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '지금 뜨는 이야기',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1C1C1E),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '모든 사람이 읽고 있는 인기 콘텐츠',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93), height: 1.4),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE5E5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'HOT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF3B30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
