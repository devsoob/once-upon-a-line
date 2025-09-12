import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:once_upon_a_line/core/design_system/colors.dart';
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
import 'package:once_upon_a_line/features/story_rooms/presentation/pages/story_room_detail_page.dart';

class StoryRoomsHomePage extends StatefulWidget {
  const StoryRoomsHomePage({super.key});

  @override
  State<StoryRoomsHomePage> createState() => _StoryRoomsHomePageState();
}

class _StoryRoomsHomePageState extends State<StoryRoomsHomePage> {
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

  Future<void> _createRoom() async {
    if (_nickname.isEmpty) {
      _showNicknameDialog();
      return;
    }

    final StoryRoom? room = await showDialog<StoryRoom>(
      context: context,
      builder: (context) => CreateRoomDialog(creatorNickname: _nickname),
    );

    if (room != null && mounted) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => StoryRoomDetailPage(room: room)));
    }
  }

  void _showNicknameDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('닉네임 설정'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '닉네임을 입력해주세요',
                border: OutlineInputBorder(),
              ),
              maxLength: 20,
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
              ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isNotEmpty) {
                    final String nickname = controller.text.trim();
                    final UserSession session = UserSession(
                      nickname: nickname,
                      lastWriteAt: DateTime.now(),
                    );
                    await _sessionService.saveSession(session);
                    if (!mounted) return;
                    if (!context.mounted) return;
                    setState(() {
                      _nickname = nickname;
                    });
                    Navigator.of(context).pop();
                    _createRoom();
                  }
                },
                child: const Text('확인'),
              ),
            ],
          ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('프로필'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        _nickname.isNotEmpty ? _nickname[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nickname,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            '게스트 사용자',
                            style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  '닉네임을 변경하려면 아래 버튼을 눌러주세요.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('닫기')),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showNicknameDialog();
                },
                child: const Text('닉네임 변경'),
              ),
            ],
          ),
    );
  }

  void _openRoom(StoryRoom room) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => StoryRoomDetailPage(room: room)));
  }

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ProfileIcon(onPressed: _showProfileDialog, size: 28),
          ),
        ],
        titleSpacing: 16,
      ),
      body: Column(
        children: [
          // Stories List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                              builder: (context, snapshot) => _buildRoomsList(snapshot),
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.1),
          //     blurRadius: 10,
          //     offset: const Offset(0, -2),
          //   ),
          // ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom > 0 ? 8 : 16,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: const Text(
                  '새 이야기 시작하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomsList(AsyncSnapshot<List<StoryRoom>> snapshot) {
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
              color: Colors.black.withOpacity(0.04),
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
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.18),
                    AppColors.primary.withOpacity(0.06),
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
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
                            color: AppColors.primary,
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
