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
          // Start story button only
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: _createRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 0,
                ),
                child: const Text(
                  '새 이야기 시작하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

          // Stories List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '진행 중인 이야기',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
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

    return ListView.builder(
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      room.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${room.totalSentences}줄',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF27AE60),
                      ),
                    ),
                  ),
                ],
              ),
              if (room.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  room.description,
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      room.creatorNickname.isNotEmpty ? room.creatorNickname[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    room.creatorNickname,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(room.lastUpdatedAt),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF95A5A6)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}
