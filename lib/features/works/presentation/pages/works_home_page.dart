import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/data/works_repository.dart';

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
      appBar: AppBar(
        title: const Text('작품 목록', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _works.isEmpty
              ? Center(
                child: Text(
                  '작품을 추가해 시작해 보세요.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontFamily: 'Pretendard'),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.70,
                  ),
                  itemCount: _works.length,
                  itemBuilder: (BuildContext context, int index) {
                    final WorkDto work = _works[index];
                    return _BookTile(title: work.title, onTap: () => _openWork(work));
                  },
                ),
              ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _addWork,
              icon: const Icon(Icons.add),
              label: const Text('작품 추가'),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      theme.colorScheme.primary.withAlpha(18),
                      theme.colorScheme.primary.withAlpha(8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primary.withAlpha(20)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: theme.colorScheme.primary.withAlpha(100),
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
