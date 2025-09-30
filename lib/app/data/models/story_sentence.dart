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
    DateTime parseTimestamp(dynamic value, {DateTime? fallback}) {
      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {}
      }
      return fallback ?? DateTime.now();
    }

    int parseInt(dynamic value, {int fallback = 0}) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final int? parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      return fallback;
    }

    return StorySentence(
      id: id,
      roomId: (data['roomId'] ?? '').toString(),
      content: (data['content'] ?? '').toString(),
      authorNickname: (data['authorNickname'] ?? '').toString(),
      createdAt: parseTimestamp(data['createdAt']),
      order: parseInt(data['order']),
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
