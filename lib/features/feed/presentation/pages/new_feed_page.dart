import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_line/app/data/models/story_room.dart';
import 'package:once_upon_a_line/core/routers/router_name.dart';

class NewFeedPage extends StatelessWidget {
  const NewFeedPage({super.key});

  StoryRoom _createMockStoryRoom(int index) {
    return StoryRoom(
      id: 'new_$index',
      title: '최신 게시물 ${index + 1}',
      description: '방금 업로드된 따끈따끈한 글이에요',
      creatorNickname: '새로운 작가 ${index + 1}',
      createdAt: DateTime.now().subtract(Duration(minutes: index * 5)),
      lastUpdatedAt: DateTime.now().subtract(Duration(minutes: index * 5)),
      participants: ['새로운 작가 ${index + 1}'],
      totalSentences: 1 + index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      itemCount: 15,
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
                    color: const Color(0xFF34C759),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.add_circle_outline, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '최신 게시물 ${index + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1C1C1E),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '방금 업로드된 따끈따끈한 글이에요',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93), height: 1.4),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('방금', style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5F5E5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF34C759),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
