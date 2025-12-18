import 'dart:async';

import 'package:once_upon_a_line/app/data/models/story_room.dart';
import 'package:once_upon_a_line/app/data/models/story_starter.dart';
import 'package:once_upon_a_line/app/data/models/story_sentence.dart';
import 'package:once_upon_a_line/app/data/repositories/story_room_repository.dart';
import 'package:once_upon_a_line/app/data/repositories/story_sentence_repository.dart';
import 'package:once_upon_a_line/app/data/repositories/local_story_room_repository.dart';
import 'package:once_upon_a_line/app/data/repositories/local_story_sentence_repository.dart';

/// Adapters to expose local repositories via shared interfaces for UI simplicity.
class LocalStoryRoomRepositoryAdapter implements StoryRoomRepository {
  LocalStoryRoomRepositoryAdapter(this._local);

  final LocalStoryRoomRepository _local;

  final StreamController<List<StoryRoom>> _roomsController =
      StreamController<List<StoryRoom>>.broadcast();
  bool _initialized = false;

  Future<void> _emitCurrentRooms() async {
    final List<StoryRoom> rooms = await _local.getPublicRooms();
    if (!_roomsController.isClosed) {
      _roomsController.add(rooms);
    }
  }

  @override
  Stream<List<StoryRoom>> getPublicRooms() {
    if (!_initialized) {
      _initialized = true;
      // seed once
      unawaited(_emitCurrentRooms());
    }
    return _roomsController.stream;
  }

  @override
  Stream<StoryRoom?> getRoom(String roomId) {
    // Local repo exposes a one-shot stream; keep simple mapping
    return _local.getRoomStream(roomId);
  }

  @override
  Future<StoryRoom> createRoom({
    required String title,
    required String description,
    required String creatorNickname,
    required String creatorUserId,
    StoryStarter? storyStarter,
  }) async {
    final StoryRoom room = await _local.createRoom(
      title: title,
      description: description,
      creatorNickname: creatorNickname,
      creatorUserId: creatorUserId,
      storyStarter: storyStarter,
    );
    await _emitCurrentRooms();
    return room;
  }

  @override
  Stream<List<StoryRoom>> getMyRooms(String userId) {
    // For local implementation, filter the public rooms stream by userId
    return getPublicRooms().map(
      (rooms) =>
          rooms.where((room) {
            return room.creatorUserId == userId || room.participants.contains(userId);
          }).toList(),
    );
  }

  @override
  Future<List<StoryRoom>> getMyRoomsOnce(String userId) async {
    final List<StoryRoom> rooms = await _local.getPublicRooms();
    return rooms;
  }

  @override
  Future<void> joinRoom(String roomId, String nickname) async {
    await _local.joinRoom(roomId, nickname);
    await _emitCurrentRooms();
  }

  @override
  Future<void> leaveRoom(String roomId, String nickname) async {
    await _local.leaveRoom(roomId, nickname);
    await _emitCurrentRooms();
  }

  @override
  Future<void> updateRoom(StoryRoom room) => _local.updateRoom(room);

  @override
  Future<void> deleteRoom(String roomId) => _local.deleteRoom(roomId);

  void dispose() {
    _roomsController.close();
  }
}

class LocalStorySentenceRepositoryAdapter implements StorySentenceRepository {
  LocalStorySentenceRepositoryAdapter(this._local);

  final LocalStorySentenceRepository _local;

  @override
  Stream<List<StorySentence>> getSentences(String roomId) {
    return _local.getSentencesStream(roomId);
  }

  @override
  Future<StorySentence> addSentence({
    required String roomId,
    required String content,
    required String authorNickname,
    required String authorUserId,
  }) {
    return _local.addSentence(
      roomId: roomId,
      content: content,
      authorNickname: authorNickname,
      authorUserId: authorUserId,
    );
  }

  @override
  Future<void> deleteSentence(String sentenceId) => _local.deleteSentence(sentenceId);

  @override
  Future<void> deleteAllSentencesInRoom(String roomId) => _local.deleteAllSentencesInRoom(roomId);
}
