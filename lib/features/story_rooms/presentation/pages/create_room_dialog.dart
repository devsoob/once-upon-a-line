import 'dart:async';
import 'package:flutter/material.dart';
import 'package:once_upon_a_line/core/constants/app_colors.dart';
import 'package:once_upon_a_line/core/widgets/app_text_field.dart';
import 'package:once_upon_a_line/core/widgets/app_toast.dart';
import 'package:get_it/get_it.dart';
import '../../../../app/data/repositories/story_room_repository.dart';
import '../../../../app/data/models/story_room.dart';
import '../../../../app/data/models/story_starter.dart';
import '../../../../app/data/services/story_starter_service.dart';
import 'package:once_upon_a_line/core/logger.dart';
import 'package:once_upon_a_line/core/constants/timeouts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateRoomDialog extends StatefulWidget {
  const CreateRoomDialog({super.key, required this.creatorNickname, required this.creatorUserId});

  final String creatorNickname;
  final String creatorUserId;

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  late final StoryStarterService _storyStarterService;
  StoryStarter? _currentStarter;
  String _selectedGenre = '전체';

  @override
  void initState() {
    super.initState();
    _storyStarterService = GetIt.I<StoryStarterService>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _generateRandomStarter() {
    setState(() {
      if (_selectedGenre == '전체') {
        _currentStarter = _storyStarterService.getRandomStarter();
      } else {
        _currentStarter = _storyStarterService.getRandomStarterByGenre(_selectedGenre);
      }
    });

    if (_currentStarter != null) {
      // 스토리 시작점을 제목과 설명으로 분리
      final parts = _currentStarter!.content.split('에서');
      if (parts.length >= 2) {
        _titleController.text = '${parts[0]}에서';
        _descriptionController.text = parts[1].trim();
      } else {
        _titleController.text = _currentStarter!.content;
        _descriptionController.text = '';
      }
    }
  }

  Future<void> _createRoom() async {
    if (_titleController.text.trim().isEmpty) {
      AppToast.show(context, '제목을 입력해주세요');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      StoryRoom? room;

      logger.i('[UI][CreateRoom] creating room');
      logger.i(
        '[UI][CreateRoom] creatorUserId(session)="${widget.creatorUserId}" authUid="${FirebaseAuth.instance.currentUser?.uid}" isAnon=${FirebaseAuth.instance.currentUser?.isAnonymous}',
      );
      final StoryRoomRepository repo = GetIt.I<StoryRoomRepository>();
      // Prevent indefinite wait: timeout fallback closes dialog without navigation
      room = await repo
          .createRoom(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            creatorNickname: widget.creatorNickname,
            creatorUserId: widget.creatorUserId,
            storyStarter: _currentStarter,
          )
          .timeout(AppTimeouts.createRoom);

      if (mounted) {
        logger.i('[UI][CreateRoom] success, closing dialog');
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          try {
            if (Navigator.canPop(context)) {
              logger.d('[UI][CreateRoom] pop via local navigator');
              Navigator.pop(context, room);
              return;
            }
          } catch (_) {}
          try {
            logger.d('[UI][CreateRoom] pop via root navigator');
            Navigator.of(context, rootNavigator: true).pop(room);
            return;
          } catch (_) {}
          // Final fallback: slight delay then attempt root pop again
          await Future<void>.delayed(const Duration(milliseconds: 100));
          if (!mounted) return;
          try {
            logger.d('[UI][CreateRoom] fallback delayed root pop');
            Navigator.of(context, rootNavigator: true).pop(room);
          } catch (e) {
            logger.e('[UI][CreateRoom] pop failed: $e');
          }
        });
      }
    } on TimeoutException {
      logger.w('[UI][CreateRoom] timeout; closing dialog without navigation');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          try {
            if (Navigator.canPop(context)) {
              Navigator.pop(context, null);
              return;
            }
          } catch (_) {}
          try {
            Navigator.of(context, rootNavigator: true).pop(null);
          } catch (e) {
            logger.e('[UI][CreateRoom] timeout pop failed: $e');
          }
        });
      }
    } catch (e) {
      logger.e('[UI][CreateRoom] failed: $e');
      if (mounted) {
        AppToast.show(context, '오류가 발생했습니다: $e');
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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
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
                          child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            '이야기 만들기',
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '함께 만들어갈 이야기를 시작해보세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Content - 스크롤 가능하게 변경
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '이야기 제목',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppTextField(
                            controller: _titleController,
                            hintText: '예: 마법의 숲에서',
                            maxLength: 50,
                            textInputAction: TextInputAction.next,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Random Story Starter Section
                      if (_currentStarter != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5EAF0), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF222222),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _currentStarter!.genre,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text(
                                      '랜덤 시작점',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF222222),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => setState(() => _currentStarter = null),
                                    icon: const Icon(Icons.close_rounded, size: 20),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.grey.withValues(alpha: 0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _currentStarter!.content,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Genre Selection and Generate Button
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '장르 선택 (선택사항)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFE5EAF0), width: 1),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _selectedGenre,
                                    isExpanded: true,
                                    borderRadius: BorderRadius.circular(12),
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      border: InputBorder.none,
                                      hintText: '전체',
                                    ),
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF222222),
                                    ),
                                    items:
                                        ['전체', ..._storyStarterService.getAvailableGenres()]
                                            .map(
                                              (genre) => DropdownMenuItem<String>(
                                                value: genre,
                                                child: Text(genre),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedGenre = value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                height: 56, // Match text field height
                                child: ElevatedButton.icon(
                                  onPressed: _generateRandomStarter,
                                  icon: const Icon(Icons.auto_awesome, size: 20),
                                  label: const Text('랜덤'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    backgroundColor: const Color(0xFF222222),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Description field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '이야기 설명 (선택사항)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppTextField(
                            controller: _descriptionController,
                            hintText: '이야기의 배경이나 설정을 간단히 설명해주세요',
                            maxLines: 3,
                            maxLength: 200,
                            textInputAction: TextInputAction.newline,
                            keyboardType: TextInputType.multiline,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              // Action buttons - 하단에 고정
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Color(0xFF222222), width: 1.5),
                          backgroundColor: Colors.white,
                          overlayColor: const Color(0xFF222222).withValues(alpha: 0.1),
                        ),
                        child: const Text(
                          '취소',
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
                        onPressed: _isLoading ? null : _createRoom,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF222222),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          shadowColor: Colors.transparent,
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
                                : const Text(
                                  '만들기',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
