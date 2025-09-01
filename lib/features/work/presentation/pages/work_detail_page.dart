import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../app/data/works_repository.dart';
import '../../../../app/data/sentences_repository.dart';

class WorkDetailPage extends StatefulWidget {
  const WorkDetailPage({super.key, required this.work});

  final WorkDto work;

  @override
  State<WorkDetailPage> createState() => _WorkDetailPageState();
}

class _WorkDetailPageState extends State<WorkDetailPage> {
  late final SentencesRepository _sentencesRepo;
  final TextEditingController _controller = TextEditingController();
  bool _loading = true;
  List<SentenceDto> _sentences = <SentenceDto>[];

  @override
  void initState() {
    super.initState();
    _sentencesRepo = GetIt.I<SentencesRepository>();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final List<SentenceDto> sentences = await _sentencesRepo.getSentences(widget.work.id);
    if (!mounted) return;
    setState(() {
      _sentences = sentences;
      _loading = false;
    });
  }

  String? _validate(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return '문장을 입력해 주세요.';
    final List<String> sentences =
        trimmed.split('.').map((String s) => s.trim()).where((String s) => s.isNotEmpty).toList();
    if (sentences.length != 1) return '오직 마침표(.) 기준으로 한 문장만 작성할 수 있어요.';
    if (!trimmed.endsWith('.')) return '마침표(.)로 끝나는 한 문장이어야 해요.';
    if (trimmed.length > 300) return '문장은 300자 이내로 작성해 주세요.';
    if (RegExp(r'^\d+\s*\.').hasMatch(trimmed)) return '번호 없이 문장을 작성해 주세요.';
    return null;
  }

  Future<void> _add() async {
    final String text = _controller.text;
    final String? error = _validate(text);
    if (error != null) {
      AppToast.show(context, error);
      return;
    }
    final DateTime? last = await _sentencesRepo.getLastWriteAt();
    final DateTime now = DateTime.now();
    if (last != null) {
      final bool canWrite =
          now.difference(last).inHours >= 24 ||
          (now.day != last.day || now.month != last.month || now.year != last.year);
      if (!canWrite) {
        if (!mounted) return;
        AppToast.show(context, '오늘은 이미 한 문장을 작성했어요.\n내일 다시 시도해 주세요.');
        return;
      }
    }

    await _sentencesRepo.addSentence(workId: widget.work.id, content: text.trim());
    if (!mounted) return;
    _controller.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.work.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: <Widget>[
                  Expanded(
                    child:
                        _sentences.isEmpty
                            ? Center(
                              child: Text(
                                '첫 문장을 시작해 보세요.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                            )
                            : SingleChildScrollView(
                              padding: const EdgeInsets.all(16),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  _sentences.map((s) => s.content).join(' '),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontFamily: 'Pretendard',
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF4DD7B0), width: 1.5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: TextField(
                              controller: _controller,
                              maxLines: 3,
                              style: theme.textTheme.bodyLarge?.copyWith(fontFamily: 'Pretendard'),
                              decoration: const InputDecoration(
                                hintText: '마침표(.)로 끝나는 한 문장??',
                                hintStyle: TextStyle(fontFamily: 'Pretendard'),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: EdgeInsets.zero,
                                fillColor: Colors.transparent,
                              ),
                              onChanged: (_) {
                                // 에러 상태 관리는 토스트로 대체되어 제거
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SafeArea(
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton.icon(
                              onPressed: _add,
                              icon: const Icon(Icons.add),
                              label: const Text('추가'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
