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

  Future<void> _renameWork(WorkDto work) async {
    final TextEditingController controller = TextEditingController(text: work.title);
    final String? newTitle = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('작품 이름 수정'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '새 작품 이름 입력'),
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
    if (newTitle == null || newTitle.isEmpty || newTitle == work.title) return;
    await _repo.renameWork(workId: work.id, newTitle: newTitle);
    await _load();
  }

  Future<void> _deleteWork(WorkDto work) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('작품 삭제'),
          content: Text('정말 "${work.title}" 을(를) 삭제할까요? 되돌릴 수 없습니다.'),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    await _repo.deleteWork(work.id);
    await _load();
  }

  void _showWorkActions(WorkDto work) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('이름 수정'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _renameWork(work);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('삭제'),
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                onTap: () async {
                  Navigator.of(context).pop();
                  await _deleteWork(work);
                },
              ),
            ],
          ),
        );
      },
    );
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
                    return _BookTile(
                      title: work.title,
                      onTap: () => _openWork(work),
                      onLongPress: () => _showWorkActions(work),
                      actionsBuilder:
                          (BuildContext context) => IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () => _showWorkActions(work),
                            tooltip: '메뉴',
                          ),
                    );
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
  const _BookTile({
    required this.title,
    required this.onTap,
    this.onLongPress,
    this.actionsBuilder,
  });

  final String title;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final WidgetBuilder? actionsBuilder;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
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
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: theme.colorScheme.primary.withAlpha(100),
                        size: 40,
                      ),
                    ),
                    if (actionsBuilder != null)
                      Positioned(top: 4, right: 4, child: actionsBuilder!(context)),
                  ],
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
