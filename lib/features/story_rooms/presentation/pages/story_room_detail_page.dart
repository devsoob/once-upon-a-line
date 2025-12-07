import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:once_upon_a_line/core/constants/app_colors.dart';
import 'package:once_upon_a_line/core/widgets/app_text_field.dart';
import 'package:once_upon_a_line/core/widgets/app_toast.dart';
import 'package:get_it/get_it.dart';
import 'package:once_upon_a_line/app/data/repositories/story_sentence_repository.dart';
import 'package:once_upon_a_line/app/data/models/story_room.dart';
import 'package:once_upon_a_line/app/data/models/story_sentence.dart';
import 'package:once_upon_a_line/app/data/services/user_session_service.dart';
import 'package:once_upon_a_line/app/data/models/user_session.dart';
import 'package:once_upon_a_line/app/data/services/random_sentence_service.dart';
import 'package:once_upon_a_line/core/logger.dart';
import 'package:go_router/go_router.dart';
import 'package:once_upon_a_line/core/routers/router_name.dart';

class StoryRoomDetailPage extends StatefulWidget {
  const StoryRoomDetailPage({super.key, required this.room});

  final StoryRoom room;

  @override
  State<StoryRoomDetailPage> createState() => _StoryRoomDetailPageState();
}

class _StoryRoomDetailPageState extends State<StoryRoomDetailPage> {
  late final UserSessionService _sessionService;
  late final RandomSentenceService _randomSentenceService;
  final TextEditingController _sentenceController = TextEditingController();
  String _nickname = '게스트';
  String _userId = '';
  bool _isLoading = false;
  bool _hasShownStreamError = false;

  final Map<String, Color> _nicknameToColor = <String, Color>{};
  static const List<Color> _authorPalette = <Color>[
    Color(0xFFDB4C40), // red coral
    Color(0xFF3AA6B9), // teal blue
    Color(0xFF7B9ACC), // periwinkle
    Color(0xFF5CBA47), // green
    Color(0xFFFFA726), // orange
    Color(0xFF4A5568), // dark gray (replaces purple)
    Color(0xFF26C6DA), // cyan
    Color(0xFFFF7043), // deep orange
  ];

  Color _colorForAuthor(String nickname) {
    if (_nicknameToColor.containsKey(nickname)) return _nicknameToColor[nickname]!;
    // Deterministic index based on nickname hashCode so colors are stable across rebuilds
    final int index = nickname.hashCode.abs() % _authorPalette.length;
    final Color color = _authorPalette[index];
    _nicknameToColor[nickname] = color;
    return color;
  }

  @override
  void initState() {
    super.initState();
    _sessionService = GetIt.I<UserSessionService>();
    _randomSentenceService = GetIt.I<RandomSentenceService>();
    _loadUser();
    _setRandomSentence();
  }

  @override
  void dispose() {
    _sentenceController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final UserSession? session = await _sessionService.getCurrentSession();
    setState(() {
      _nickname = session?.nickname ?? '게스트';
      _userId = session?.userId ?? '';
    });
  }

  void _setRandomSentence() {
    final String randomSentence = _randomSentenceService.getRandomSentence();
    final String formattedSentence = _randomSentenceService.ensureEndsWithPeriod(randomSentence);
    _sentenceController.text = formattedSentence;
  }

  String? _validateSentence(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return '문장을 입력해 주세요.';
    if (!trimmed.endsWith('.')) return '마침표(.)로 끝나는 한 문장이어야 해요.';
    if (trimmed.length > 300) return '문장은 300자 이내로 작성해 주세요.';
    return null;
  }

  Future<void> _addSentence() async {
    final String text = _sentenceController.text;
    final String? error = _validateSentence(text);
    if (error != null) {
      AppToast.show(context, error);
      return;
    }

    // Optimistic UI: clear and unlock immediately
    setState(() {
      _isLoading = true;
    });
    _sentenceController.clear();
    setState(() {
      _isLoading = false;
    });

    // Fire-and-forget write; report errors via toast, stream will update UI
    Future<void>(() async {
      try {
        final StorySentenceRepository repo = GetIt.I<StorySentenceRepository>();
        await repo.addSentence(
          roomId: widget.room.id,
          content: text.trim(),
          authorNickname: _nickname,
          authorUserId: _userId,
        );
        if (mounted) {
          AppToast.show(context, '문장이 추가되었습니다!');
        }
      } catch (e, st) {
        String message = '문장 추가 중 오류가 발생했습니다';
        final String raw = e.toString();
        if (raw.contains('permission-denied') || raw.contains('PERMISSION_DENIED')) {
          message = '권한 오류가 발생했어요. 잠시 후 다시 시도해 주세요.';
        } else if (raw.contains('unavailable')) {
          message = '네트워크 상태가 불안정해요. 연결을 확인해 주세요.';
        }
        if (kDebugMode) {
          logger.e(
            '[StoryRoomDetail] addSentence failed (optimistic): $e',
            error: e,
            stackTrace: st,
          );
        }
        if (mounted) {
          AppToast.show(context, message);
        }
      }
    });
  }

  /// 첫 번째 문장 뒤에 시작점을 표시할지 여부 (UI에서만 사용)
  bool _shouldShowStarter() {
    return widget.room.storyStarter != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.room.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Story Content - light grey and scrollable
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF8F9FA),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: StreamBuilder<List<StorySentence>>(
                    stream: GetIt.I<StorySentenceRepository>().getSentences(widget.room.id),
                    initialData: const <StorySentence>[],
                    builder: (context, snapshot) => _buildSentencesList(snapshot),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom > 0 ? 8 : 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _sentenceController,
                    hintText: '마침표(.)로 끝나는 한 문장을 작성해주세요.',
                    maxLines: 2,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    _sentenceController.clear();
                    _setRandomSentence();
                    AppToast.show(context, '새로운 랜덤 문장이 생성되었습니다!');
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shuffle, color: Colors.white, size: 20),
                  ),
                  tooltip: '랜덤 문장 생성',
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addSentence,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 24)),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                        : const Text('추가'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentencesList(AsyncSnapshot<List<StorySentence>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      if (kDebugMode) {
        logger.e('[StoryRoomDetail] stream error: ${snapshot.error}');
      }
      if (!_hasShownStreamError && mounted) {
        _hasShownStreamError = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final String message = '이야기를 불러오는 중 오류가 발생했어요.';
          AppToast.show(context, message);
        });
      }
      return Center(
        child: Text('오류가 발생했습니다: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
      );
    }

    final List<StorySentence> sentences = snapshot.data ?? [];

    if (sentences.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_note_outlined, size: 64, color: Color(0xFFBDC3C7)),
            SizedBox(height: 16),
            Text(
              '첫 문장을 작성해보세요!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF7F8C8D)),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_shouldShowStarter()) ...[
            // 랜덤 시작점 표시
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.room.storyStarter!.genre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '랜덤 시작점',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.room.storyStarter!.content,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Text.rich(
            TextSpan(
              children:
                  sentences.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final StorySentence sentence = entry.value;
                    final Color authorColor = _colorForAuthor(sentence.authorNickname);

                    return TextSpan(
                      children: [
                        TextSpan(
                          text: sentence.content,
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.8,
                            color: authorColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        if (index < sentences.length - 1) const TextSpan(text: ' '),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
