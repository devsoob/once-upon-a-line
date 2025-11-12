import 'package:flutter/material.dart';

class SearchTagFeedPage extends StatelessWidget {
  final String tag;

  const SearchTagFeedPage({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          '#$tag 피드',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        titleSpacing: 16,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        itemCount: 20,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '태그 #$tag 게시물 ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '간단한 게시물 미리보기 텍스트가 여기에 표시됩니다.',
                  style: TextStyle(fontSize: 13, color: Colors.black.withValues(alpha: 0.54)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
