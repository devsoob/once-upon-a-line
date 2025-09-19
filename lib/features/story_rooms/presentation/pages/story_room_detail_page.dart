import 'package:flutter/material.dart';
import 'package:once_upon_a_line/core/constants/app_colors.dart';
import 'package:once_upon_a_line/core/widgets/app_text_field.dart';
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

  final Map<String, Color> _nicknameToColor = <String, Color>{};
  static const List<Color> _authorPalette = <Color>[
    Color(0xFFDB4C40), // red coral
    Color(0xFF3AA6B9), // teal blue
    Color(0xFF7B9ACC), // periwinkle
    Color(0xFF5CBA47), // green
    Color(0xFFFFA726), // orange
    Color(0xFF8E24AA), // purple
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
            ),

            // Bottom input and button fixed on white background
            Container(
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
                  AppTextField(
                    controller: _sentenceController,
                    hintText: '마침표(.)로 끝나는 한 문장을 작성해주세요...',
                    maxLines: 2,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addSentence,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                      ),
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
        children: [
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
