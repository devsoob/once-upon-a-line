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

    // Primary path: transaction to atomically increment counter and write sentence
    late final StorySentence sentence;
    try {
      await _firestore.runTransaction((transaction) async {
        final DocumentReference<Map<String, dynamic>> roomRef =
            _firestore.collection('story_rooms').doc(roomId);
        final DocumentSnapshot<Map<String, dynamic>> roomSnap = await transaction.get(roomRef);

        if (!roomSnap.exists) {
          // Initialize counter as 0 if room doc missing
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
    } catch (e, st) {
      // Fallback path for environments where transaction fails (e.g., iOS unknown error)
      if (kDebugMode) {
        debugPrint('[Repo][Sentence] transaction failed: $e');
        debugPrint('$st');
        debugPrint('[Repo][Sentence] falling back to batch (non-transactional)');
      }

      final DocumentReference<Map<String, dynamic>> roomRef =
          _firestore.collection('story_rooms').doc(roomId);
      final DocumentSnapshot<Map<String, dynamic>> roomSnap = await roomRef.get();
      final int currentTotal = (roomSnap.data()?['totalSentences'] ?? 0) as int;
      final int nextOrder = currentTotal + 1;

      sentence = StorySentence(
        id: sentenceId,
        roomId: roomId,
        content: content,
        authorNickname: authorNickname,
        createdAt: now,
        order: nextOrder,
      );

      final WriteBatch batch = _firestore.batch();
      if (roomSnap.exists) {
        batch.update(roomRef, {
          'totalSentences': FieldValue.increment(1),
          'lastUpdatedAt': Timestamp.fromDate(now),
        });
      } else {
        batch.set(roomRef, {
          'totalSentences': nextOrder,
          'lastUpdatedAt': Timestamp.fromDate(now),
        }, SetOptions(merge: true));
      }
      final DocumentReference<Map<String, dynamic>> sentenceRef =
          _sentencesCollection.doc(sentenceId);
      batch.set(sentenceRef, sentence.toFirestore());
      await batch.commit();
    }

    if (kDebugMode) {
      debugPrint('[Repo][Sentence] addSentence success id=$sentenceId order=${sentence.order}');
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
