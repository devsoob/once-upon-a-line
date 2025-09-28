import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:once_upon_a_line/app/data/models/story_sentence.dart';
import 'package:once_upon_a_line/app/data/models/story_room.dart';

class LocalStorySentenceRepository {
  LocalStorySentenceRepository(this._prefs);

  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();
  static const String _kSentencesKey = 'story_sentences_local';
  static const String _kRoomsKey = 'story_rooms_local';

  Future<List<StorySentence>> getSentences(String roomId) async {
    final String? jsonString = _prefs.getString(_kSentencesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return <StorySentence>[];
    }
    try {
      final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((data) => StorySentence.fromLocalJson(data))
          .where((sentence) => sentence.roomId == roomId)
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (_) {
      return <StorySentence>[];
    }
  }

  Stream<List<StorySentence>> getSentencesStream(String roomId) async* {
    yield await getSentences(roomId);
  }

  Future<StorySentence> addSentence({
    required String roomId,
    required String content,
    required String authorNickname,
  }) async {
    final String sentenceId = _uuid.v4();
    final DateTime now = DateTime.now();

    // Get the next order number
    final List<StorySentence> existingSentences = await getSentences(roomId);
    final int nextOrder =
        existingSentences.isEmpty
            ? 1
            : existingSentences.map((s) => s.order).reduce((a, b) => a > b ? a : b) + 1;

    final StorySentence sentence = StorySentence(
      id: sentenceId,
      roomId: roomId,
      content: content,
      authorNickname: authorNickname,
      createdAt: now,
      order: nextOrder,
    );

    final List<StorySentence> allSentences = await _getAllSentences();
    allSentences.add(sentence);
    await _saveAllSentences(allSentences);

    // Update room's totalSentences count
    await _updateRoomSentenceCount(roomId);

    return sentence;
  }

  Future<void> deleteSentence(String sentenceId) async {
    // Temporarily disabled per MVP scope.
    throw UnsupportedError('deleteSentence is disabled in current MVP');
  }

  Future<void> deleteAllSentencesInRoom(String roomId) async {
    // Temporarily disabled per MVP scope.
    throw UnsupportedError('deleteAllSentencesInRoom is disabled in current MVP');
  }

  Future<List<StorySentence>> _getAllSentences() async {
    final String? jsonString = _prefs.getString(_kSentencesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return <StorySentence>[];
    }
    try {
      final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((data) => StorySentence.fromLocalJson(data))
          .toList();
    } catch (_) {
      return <StorySentence>[];
    }
  }

  Future<void> _saveAllSentences(List<StorySentence> sentences) async {
    await _prefs.setString(
      _kSentencesKey,
      json.encode(sentences.map((sentence) => sentence.toLocalJson()).toList()),
    );
  }

  Future<void> _updateRoomSentenceCount(String roomId) async {
    final String? jsonString = _prefs.getString(_kRoomsKey);
    if (jsonString == null || jsonString.isEmpty) return;

    try {
      final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
      final List<StoryRoom> rooms =
          decoded
              .whereType<Map<String, dynamic>>()
              .map((data) => StoryRoom.fromLocalJson(data))
              .toList();

      final int roomIndex = rooms.indexWhere((room) => room.id == roomId);
      if (roomIndex != -1) {
        final int actualSentenceCount = await _getActualSentenceCount(roomId);
        rooms[roomIndex] = rooms[roomIndex].copyWith(
          totalSentences: actualSentenceCount,
          lastUpdatedAt: DateTime.now(),
        );

        await _prefs.setString(
          _kRoomsKey,
          json.encode(rooms.map((room) => room.toLocalJson()).toList()),
        );
      }
    } catch (_) {
      // Ignore errors
    }
  }

  Future<int> _getActualSentenceCount(String roomId) async {
    final List<StorySentence> allSentences = await _getAllSentences();
    return allSentences.where((sentence) => sentence.roomId == roomId).length;
  }
}
