import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:once_upon_a_line/app/data/models/story_room.dart';

abstract class StoryRoomRepository {
  Stream<List<StoryRoom>> getPublicRooms();
  Stream<StoryRoom?> getRoom(String roomId);
  Future<StoryRoom> createRoom({
    required String title,
    required String description,
    required String creatorNickname,
  });
  Future<void> joinRoom(String roomId, String nickname);
  Future<void> leaveRoom(String roomId, String nickname);
  Future<void> updateRoom(StoryRoom room);
  Future<void> deleteRoom(String roomId);
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
  }) async {
    final String roomId = _uuid.v4();
    final DateTime now = DateTime.now();

    final StoryRoom room = StoryRoom(
      id: roomId,
      title: title,
      description: description,
      creatorNickname: creatorNickname,
      createdAt: now,
      lastUpdatedAt: now,
      participants: [creatorNickname],
      isPublic: true,
    );
    if (kDebugMode) {
      debugPrint('[Repo][Room] createRoom start title="$title" by "$creatorNickname"');
    }
    // Optimistic write: do not await to avoid UI stall on iOS simulator
    _roomsCollection.doc(roomId).set(room.toFirestore()).catchError((e, st) {
      if (kDebugMode) {
        debugPrint('[Repo][Room] createRoom async set error: $e');
        debugPrint(st.toString());
      }
    });
    if (kDebugMode) {
      debugPrint('[Repo][Room] createRoom enqueued id=$roomId');
    }
    return room;
  }

  @override
  Future<void> joinRoom(String roomId, String nickname) async {
    if (kDebugMode) {
      debugPrint('[Repo][Room] joinRoom roomId=$roomId nickname=$nickname');
    }
    final DocumentReference<Map<String, dynamic>> docRef = _roomsCollection.doc(roomId);
    await _firestore.runTransaction((transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final StoryRoom room = StoryRoom.fromFirestore(snapshot.id, snapshot.data()!);

      if (!room.participants.contains(nickname)) {
        final StoryRoom updated = room.copyWith(
          participants: [...room.participants, nickname],
          lastUpdatedAt: DateTime.now(),
        );
        transaction.update(docRef, updated.toFirestore());
      }
    });
  }

  @override
  Future<void> leaveRoom(String roomId, String nickname) async {
    if (kDebugMode) {
      debugPrint('[Repo][Room] leaveRoom roomId=$roomId nickname=$nickname');
    }
    final DocumentReference<Map<String, dynamic>> docRef = _roomsCollection.doc(roomId);
    await _firestore.runTransaction((transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final StoryRoom room = StoryRoom.fromFirestore(snapshot.id, snapshot.data()!);

      if (room.participants.contains(nickname)) {
        final StoryRoom updated = room.copyWith(
          participants: room.participants.where((p) => p != nickname).toList(),
          lastUpdatedAt: DateTime.now(),
        );
        transaction.update(docRef, updated.toFirestore());
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
