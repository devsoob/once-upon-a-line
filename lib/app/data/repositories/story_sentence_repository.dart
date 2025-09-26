import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:once_upon_a_line/app/data/models/story_sentence.dart';

abstract class StorySentenceRepository {
  Stream<List<StorySentence>> getSentences(String roomId);
  Future<StorySentence> addSentence({
    required String roomId,
    required String content,
    required String authorNickname,
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
  }) async {
    final String sentenceId = _uuid.v4();
    final DateTime now = DateTime.now();

    if (kDebugMode) {
      debugPrint('[Repo][Sentence] addSentence start roomId=$roomId by "$authorNickname"');
    }

    // Use a transaction to get and increment the room's counter, then write the sentence
    late final StorySentence sentence;
    await _firestore.runTransaction((transaction) async {
      final DocumentReference<Map<String, dynamic>> roomRef =
          _firestore.collection('story_rooms').doc(roomId);
      final DocumentSnapshot<Map<String, dynamic>> roomSnap = await transaction.get(roomRef);

      if (!roomSnap.exists) {
        // If room doc does not exist, initialize counter as 0
        transaction.set(roomRef, {
          'totalSentences': 0,
          'lastUpdatedAt': Timestamp.fromDate(now),
        }, SetOptions(merge: true));
      }

      final int currentTotal = (roomSnap.data()?['totalSentences'] ?? 0) as int;
      final int nextOrder = currentTotal + 1;

      // Update room counters and lastUpdatedAt
      transaction.update(roomRef, {
        'totalSentences': nextOrder,
        'lastUpdatedAt': Timestamp.fromDate(now),
      });

      // Prepare and write the new sentence with the computed order
      sentence = StorySentence(
        id: sentenceId,
        roomId: roomId,
        content: content,
        authorNickname: authorNickname,
        createdAt: now,
        order: nextOrder,
      );
      final DocumentReference<Map<String, dynamic>> sentenceRef =
          _sentencesCollection.doc(sentenceId);
      transaction.set(sentenceRef, sentence.toFirestore());
    });

    if (kDebugMode) {
      debugPrint('[Repo][Sentence] addSentence success id=$sentenceId order=${sentence.order}');
    }
    return sentence;
  }

  @override
  Future<void> deleteSentence(String sentenceId) async {
    await _sentencesCollection.doc(sentenceId).delete();
  }

  @override
  Future<void> deleteAllSentencesInRoom(String roomId) async {
    final QuerySnapshot<Map<String, dynamic>> sentencesQuery =
        await _sentencesCollection.where('roomId', isEqualTo: roomId).get();

    final WriteBatch batch = _firestore.batch();
    for (final DocumentSnapshot<Map<String, dynamic>> doc in sentencesQuery.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    // Reset room counters after deletion for consistency
    try {
      await _firestore.collection('story_rooms').doc(roomId).update({
        'totalSentences': 0,
        'lastUpdatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (_) {
      // ignore if room doesn't exist
    }
  }
}
