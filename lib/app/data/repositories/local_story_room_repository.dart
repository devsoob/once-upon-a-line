import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:once_upon_a_line/app/data/models/story_room.dart';
import 'package:once_upon_a_line/app/data/models/story_sentence.dart';

class LocalStoryRoomRepository {
  LocalStoryRoomRepository(this._prefs);

  final SharedPreferences _prefs;
  final Uuid _uuid = const Uuid();
  static const String _kRoomsKey = 'story_rooms_local';

  Future<List<StoryRoom>> getPublicRooms() async {
    final String? jsonString = _prefs.getString(_kRoomsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return <StoryRoom>[];
    }
    try {
      final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
      final List<StoryRoom> rooms =
          decoded
              .whereType<Map<String, dynamic>>()
              .map((data) => StoryRoom.fromLocalJson(data))
              .where((room) => room.isPublic)
              .toList();

      // Update totalSentences with actual count
      for (int i = 0; i < rooms.length; i++) {
        final int actualSentenceCount = await _getActualSentenceCount(rooms[i].id);
        if (actualSentenceCount != rooms[i].totalSentences) {
          rooms[i] = rooms[i].copyWith(totalSentences: actualSentenceCount);
        }
      }

      rooms.sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
      return rooms;
    } catch (_) {
      return <StoryRoom>[];
    }
  }

  Stream<List<StoryRoom>> getPublicRoomsStream() async* {
    yield await getPublicRooms();
  }

  Future<StoryRoom?> getRoom(String roomId) async {
    final List<StoryRoom> rooms = await getPublicRooms();
    try {
      return rooms.firstWhere((room) => room.id == roomId);
    } catch (_) {
      return null;
    }
  }

  Stream<StoryRoom?> getRoomStream(String roomId) async* {
    yield await getRoom(roomId);
  }

  Future<StoryRoom> createRoom({
    required String title,
    required String description,
    required String creatorNickname,
    required String creatorUserId,
  }) async {
    final String roomId = _uuid.v4();
    final DateTime now = DateTime.now();

    final StoryRoom room = StoryRoom(
      id: roomId,
      title: title,
      description: description,
      creatorNickname: creatorNickname,
      creatorUserId: creatorUserId,
      createdAt: now,
      lastUpdatedAt: now,
      participants: [creatorNickname],
      isPublic: true,
    );

    final List<StoryRoom> rooms = await getPublicRooms();
    rooms.add(room);
    await _saveRooms(rooms);
    return room;
  }

  Future<void> joinRoom(String roomId, String nickname) async {
    final List<StoryRoom> rooms = await getPublicRooms();
    final int roomIndex = rooms.indexWhere((room) => room.id == roomId);

    if (roomIndex != -1) {
      final StoryRoom room = rooms[roomIndex];
      final List<String> updatedParticipants = List.from(room.participants);

      if (!updatedParticipants.contains(nickname)) {
        updatedParticipants.add(nickname);
      }

      final StoryRoom updatedRoom = room.copyWith(
        participants: updatedParticipants,
        lastUpdatedAt: DateTime.now(),
      );

      rooms[roomIndex] = updatedRoom;
      await _saveRooms(rooms);
    }
  }

  Future<void> leaveRoom(String roomId, String nickname) async {
    final List<StoryRoom> rooms = await getPublicRooms();
    final int roomIndex = rooms.indexWhere((room) => room.id == roomId);

    if (roomIndex != -1) {
      final StoryRoom room = rooms[roomIndex];
      final List<String> updatedParticipants = List.from(room.participants);
      updatedParticipants.remove(nickname);

      final StoryRoom updatedRoom = room.copyWith(
        participants: updatedParticipants,
        lastUpdatedAt: DateTime.now(),
      );

      rooms[roomIndex] = updatedRoom;
      await _saveRooms(rooms);
    }
  }

  Future<void> updateRoom(StoryRoom room) async {
    // Temporarily disabled per MVP scope.
    throw UnsupportedError('updateRoom is disabled in current MVP');
  }

  Future<void> deleteRoom(String roomId) async {
    // Temporarily disabled per MVP scope.
    throw UnsupportedError('deleteRoom is disabled in current MVP');
  }

  Future<void> _saveRooms(List<StoryRoom> rooms) async {
    await _prefs.setString(
      _kRoomsKey,
      json.encode(rooms.map((room) => room.toLocalJson()).toList()),
    );
  }

  Future<int> _getActualSentenceCount(String roomId) async {
    final String? jsonString = _prefs.getString('story_sentences_local');
    if (jsonString == null || jsonString.isEmpty) {
      return 0;
    }
    try {
      final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((data) => StorySentence.fromLocalJson(data))
          .where((sentence) => sentence.roomId == roomId)
          .length;
    } catch (_) {
      return 0;
    }
  }
}
