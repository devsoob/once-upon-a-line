import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:once_upon_a_line/core/constants/app_colors.dart';
import 'package:once_upon_a_line/core/widgets/app_logo.dart';
import 'package:once_upon_a_line/core/widgets/profile_icon.dart';
import 'package:get_it/get_it.dart';
import 'package:once_upon_a_line/app/data/repositories/story_room_repository.dart';
import 'package:once_upon_a_line/app/data/repositories/local_story_room_repository.dart';
import 'package:once_upon_a_line/app/data/models/story_room.dart';
import 'package:once_upon_a_line/app/data/services/user_session_service.dart';
import 'package:once_upon_a_line/app/data/models/user_session.dart';
import 'package:once_upon_a_line/di.dart';
import 'package:once_upon_a_line/features/story_rooms/presentation/pages/create_room_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_line/core/routers/router_name.dart';

class StoryRoomsHomePage extends StatefulWidget {
  const StoryRoomsHomePage({super.key});

  @override
  State<StoryRoomsHomePage> createState() => _StoryRoomsHomePageState();
}

class _StoryRoomsHomePageState extends State<StoryRoomsHomePage> {
  late final UserSessionService _sessionService;
  String _nickname = '';
  String _userId = '';
  bool _needsRefresh = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[UI] StoryRoomsHomePage.initState');
    _sessionService = GetIt.I<UserSessionService>();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final UserSession? session = await _sessionService.getCurrentSession();
    if (!mounted) return;
    setState(() {
      _nickname = session?.nickname ?? '게스트';
      _userId = session?.userId ?? '';
    });
  }

  Future<void> _createRoom() async {
    if (_nickname.isEmpty || _userId.isEmpty) {
      _showNicknameDialog(continueCreateFlow: true);
      return;
    }

    final StoryRoom? room = await showDialog<StoryRoom>(
      context: context,
      builder: (context) => CreateRoomDialog(creatorNickname: _nickname, creatorUserId: _userId),
    );

    if (room != null && mounted) {
      final result = await context.pushNamed(storyDetailRouteName, extra: room);

      // 뒤로가기 시 새로고침 플래그 설정
      if (result == true) {
        setState(() {
          _needsRefresh = true;
        });
      }
    }
  }

  Future<void> _showNicknameDialog({bool continueCreateFlow = false}) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                    decoration: const BoxDecoration(
                      color: Color(0xFF222222),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                '프로필',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '계정 정보를 확인하고 관리하세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Profile info card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5EAF0), width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF222222),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    _nickname.isNotEmpty ? _nickname[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _nickname,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF222222).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        '게스트 사용자',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF222222),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: const BorderSide(color: Color(0xFF222222), width: 1.5),
                                  backgroundColor: Colors.white,
                                  overlayColor: const Color(0xFF222222).withValues(alpha: 0.1),
                                ),
                                child: const Text(
                                  '닫기',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF222222),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) {
                                      _showNicknameEditDialog(
                                        continueCreateFlow: continueCreateFlow,
                                      );
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF222222),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child: const Text(
                                  '닉네임 변경',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showNicknameEditDialog({bool continueCreateFlow = false}) async {
    final TextEditingController controller = TextEditingController(text: _nickname);
    final String? newNickname = await showDialog<String>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 480),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '닉네임 변경',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller,
                        autofocus: true,
                        maxLength: 20,
                        decoration: const InputDecoration(
                          hintText: '닉네임을 입력하세요 (최대 20자)',
                          counterText: '',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('취소'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final String value = controller.text.trim();
                                if (value.isEmpty) {
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(const SnackBar(content: Text('닉네임을 입력해 주세요.')));
                                  return;
                                }
                                if (value.length > 20) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('닉네임은 20자 이내여야 해요.')),
                                  );
                                  return;
                                }
                                Navigator.of(context).pop(value);
                              },
                              child: const Text('저장'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (newNickname != null && mounted) {
      try {
        final UserSession? current = await _sessionService.getCurrentSession();
        final UserSession updated = (current ??
                UserSession(
                  userId: '',
                  nickname: '',
                  lastWriteAt: DateTime.fromMillisecondsSinceEpoch(0),
                ))
            .copyWith(nickname: newNickname, lastWriteAt: DateTime.now());
        await _sessionService.saveSession(updated);
      } catch (e) {
        debugPrint('[UI] Nickname save failed: $e');
      }
      if (!mounted) return;
      setState(() {
        _nickname = newNickname;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('닉네임이 저장되었습니다.')));
      if (continueCreateFlow) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _createRoom();
        });
      }
    }
  }

  Future<void> _openRoom(StoryRoom room) async {
    final result = await context.pushNamed(storyDetailRouteName, extra: room);

    // 뒤로가기 시 새로고침 플래그 설정
    if (result == true && mounted) {
      setState(() {
        _needsRefresh = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[UI] StoryRoomsHomePage.build');
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(width: 36),
            const SizedBox(width: 8),
            Text(
              'Once Upon A Line',
              style: GoogleFonts.dancingScript(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF222222),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ProfileIcon(onPressed: () => _showNicknameDialog(), size: 28),
          ),
        ],
        titleSpacing: 16,
      ),
      body: Column(
        children: [
          // Stories List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child:
                        DiConfig.isFirebaseInitialized
                            ? StreamBuilder<List<StoryRoom>>(
                              stream: GetIt.I<StoryRoomRepository>().getPublicRooms(),
                              builder: (context, snapshot) => _buildRoomsList(snapshot),
                            )
                            : FutureBuilder<List<StoryRoom>>(
                              future: GetIt.I<LocalStoryRoomRepository>().getPublicRooms(),
                              builder: (context, snapshot) {
                                // 새로고침 후 플래그 리셋
                                if (_needsRefresh &&
                                    snapshot.connectionState == ConnectionState.done) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) {
                                      setState(() {
                                        _needsRefresh = false;
                                      });
                                    }
                                  });
                                }
                                return _buildRoomsList(snapshot);
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsList(AsyncSnapshot<List<StoryRoom>> snapshot) {
    debugPrint(
      '[UI] _buildRoomsList state=${snapshot.connectionState} hasError=${snapshot.hasError} len=${snapshot.data?.length}',
    );
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
        child: Text('오류가 발생했습니다: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
      );
    }

    final List<StoryRoom> rooms = snapshot.data ?? [];

    if (rooms.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 64, color: Color(0xFFBDC3C7)),
            SizedBox(height: 16),
            Text(
              '아직 진행 중인 이야기가 없습니다.\n첫 이야기를 시작해보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D)),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.64,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final StoryRoom room = rooms[index];
        return _StoryRoomCard(room: room, onTap: () => _openRoom(room));
      },
    );
  }
}

class _StoryRoomCard extends StatelessWidget {
  const _StoryRoomCard({required this.room, required this.onTap});

  final StoryRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 헤더: 은은한 그라디언트 배너
            Container(
              height: 72,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                color: const Color(0xFFF8F9FA),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EAF0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.menu_book_rounded, size: 14, color: AppColors.textSecondary),
                      SizedBox(width: 6),
                      Text(
                        'Public',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 내용
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.25,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (room.description.isNotEmpty)
                      Text(
                        room.description,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF222222),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '이어쓰기 가능',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
