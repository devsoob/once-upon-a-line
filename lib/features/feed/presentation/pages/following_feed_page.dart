import 'package:flutter/material.dart';

class FollowingFeedPage extends StatelessWidget {
  const FollowingFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: 12,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 14, backgroundColor: Color(0xFFE9ECEF)),
                  const SizedBox(width: 8),
                  Text('팔로잉 작가 ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '새 글 업데이트 ${index + 1}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              const Text('팔로잉 중인 작가의 최신 게시물이 여기에 표시됩니다.', style: TextStyle(color: Colors.black54)),
            ],
          ),
        );
      },
    );
  }
}
