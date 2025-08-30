import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../data/works_repository.dart';
import '../../../sentences/data/sentences_repository.dart';

class WorkDetailPage extends StatefulWidget {
  const WorkDetailPage({super.key, required this.work});

  final WorkDto work;

  @override
  State<WorkDetailPage> createState() => _WorkDetailPageState();
}

class _WorkDetailPageState extends State<WorkDetailPage> {
  late final SentencesRepository _sentencesRepo;
  final TextEditingController _controller = TextEditingController();
  String? _error;
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
      setState(() => _error = error);
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('오늘은 이미 한 문장을 작성했어요. 내일 다시 시도해 주세요.')));
        return;
      }
    }

    await _sentencesRepo.addSentence(workId: widget.work.id, content: text.trim());
    if (!mounted) return;
    _controller.clear();
    setState(() => _error = null);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.work.title)),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: <Widget>[
                  Expanded(
                    child:
                        _sentences.isEmpty
                            ? const Center(child: Text('첫 문장을 시작해 보세요.'))
                            : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (BuildContext context, int index) {
                                final SentenceDto s = _sentences[index];
                                return Text(s.content, style: const TextStyle(fontSize: 16));
                              },
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemCount: _sentences.length,
                            ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: '마침표(.)로 끝나는 한 문장',
                              errorText: _error,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (_) {
                              if (_error != null) setState(() => _error = null);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(onPressed: _add, child: const Text('추가')),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
