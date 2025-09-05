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

    // Get the next order number
    final QuerySnapshot<Map<String, dynamic>> lastSentenceQuery =
        await _sentencesCollection
            .where('roomId', isEqualTo: roomId)
            .orderBy('order', descending: true)
            .limit(1)
            .get();

    final int nextOrder =
        lastSentenceQuery.docs.isEmpty
            ? 1
            : (lastSentenceQuery.docs.first.data()['order'] as int) + 1;

    final StorySentence sentence = StorySentence(
      id: sentenceId,
      roomId: roomId,
      content: content,
      authorNickname: authorNickname,
      createdAt: now,
      order: nextOrder,
    );

    await _sentencesCollection.doc(sentenceId).set(sentence.toFirestore());
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
  }
}
