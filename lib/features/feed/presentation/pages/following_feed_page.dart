import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_line/app/data/models/story_room.dart';
import 'package:once_upon_a_line/core/routers/router_name.dart';

class FollowingFeedPage extends StatelessWidget {
  const FollowingFeedPage({super.key});

  StoryRoom _createMockStoryRoom(int index) {
    return StoryRoom(
      id: 'following_$index',
      title: '팔로잉 작가 ${index + 1}의 이야기',
      description: '새 글 업데이트 ${index + 1}',
      creatorNickname: '팔로잉 작가 ${index + 1}',
      createdAt: DateTime.now().subtract(Duration(hours: 2 + index)),
      lastUpdatedAt: DateTime.now().subtract(Duration(hours: 2 + index)),
      participants: ['팔로잉 작가 ${index + 1}'],
      totalSentences: 5 + index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      itemCount: 12,
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.person_outline, size: 18, color: Color(0xFF8E8E93)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '팔로잉 작가 ${index + 1}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '새 글 업데이트 ${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1C1C1E),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('2시간 전', style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF007AFF),
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
