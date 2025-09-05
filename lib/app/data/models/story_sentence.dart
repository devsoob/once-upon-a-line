import 'package:cloud_firestore/cloud_firestore.dart';

class StorySentence {
  final String id;
  final String roomId;
  final String content;
  final String authorNickname;
  final DateTime createdAt;
  final int order;

  StorySentence({
    required this.id,
    required this.roomId,
    required this.content,
    required this.authorNickname,
    required this.createdAt,
    required this.order,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'roomId': roomId,
      'content': content,
      'authorNickname': authorNickname,
      'createdAt': Timestamp.fromDate(createdAt),
      'order': order,
    };
  }

  static StorySentence fromFirestore(String id, Map<String, dynamic> data) {
    return StorySentence(
      id: id,
      roomId: data['roomId'] ?? '',
      content: data['content'] ?? '',
      authorNickname: data['authorNickname'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      order: data['order'] ?? 0,
    );
  }

  StorySentence copyWith({
    String? roomId,
    String? content,
    String? authorNickname,
    DateTime? createdAt,
    int? order,
  }) {
    return StorySentence(
      id: id,
      roomId: roomId ?? this.roomId,
      content: content ?? this.content,
      authorNickname: authorNickname ?? this.authorNickname,
      createdAt: createdAt ?? this.createdAt,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'id': id,
      'roomId': roomId,
      'content': content,
      'authorNickname': authorNickname,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'order': order,
    };
  }

  static StorySentence fromLocalJson(Map<String, dynamic> data) {
    return StorySentence(
      id: data['id'] ?? '',
      roomId: data['roomId'] ?? '',
      content: data['content'] ?? '',
      authorNickname: data['authorNickname'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      order: data['order'] ?? 0,
    );
  }
}
