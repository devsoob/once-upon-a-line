import 'package:cloud_firestore/cloud_firestore.dart';

class StoryRoom {
  final String id;
  final String title;
  final String description;
  final String creatorNickname;
  final String? creatorUserId;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;
  final List<String> participants;
  final bool isPublic;
  final String? coverImageUrl;
  final int totalSentences;

  StoryRoom({
    required this.id,
    required this.title,
    required this.description,
    required this.creatorNickname,
    this.creatorUserId,
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.participants,
    this.isPublic = true,
    this.coverImageUrl,
    this.totalSentences = 0,
  });

  Map<String, dynamic> toFirestore() {
    final Map<String, dynamic> map = {
      'title': title,
      'description': description,
      'creatorNickname': creatorNickname,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
      'participants': participants,
      'isPublic': isPublic,
      'coverImageUrl': coverImageUrl,
      'totalSentences': totalSentences,
    };
    if (creatorUserId != null) {
      map['creatorUserId'] = creatorUserId;
    }
    return map;
  }

  static StoryRoom fromFirestore(String id, Map<String, dynamic> data) {
    // Safe parsing with fallbacks to prevent runtime errors if fields are missing or malformed
    DateTime parseTimestamp(dynamic value, {DateTime? fallback}) {
      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) {
        // Attempt to parse ISO8601
        try {
          return DateTime.parse(value);
        } catch (_) {}
      }
      return fallback ?? DateTime.now();
    }

    List<String> parseStringList(dynamic value) {
      if (value is List) {
        return value.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList();
      }
      return <String>[];
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

    return StoryRoom(
      id: id,
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      creatorNickname: (data['creatorNickname'] ?? '').toString(),
      creatorUserId: data['creatorUserId']?.toString(),
      createdAt: parseTimestamp(data['createdAt']),
      lastUpdatedAt: parseTimestamp(data['lastUpdatedAt']),
      participants: parseStringList(data['participants']),
      isPublic: (data['isPublic'] is bool) ? data['isPublic'] as bool : true,
      coverImageUrl: data['coverImageUrl']?.toString(),
      totalSentences: parseInt(data['totalSentences']),
    );
  }

  StoryRoom copyWith({
    String? title,
    String? description,
    String? creatorNickname,
    String? creatorUserId,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
    List<String>? participants,
    bool? isPublic,
    String? coverImageUrl,
    int? totalSentences,
  }) {
    return StoryRoom(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorNickname: creatorNickname ?? this.creatorNickname,
      creatorUserId: creatorUserId ?? this.creatorUserId,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      participants: participants ?? this.participants,
      isPublic: isPublic ?? this.isPublic,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      totalSentences: totalSentences ?? this.totalSentences,
    );
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'creatorNickname': creatorNickname,
      'creatorUserId': creatorUserId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastUpdatedAt': lastUpdatedAt.millisecondsSinceEpoch,
      'participants': participants,
      'isPublic': isPublic,
      'coverImageUrl': coverImageUrl,
      'totalSentences': totalSentences,
    };
  }

  static StoryRoom fromLocalJson(Map<String, dynamic> data) {
    return StoryRoom(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      creatorNickname: data['creatorNickname'] ?? '',
      creatorUserId: data['creatorUserId']?.toString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      lastUpdatedAt: DateTime.fromMillisecondsSinceEpoch(data['lastUpdatedAt'] ?? 0),
      participants: List<String>.from(data['participants'] ?? []),
      isPublic: data['isPublic'] ?? true,
      coverImageUrl: data['coverImageUrl'],
      totalSentences: data['totalSentences'] ?? 0,
    );
  }
}
