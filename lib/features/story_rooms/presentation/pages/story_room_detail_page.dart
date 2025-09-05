import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:once_upon_a_line/app/data/repositories/story_sentence_repository.dart';
import 'package:once_upon_a_line/app/data/repositories/local_story_sentence_repository.dart';
import 'package:once_upon_a_line/app/data/models/story_room.dart';
import 'package:once_upon_a_line/app/data/models/story_sentence.dart';
import 'package:once_upon_a_line/app/data/services/user_session_service.dart';
import 'package:once_upon_a_line/app/data/models/user_session.dart';
import 'package:once_upon_a_line/di.dart';

class StoryRoomDetailPage extends StatefulWidget {
  const StoryRoomDetailPage({super.key, required this.room});

  final StoryRoom room;

  @override
  State<StoryRoomDetailPage> createState() => _StoryRoomDetailPageState();
}

class _StoryRoomDetailPageState extends State<StoryRoomDetailPage> {
  late final UserSessionService _sessionService;
  final TextEditingController _sentenceController = TextEditingController();
  String _nickname = '게스트';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sessionService = GetIt.I<UserSessionService>();
    _loadNickname();
  }

  @override
  void dispose() {
    _sentenceController.dispose();
    super.dispose();
  }

  Future<void> _loadNickname() async {
    final UserSession? session = await _sessionService.getCurrentSession();
    setState(() {
      _nickname = session?.nickname ?? '게스트';
    });
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (DiConfig.isFirebaseInitialized) {
        final StorySentenceRepository firebaseRepo = GetIt.I<StorySentenceRepository>();
        await firebaseRepo.addSentence(
          roomId: widget.room.id,
          content: text.trim(),
          authorNickname: _nickname,
        );
      } else {
        final LocalStorySentenceRepository localRepo = GetIt.I<LocalStorySentenceRepository>();
        await localRepo.addSentence(
          roomId: widget.room.id,
          content: text.trim(),
          authorNickname: _nickname,
        );
      }

      _sentenceController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('문장이 추가되었습니다!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.room.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF2C3E50),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Room Info Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF3498DB),
                        child: Text(
                          widget.room.creatorNickname.isNotEmpty
                              ? widget.room.creatorNickname[0].toUpperCase()
                              : '?',
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
                              widget.room.creatorNickname,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            Text(
                              '${widget.room.participants.length}명 참여',
                              style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.room.totalSentences}줄',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF27AE60),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.room.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.room.description,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D), height: 1.4),
                    ),
                  ],
                ],
              ),
            ),

            // Story Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child:
                    DiConfig.isFirebaseInitialized
                        ? StreamBuilder<List<StorySentence>>(
                          stream: GetIt.I<StorySentenceRepository>().getSentences(widget.room.id),
                          builder: (context, snapshot) => _buildSentencesList(snapshot),
                        )
                        : FutureBuilder<List<StorySentence>>(
                          future: GetIt.I<LocalStorySentenceRepository>().getSentences(
                            widget.room.id,
                          ),
                          builder: (context, snapshot) => _buildSentencesList(snapshot),
                        ),
              ),
            ),

            // Input Section
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3498DB), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _sentenceController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 16, color: Color(0xFF2C3E50)),
                      decoration: const InputDecoration(
                        hintText: '마침표(.)로 끝나는 한 문장을 작성해주세요...',
                        hintStyle: TextStyle(color: Color(0xFFBDC3C7)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '닉네임: $_nickname',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF7F8C8D)),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _addSentence,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3498DB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                                : const Text(
                                  '추가',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
    );
  }

  Widget _buildSentencesList(AsyncSnapshot<List<StorySentence>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
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
        children:
            sentences
                .map(
                  (sentence) => _SentenceWidget(
                    sentence: sentence,
                    isMySentence: sentence.authorNickname == _nickname,
                  ),
                )
                .toList(),
      ),
    );
  }
}

class _SentenceWidget extends StatelessWidget {
  const _SentenceWidget({required this.sentence, required this.isMySentence});

  final StorySentence sentence;
  final bool isMySentence;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMySentence ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: isMySentence ? Border.all(color: const Color(0xFF3498DB), width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isMySentence ? const Color(0xFF3498DB) : const Color(0xFF95A5A6),
                child: Text(
                  sentence.authorNickname.isNotEmpty
                      ? sentence.authorNickname[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                sentence.authorNickname,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isMySentence ? const Color(0xFF3498DB) : const Color(0xFF7F8C8D),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(sentence.createdAt),
                style: const TextStyle(fontSize: 11, color: Color(0xFF95A5A6)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            sentence.content,
            style: const TextStyle(fontSize: 16, color: Color(0xFF2C3E50), height: 1.5),
          ),
        ],
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
