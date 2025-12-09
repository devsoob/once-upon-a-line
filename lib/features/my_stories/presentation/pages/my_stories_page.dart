import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:once_upon_a_line/app/data/models/story_room.dart';
import 'package:once_upon_a_line/app/data/models/user_session.dart';
import 'package:once_upon_a_line/app/data/services/user_session_service.dart';
import 'package:once_upon_a_line/core/constants/app_colors.dart';
import 'package:once_upon_a_line/app/data/repositories/story_room_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_line/core/routers/router_name.dart';

class MyStoriesPage extends StatefulWidget {
  const MyStoriesPage({super.key});

  @override
  State<MyStoriesPage> createState() => _MyStoriesPageState();
}

class _MyStoriesPageState extends State<MyStoriesPage> {
  late final UserSessionService _sessionService;
  late final TextEditingController _nicknameController;
  String _nickname = '';
  String _userId = '';
  bool _isEditingNickname = false;
  bool _isSavingNickname = false;

  @override
  void initState() {
    super.initState();
    _sessionService = GetIt.I<UserSessionService>();
    _nicknameController = TextEditingController();
    _loadUser();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final UserSession? session = await _sessionService.getCurrentSession();
    if (!mounted) return;
    setState(() {
      _nickname = session?.nickname ?? '게스트';
      _userId = session?.userId ?? '';
      _nicknameController.text = _nickname;
    });
  }

  void _startEditingNickname() {
    setState(() {
      _isEditingNickname = true;
    });
  }

  void _cancelEditingNickname() {
    setState(() {
      _isEditingNickname = false;
      _nicknameController.text = _nickname;
    });
  }

  Future<void> _saveNickname() async {
    final String trimmed = _nicknameController.text.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('닉네임을 입력해 주세요.')));
      return;
    }
    if (trimmed.length > 20) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('닉네임은 20자 이내여야 해요.')));
      return;
    }

    setState(() {
      _isSavingNickname = true;
    });

    try {
      final UserSession? current = await _sessionService.getCurrentSession();
      final UserSession updated = (current ??
              UserSession(
                userId: _userId,
                nickname: '',
                lastWriteAt: DateTime.fromMillisecondsSinceEpoch(0),
              ))
          .copyWith(nickname: trimmed, lastWriteAt: DateTime.now());
      await _sessionService.saveSession(updated);
      if (!mounted) return;
      setState(() {
        _nickname = trimmed;
        _isEditingNickname = false;
        _isSavingNickname = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('닉네임이 저장되었습니다.')));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSavingNickname = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          '마이',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        titleSpacing: 16,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: ListView(
            children: [
              // 닉네임 섹션
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '닉네임',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isEditingNickname)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nicknameController,
                              autofocus: true,
                              maxLength: 20,
                              decoration: InputDecoration(
                                hintText: '닉네임을 입력하세요 (최대 20자)',
                                counterText: '',
                                filled: true,
                                fillColor: const Color(0xFFF7F8FA),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE5EAF0), width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE5EAF0), width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _isSavingNickname ? null : _saveNickname,
                            icon:
                                _isSavingNickname
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                    : const Icon(Icons.check_rounded, color: Color(0xFF222222)),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF222222).withOpacity(0.1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          IconButton(
                            onPressed: _isSavingNickname ? null : _cancelEditingNickname,
                            icon: const Icon(Icons.close_rounded, color: Color(0xFF222222)),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF222222).withOpacity(0.1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _nickname,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _startEditingNickname,
                            icon: const Icon(
                              Icons.edit_rounded,
                              color: Color(0xFF222222),
                              size: 20,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF222222).withOpacity(0.1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _SectionHeader(title: '내가 만든 이야기'),
              if (_userId.isNotEmpty)
                StreamBuilder<List<StoryRoom>>(
                  stream: GetIt.I<StoryRoomRepository>().getMyRooms(_userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const _EmptyCard(message: '데이터를 불러오는 중 오류가 발생했습니다.');
                    }

                    final List<StoryRoom> rooms = snapshot.data ?? [];
                    final List<StoryRoom> myCreatedRooms =
                        rooms.where((room) => room.creatorUserId == _userId).toList();

                    if (myCreatedRooms.isEmpty) {
                      return const _EmptyCard(message: '아직 내가 만든 이야기가 없어요.');
                    }

                    return _StoryListSection(
                      rooms: myCreatedRooms,
                      onTap: (room) => _navigateToDetail(room),
                    );
                  },
                )
              else
                const _EmptyCard(message: '아직 내가 만든 이야기가 없어요.'),
              const SizedBox(height: 24),
              const _SectionHeader(title: '내가 참여한 이야기'),
              if (_userId.isNotEmpty)
                StreamBuilder<List<StoryRoom>>(
                  stream: GetIt.I<StoryRoomRepository>().getMyRooms(_userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const _EmptyCard(message: '데이터를 불러오는 중 오류가 발생했습니다.');
                    }

                    final List<StoryRoom> rooms = snapshot.data ?? [];
                    final List<StoryRoom> participatedRooms =
                        rooms
                            .where(
                              (room) =>
                                  room.creatorUserId != _userId &&
                                  room.participants.contains(_nickname),
                            )
                            .toList();

                    if (participatedRooms.isEmpty) {
                      return const _EmptyCard(message: '아직 참여한 이야기가 없어요.');
                    }

                    return _StoryListSection(
                      rooms: participatedRooms,
                      onTap: (room) => _navigateToDetail(room),
                    );
                  },
                )
              else
                const _EmptyCard(message: '아직 참여한 이야기가 없어요.'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToDetail(StoryRoom room) async {
    if (!mounted) return;
    await context.pushNamed(storyDetailRouteName, extra: room);
  }
}

class _StoryListSection extends StatelessWidget {
  const _StoryListSection({required this.rooms, required this.onTap});

  final List<StoryRoom> rooms;
  final void Function(StoryRoom) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: rooms.map((room) => _StoryListItem(room: room, onTap: () => onTap(room))).toList(),
    );
  }
}

class _StoryListItem extends StatelessWidget {
  const _StoryListItem({required this.room, required this.onTap});

  final StoryRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    room.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${room.totalSentences}문장',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (room.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                room.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  room.creatorNickname,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.people_outline, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${room.participants.length}명 참여',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
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
                  color: const Color(0xFF222222).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.menu_book_outlined, color: Color(0xFF222222), size: 18),
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
