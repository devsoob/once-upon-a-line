import 'package:cloud_firestore/cloud_firestore.dart';

class StorySentence {
  final String id;
  final String roomId;
  final String content;
  final String authorNickname;
  final String? authorUserId;
  final DateTime createdAt;
  final int order;

  StorySentence({
    required this.id,
    required this.roomId,
    required this.content,
    required this.authorNickname,
    this.authorUserId,
    required this.createdAt,
    required this.order,
  });

  Map<String, dynamic> toFirestore() {
    final Map<String, dynamic> map = {
      'roomId': roomId,
      'content': content,
      'authorNickname': authorNickname,
      'createdAt': Timestamp.fromDate(createdAt),
      'order': order,
    };
    if (authorUserId != null) {
      map['authorUserId'] = authorUserId;
    }
    return map;
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
      authorUserId: data['authorUserId']?.toString(),
      createdAt: parseTimestamp(data['createdAt']),
      order: parseInt(data['order']),
    );
  }

  StorySentence copyWith({
    String? roomId,
    String? content,
    String? authorNickname,
    String? authorUserId,
    DateTime? createdAt,
    int? order,
  }) {
    return StorySentence(
      id: id,
      roomId: roomId ?? this.roomId,
      content: content ?? this.content,
      authorNickname: authorNickname ?? this.authorNickname,
      authorUserId: authorUserId ?? this.authorUserId,
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
      'authorUserId': authorUserId,
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
      authorUserId: data['authorUserId']?.toString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      order: data['order'] ?? 0,
    );
  }
}
