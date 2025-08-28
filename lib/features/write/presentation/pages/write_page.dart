import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../data/local_line_repository.dart';

class WritePage extends StatefulWidget {
  const WritePage({super.key});

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final TextEditingController _controller = TextEditingController();
  String? _error;
  late final LocalLineRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = GetIt.I<LocalLineRepository>();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return '문장을 입력해 주세요.';
    final List<String> sentences =
        trimmed.split('.').map((String s) => s.trim()).where((String s) => s.isNotEmpty).toList();
    if (sentences.length != 1) {
      return '오직 마침표(.) 기준으로 한 문장만 작성할 수 있어요.';
    }
    if (!trimmed.endsWith('.')) {
      return '마침표(.)로 끝나는 한 문장이어야 해요.';
    }
    if (trimmed.length > 300) {
      return '문장은 300자 이내로 작성해 주세요.';
    }
    return null;
  }

  Future<void> _save() async {
    final String text = _controller.text;
    final String? error = _validate(text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    await _repo.saveLine(text.trim());
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('한 문장 쓰기')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '오늘의 한 문장을 마침표(.)로 끝내어 작성해 보세요',
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_error != null) {
                  setState(() => _error = null);
                }
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
