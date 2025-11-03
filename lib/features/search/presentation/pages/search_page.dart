import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_line/core/routers/router_name.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final List<String> trendingTags = <String>['소설', '시', '판타지', '로맨스', '스릴러', '에세이'];

    void submitSearch(String value) {
      final String trimmed = value.trim();
      if (trimmed.isEmpty) return;
      context.goNamed(searchResultsRouteName, queryParameters: {'q': trimmed});
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          '검색',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        titleSpacing: 16,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: submitSearch,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: '작품, 태그, 작성자를 검색해보세요',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => submitSearch(controller.text),
                  icon: const Icon(Icons.arrow_forward_rounded, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '인기 태그',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final String tag in trendingTags)
                GestureDetector(
                  onTap: () => context.goNamed(searchTagRouteName, pathParameters: {'tag': tag}),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: Text('#$tag', style: const TextStyle(color: Colors.black87)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            '추천 검색어',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: List.generate(6, (int index) {
                final String keyword = '추천 검색어 ${index + 1}';
                return ListTile(
                  title: Text(keyword, style: const TextStyle(color: Colors.black87)),
                  trailing: const Icon(Icons.north_east, size: 18),
                  onTap:
                      () =>
                          context.goNamed(searchResultsRouteName, queryParameters: {'q': keyword}),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
