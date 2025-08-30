import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../data/works_repository.dart';

class WorksHomePage extends StatefulWidget {
  const WorksHomePage({super.key});

  @override
  State<WorksHomePage> createState() => _WorksHomePageState();
}

class _WorksHomePageState extends State<WorksHomePage> {
  late final WorksRepository _repo;
  List<WorkDto> _works = <WorkDto>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = GetIt.I<WorksRepository>();
    _load();
  }

  Future<void> _load() async {
    final List<WorkDto> works = await _repo.getWorks();
    if (!mounted) return;
    setState(() {
      _works = works;
      _loading = false;
    });
  }

  Future<void> _addWork() async {
    final String? title = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('작품 제목 입력'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '예: 소설책1'),
          ),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
    if (title == null || title.isEmpty) return;
    await _repo.createWork(title: title);
    await _load();
  }

  void _openWork(WorkDto work) {
    context.push('/work/${work.id}', extra: work);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('작품 목록')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _works.isEmpty
              ? const Center(child: Text('작품을 추가해 시작해 보세요.'))
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (BuildContext context, int index) {
                  final WorkDto work = _works[index];
                  return ListTile(
                    title: Text(work.title),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openWork(work),
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: _works.length,
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addWork,
        icon: const Icon(Icons.add),
        label: const Text('작품 추가'),
      ),
    );
  }
}
