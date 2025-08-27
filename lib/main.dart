import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'di.dart';
import 'features/write/data/local_line_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DiConfig.init();
  runApp(const OnceUponALineApp());
}

class OnceUponALineApp extends StatelessWidget {
  const OnceUponALineApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 시스템 UI 스타일 지정
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Platform.isAndroid ? Brightness.dark : Brightness.light,
        statusBarBrightness: Platform.isAndroid ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Once Upon A Line',
      theme: ThemeData(scaffoldBackgroundColor: Colors.white, fontFamily: 'Pretendard'),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final LocalLineRepository _repo;
  List<String> _lines = <String>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = GetIt.I<LocalLineRepository>();
    _load();
  }

  Future<void> _load() async {
    final List<String> lines = await _repo.getLines();
    if (!mounted) return;
    setState(() {
      _lines = lines;
      _loading = false;
    });
  }

  Future<void> _goToWrite() async {
    final bool canWrite = await _repo.canWriteNow();
    if (!canWrite) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('오늘은 이미 한 문장을 작성했어요. 내일 다시 시도해 주세요.')));
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WritePage()));
    if (mounted) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Once Upon A Line'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _lines.isEmpty
              ? const Center(
                child: Text(
                  '하루에 한 문장,\n릴레이 소설을 시작해보세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                itemBuilder: (BuildContext context, int index) {
                  final String line = _lines[index];
                  return Text('${index + 1}. $line', style: const TextStyle(fontSize: 16));
                },
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: _lines.length,
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToWrite,
        label: const Text('한 문장 쓰기'),
        icon: const Icon(Icons.edit),
      ),
    );
  }
}

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
    // Split by period, ignoring empty segments due to multiple spaces/newlines
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
