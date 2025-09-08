import 'package:flutter/material.dart';
import 'package:once_upon_a_line/core/design_system/colors.dart';
import 'package:get_it/get_it.dart';
import '../../../../app/data/repositories/story_room_repository.dart';
import '../../../../app/data/repositories/local_story_room_repository.dart';
import '../../../../app/data/models/story_room.dart';
import '../../../../di.dart';

class CreateRoomDialog extends StatefulWidget {
  const CreateRoomDialog({super.key, required this.creatorNickname});

  final String creatorNickname;

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      StoryRoom room;

      if (DiConfig.isFirebaseInitialized) {
        final StoryRoomRepository firebaseRepo = GetIt.I<StoryRoomRepository>();
        room = await firebaseRepo.createRoom(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          creatorNickname: widget.creatorNickname,
        );
      } else {
        final LocalStoryRoomRepository localRepo = GetIt.I<LocalStoryRoomRepository>();
        room = await localRepo.createRoom(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          creatorNickname: widget.creatorNickname,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(room);
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '새 이야기 만들기',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '이야기 제목',
                hintText: '예: 마법의 숲에서',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              maxLength: 50,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '이야기 설명 (선택사항)',
                hintText: '이야기의 배경이나 설정을 간단히 설명해주세요',
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createRoom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
