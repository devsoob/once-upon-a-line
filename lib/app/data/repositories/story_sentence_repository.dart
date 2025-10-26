import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:once_upon_a_line/app/data/models/story_sentence.dart';
import 'package:once_upon_a_line/core/logger.dart';

abstract class StorySentenceRepository {
  Stream<List<StorySentence>> getSentences(String roomId);
  Future<StorySentence> addSentence({
    required String roomId,
    required String content,
    required String authorNickname,
    required String authorUserId,
  });
  Future<void> deleteSentence(String sentenceId);
  Future<void> deleteAllSentencesInRoom(String roomId);
}

class FirebaseStorySentenceRepository implements StorySentenceRepository {
  FirebaseStorySentenceRepository(this._firestore);

  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _sentencesCollection =>
      _firestore.collection('story_sentences');

  @override
  Stream<List<StorySentence>> getSentences(String roomId) {
    return _sentencesCollection
        .where('roomId', isEqualTo: roomId)
        .orderBy('order', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => StorySentence.fromFirestore(doc.id, doc.data())).toList(),
        );
  }

  @override
  Future<StorySentence> addSentence({
    required String roomId,
    required String content,
    required String authorNickname,
    required String authorUserId,
  }) async {
    final String sentenceId = _uuid.v4();
    final DateTime now = DateTime.now();

    if (kDebugMode) {
      logger.i('[Repo][Sentence] addSentence start roomId=$roomId by "$authorNickname"');
    }

    // Use non-transactional path (more stable on iOS simulator):
    // 1) Read room once to compute next order
    // 2) Batch: increment counter, update lastUpdatedAt, write sentence
    final DocumentReference<Map<String, dynamic>> roomRef = _firestore
        .collection('story_rooms')
        .doc(roomId);
    final DocumentSnapshot<Map<String, dynamic>> roomSnap = await roomRef.get();
    final int currentTotal = (roomSnap.data()?['totalSentences'] ?? 0) as int;
    final int nextOrder = currentTotal + 1;

    final StorySentence sentence = StorySentence(
      id: sentenceId,
      roomId: roomId,
      content: content.trim(),
      authorNickname: authorNickname,
      authorUserId: authorUserId,
      createdAt: now,
      order: nextOrder,
    );

    final WriteBatch batch = _firestore.batch();
    // Update the room document using increment to reduce race risk
    batch.set(roomRef, <String, Object?>{
      'totalSentences': FieldValue.increment(1),
      'lastUpdatedAt': Timestamp.fromDate(now),
    }, SetOptions(merge: true));

    final DocumentReference<Map<String, dynamic>> sentenceRef = _sentencesCollection.doc(
      sentenceId,
    );
    batch.set(sentenceRef, sentence.toFirestore());
    await batch.commit();

    if (kDebugMode) {
      logger.i('[Repo][Sentence] addSentence success id=$sentenceId order=${sentence.order}');
    }
    return sentence;
  }

  @override
  Future<void> deleteSentence(String sentenceId) async {
    // Temporarily disabled per MVP scope.
    throw UnsupportedError('deleteSentence is disabled in current MVP');
  }

  @override
  Future<void> deleteAllSentencesInRoom(String roomId) async {
    // Temporarily disabled per MVP scope.
    throw UnsupportedError('deleteAllSentencesInRoom is disabled in current MVP');
  }
}
