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
import '../../../../app/data/services/guided_experience_service.dart';
import 'package:once_upon_a_line/core/logger.dart';
import 'package:once_upon_a_line/core/constants/timeouts.dart';
import 'beginner_onboarding_dialog.dart';

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
  bool _showGuidedOptions = true;
  int _selectedTabIndex = 0;

  late final StoryStarterService _storyStarterService;
  late final GuidedExperienceService _guidedExperienceService;
  StoryStarter? _currentStarter;
  WritingPrompt? _selectedPrompt;
  StoryTemplate? _selectedTemplate;
  String _selectedGenre = '전체';
  String _selectedPromptCategory = '시작하기';

  @override
  void initState() {
    super.initState();
    _storyStarterService = GetIt.I<StoryStarterService>();
    _guidedExperienceService = GetIt.I<GuidedExperienceService>();
    _checkFirstTimeUser();
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

  void _checkFirstTimeUser() async {
    final isFirstTime = await _guidedExperienceService.isFirstTimeUser();
    if (isFirstTime && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOnboardingDialog();
      });
    }
  }

  void _showOnboardingDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => const BeginnerOnboardingDialog(),
    );
  }

  void _applyWritingPrompt(WritingPrompt prompt) {
    setState(() {
      _selectedPrompt = prompt;
      _titleController.text = prompt.title;
      _descriptionController.text = prompt.description;
    });
  }

  void _applyStoryTemplate(StoryTemplate template) {
    setState(() {
      _selectedTemplate = template;
      _titleController.text = template.title;
      _descriptionController.text = template.description;
    });
  }

  void _toggleGuidedOptions() {
    setState(() {
      _showGuidedOptions = !_showGuidedOptions;
    });
  }

  Widget _buildTabButton(String label, int index, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12),
          bottomLeft: index == 0 ? const Radius.circular(12) : const Radius.circular(0),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF222222) : Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              bottomLeft: index == 0 ? const Radius.circular(12) : const Radius.circular(0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : const Color(0xFF666666)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildStoryStartersTab();
      case 1:
        return _buildWritingPromptsTab();
      case 2:
        return _buildTemplatesTab();
      case 3:
        return _buildWritingTipsTab();
      default:
        return _buildStoryStartersTab();
    }
  }

  Widget _buildStoryStartersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Genre selection and generate button
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: InputBorder.none,
                    hintText: '전체',
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF222222),
                  ),
                  items:
                      ['전체', ..._storyStarterService.getAvailableGenres()]
                          .map(
                            (genre) => DropdownMenuItem<String>(value: genre, child: Text(genre)),
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
            ElevatedButton.icon(
              onPressed: _generateRandomStarter,
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('랜덤', style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                backgroundColor: const Color(0xFF222222),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Current starter display
        if (_currentStarter != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
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
                          fontSize: 11,
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
                      icon: const Icon(Icons.close_rounded, size: 16),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        ] else
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 48,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text('랜덤 시작점을 생성해보세요!', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWritingPromptsTab() {
    final prompts = _guidedExperienceService.getPromptsByCategory(_selectedPromptCategory);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category selector
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _guidedExperienceService.getPromptCategories().length,
            itemBuilder: (context, index) {
              final category = _guidedExperienceService.getPromptCategories()[index];
              final isSelected = category == _selectedPromptCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedPromptCategory = category;
                      });
                    }
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: const Color(0xFF222222),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF666666),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Prompts list
        Expanded(
          child: ListView.builder(
            itemCount: prompts.length,
            itemBuilder: (context, index) {
              final prompt = prompts[index];
              final isSelected = _selectedPrompt?.id == prompt.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => _applyWritingPrompt(prompt),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFF222222).withValues(alpha: 0.1)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF222222) : const Color(0xFFE5EAF0),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                prompt.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isSelected
                                          ? const Color(0xFF222222)
                                          : const Color(0xFF1C1C1E),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(prompt.difficulty),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getDifficultyLabel(prompt.difficulty),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prompt.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? const Color(0xFF222222) : const Color(0xFF666666),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemplatesTab() {
    final templates = _guidedExperienceService.getStoryTemplates();

    return ListView.builder(
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final isSelected = _selectedTemplate?.id == template.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _applyStoryTemplate(template),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF222222).withValues(alpha: 0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFF222222) : const Color(0xFFE5EAF0),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          template.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? const Color(0xFF222222) : const Color(0xFF1C1C1E),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          template.estimatedLength,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    template.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? const Color(0xFF222222) : const Color(0xFF666666),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      template.structure,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildWritingTipsTab() {
    final tips = _guidedExperienceService.getWritingTips();

    return ListView.builder(
      itemCount: tips.length,
      itemBuilder: (context, index) {
        final tip = tips[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5EAF0), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16, color: const Color(0xFFFF9800)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tip.category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  tip.description,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '예시: ${tip.example}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF555555),
                      fontStyle: FontStyle.italic,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return '초급';
      case 'intermediate':
        return '중급';
      case 'advanced':
        return '고급';
      default:
        return '일반';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return const Color(0xFF4CAF50);
      case 'intermediate':
        return const Color(0xFFFF9800);
      case 'advanced':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
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
                      // Guided Experience Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F8FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE1F5FE), width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.auto_awesome, color: const Color(0xFF1976D2), size: 20),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    '이야기 만들기 가이드',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1976D2),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _toggleGuidedOptions,
                                  icon: Icon(
                                    _showGuidedOptions ? Icons.expand_less : Icons.expand_more,
                                    color: const Color(0xFF1976D2),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '처음이신가요? 다양한 가이드와 템플릿을 활용해보세요!',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF1976D2).withValues(alpha: 0.8),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Guided Experience Options
                      if (_showGuidedOptions) ...[
                        // Tab navigation
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5EAF0), width: 1),
                          ),
                          child: Row(
                            children: [
                              _buildTabButton('시작점', 0, Icons.lightbulb_outline),
                              _buildTabButton('아이디어', 1, Icons.psychology_outlined),
                              _buildTabButton('템플릿', 2, Icons.library_books_outlined),
                              _buildTabButton('팁', 3, Icons.tips_and_updates_outlined),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tab content
                        SizedBox(height: 280, child: _buildTabContent()),
                        const SizedBox(height: 20),
                      ],

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
