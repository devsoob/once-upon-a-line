import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:once_upon_a_line/app/data/models/story_room.dart';
import 'package:once_upon_a_line/app/data/models/story_starter.dart';
import 'package:once_upon_a_line/core/logger.dart';

abstract class StoryRoomRepository {
  Stream<List<StoryRoom>> getPublicRooms();
  Stream<StoryRoom?> getRoom(String roomId);
  Future<StoryRoom> createRoom({
    required String title,
    required String description,
    required String creatorNickname,
    required String creatorUserId,
    StoryStarter? storyStarter,
  });
  Future<void> joinRoom(String roomId, String nickname);
  Future<void> leaveRoom(String roomId, String nickname);
  Future<void> updateRoom(StoryRoom room);
  Future<void> deleteRoom(String roomId);

  // Get my rooms - both created and participated
  Stream<List<StoryRoom>> getMyRooms(String userId);
  Future<List<StoryRoom>> getMyRoomsOnce(String userId);
}

class FirebaseStoryRoomRepository implements StoryRoomRepository {
  FirebaseStoryRoomRepository(this._firestore);

  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _roomsCollection =>
      _firestore.collection('story_rooms');

  @override
  Stream<List<StoryRoom>> getPublicRooms() {
    return _roomsCollection
        .where('isPublic', isEqualTo: true)
        .orderBy('lastUpdatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => StoryRoom.fromFirestore(doc.id, doc.data())).toList(),
        );
  }

  @override
  Stream<StoryRoom?> getRoom(String roomId) {
    return _roomsCollection
        .doc(roomId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.exists ? StoryRoom.fromFirestore(snapshot.id, snapshot.data()!) : null,
        );
  }

  @override
  Future<StoryRoom> createRoom({
    required String title,
    required String description,
    required String creatorNickname,
    required String creatorUserId,
    StoryStarter? storyStarter,
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
      participants: <String>[creatorNickname],
      isPublic: true,
      storyStarter: storyStarter,
    );
    if (kDebugMode) {
      logger.i('[Repo][Room] createRoom start title="$title" by "$creatorNickname"');
    }
    try {
      // IMPORTANT: await the write so UI can correctly show failure (permission-denied, etc.)
      if (kDebugMode) {
        logger.d('[Repo][Room] createRoom payload=${room.toFirestore()}');
      }
      await _roomsCollection.doc(roomId).set(room.toFirestore());
      if (kDebugMode) {
        logger.i('[Repo][Room] createRoom success id=$roomId');
      }
    } catch (e, st) {
      if (kDebugMode) {
        logger.e('[Repo][Room] createRoom set error: $e', error: e, stackTrace: st);
      }
      rethrow;
    }
    return room;
  }

  @override
  Stream<List<StoryRoom>> getMyRooms(String userId) {
    return _roomsCollection
        .where('isPublic', isEqualTo: true)
        .orderBy('lastUpdatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final List<StoryRoom> allRooms =
              snapshot.docs.map((doc) => StoryRoom.fromFirestore(doc.id, doc.data())).toList();
          // Return all public rooms - filtering by creator/participant happens in UI
          // because participants array contains nicknames, not user IDs
          return allRooms;
        });
  }

  @override
  Future<List<StoryRoom>> getMyRoomsOnce(String userId) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _roomsCollection
            .where('isPublic', isEqualTo: true)
            .orderBy('lastUpdatedAt', descending: true)
            .get();

    return snapshot.docs.map((doc) => StoryRoom.fromFirestore(doc.id, doc.data())).toList();
  }

  @override
  Future<void> joinRoom(String roomId, String nickname) async {
    if (kDebugMode) {
      logger.d('[Repo][Room] joinRoom roomId=$roomId nickname=$nickname');
    }
    final DocumentReference<Map<String, dynamic>> docRef = _roomsCollection.doc(roomId);
    await _firestore.runTransaction((transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final List<dynamic> participantsRaw =
          (snapshot.data()?['participants'] ?? <dynamic>[]) as List;
      final List<String> participants = participantsRaw.map((e) => e.toString()).toList();
      if (!participants.contains(nickname)) {
        final DateTime now = DateTime.now();
        transaction.update(docRef, <String, Object?>{
          'participants': FieldValue.arrayUnion(<String>[nickname]),
          'lastUpdatedAt': Timestamp.fromDate(now),
        });
      }
    });
  }

  @override
  Future<void> leaveRoom(String roomId, String nickname) async {
    if (kDebugMode) {
      logger.d('[Repo][Room] leaveRoom roomId=$roomId nickname=$nickname');
    }
    final DocumentReference<Map<String, dynamic>> docRef = _roomsCollection.doc(roomId);
    await _firestore.runTransaction((transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final List<dynamic> participantsRaw =
          (snapshot.data()?['participants'] ?? <dynamic>[]) as List;
      final List<String> participants = participantsRaw.map((e) => e.toString()).toList();
      if (participants.contains(nickname)) {
        final DateTime now = DateTime.now();
        transaction.update(docRef, <String, Object?>{
          'participants': FieldValue.arrayRemove(<String>[nickname]),
          'lastUpdatedAt': Timestamp.fromDate(now),
        });
      }
    });
  }

  @override
  Future<void> updateRoom(StoryRoom room) async {
    // Temporarily disabled per MVP scope: only create/join/leave are allowed.
    throw UnsupportedError('updateRoom is disabled in current MVP');
  }

  @override
  Future<void> deleteRoom(String roomId) async {
    // Temporarily disabled per MVP scope.
    throw UnsupportedError('deleteRoom is disabled in current MVP');
  }
}
