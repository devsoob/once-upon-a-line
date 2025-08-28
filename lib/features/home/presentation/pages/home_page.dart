import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../write/data/local_line_repository.dart';

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
    await context.push('/write');
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
