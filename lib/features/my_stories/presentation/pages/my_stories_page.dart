import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:once_upon_a_line/app/data/models/story_room.dart';
import 'package:once_upon_a_line/app/data/models/user_session.dart';
import 'package:once_upon_a_line/app/data/services/user_session_service.dart';
import 'package:once_upon_a_line/core/constants/app_colors.dart';
import 'package:once_upon_a_line/core/widgets/app_logo.dart';
import 'package:once_upon_a_line/core/widgets/profile_icon.dart';
import 'package:once_upon_a_line/features/story_rooms/presentation/pages/create_room_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_line/core/routers/router_name.dart';

class MyStoriesPage extends StatefulWidget {
  const MyStoriesPage({super.key});

  @override
  State<MyStoriesPage> createState() => _MyStoriesPageState();
}

class _MyStoriesPageState extends State<MyStoriesPage> {
  late final UserSessionService _sessionService;
  String _nickname = '';

  @override
  void initState() {
    super.initState();
    _sessionService = GetIt.I<UserSessionService>();
    _loadNickname();
  }

  Future<void> _loadNickname() async {
    final UserSession? session = await _sessionService.getCurrentSession();
    if (!mounted) return;
    setState(() {
      _nickname = session?.nickname ?? '게스트';
    });
  }

  Future<void> _showNicknameDialog({bool continueCreateFlow = false}) async {
    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('닉네임 설정'),
            content: const Text('글을 작성하려면 닉네임이 필요해요.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('닫기')),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showNicknameEditDialog(continueCreateFlow: continueCreateFlow);
                },
                child: const Text('변경'),
              ),
            ],
          ),
    );
  }

  Future<void> _showNicknameEditDialog({bool continueCreateFlow = false}) async {
    final TextEditingController controller = TextEditingController(text: _nickname);
    final String? newNickname = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('닉네임 변경'),
            content: TextField(
              controller: controller,
              autofocus: true,
              maxLength: 20,
              decoration: const InputDecoration(hintText: '닉네임을 입력하세요 (최대 20자)', counterText: ''),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
              TextButton(
                onPressed: () => Navigator.of(context).pop(controller.text.trim()),
                child: const Text('저장'),
              ),
            ],
          ),
    );

    if (newNickname != null && newNickname.isNotEmpty && mounted) {
      final UserSession? current = await _sessionService.getCurrentSession();
      final UserSession updated = (current ??
              UserSession(nickname: '', lastWriteAt: DateTime.fromMillisecondsSinceEpoch(0)))
          .copyWith(nickname: newNickname, lastWriteAt: DateTime.now());
      await _sessionService.saveSession(updated);
      if (!mounted) return;
      setState(() => _nickname = newNickname);
      if (continueCreateFlow) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _createRoom());
      }
    }
  }

  Future<void> _createRoom() async {
    if (_nickname.isEmpty || _nickname == '게스트') {
      _showNicknameDialog(continueCreateFlow: true);
      return;
    }

    final StoryRoom? room = await showDialog<StoryRoom>(
      context: context,
      builder: (context) => CreateRoomDialog(creatorNickname: _nickname),
    );

    if (room != null && mounted) {
      await context.pushNamed(
        storyDetailRouteName,
        extra: room,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(mainAxisSize: MainAxisSize.min, children: const [AppLogo(width: 36)]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ProfileIcon(onPressed: () => _showNicknameDialog(), size: 28),
          ),
        ],
        titleSpacing: 16,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ListView(
            children: const [
              _SectionHeader(title: '내가 만든 이야기'),
              _EmptyCard(message: '아직 내가 만든 이야기가 없어요.'),
              SizedBox(height: 24),
              _SectionHeader(title: '내가 참여한 이야기'),
              _EmptyCard(message: '아직 참여한 이야기가 없어요.'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createRoom,
        child: const Icon(Icons.edit_rounded),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EAF0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.menu_book_outlined, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                '비어 있음',
                style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
