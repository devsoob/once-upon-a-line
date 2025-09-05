import 'package:cloud_firestore/cloud_firestore.dart';

class StoryRoom {
  final String id;
  final String title;
  final String description;
  final String creatorNickname;
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
    required this.createdAt,
    required this.lastUpdatedAt,
    required this.participants,
    this.isPublic = true,
    this.coverImageUrl,
    this.totalSentences = 0,
  });

  Map<String, dynamic> toFirestore() {
    return {
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
  }

  static StoryRoom fromFirestore(String id, Map<String, dynamic> data) {
    return StoryRoom(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      creatorNickname: data['creatorNickname'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastUpdatedAt: (data['lastUpdatedAt'] as Timestamp).toDate(),
      participants: List<String>.from(data['participants'] ?? []),
      isPublic: data['isPublic'] ?? true,
      coverImageUrl: data['coverImageUrl'],
      totalSentences: data['totalSentences'] ?? 0,
    );
  }

  StoryRoom copyWith({
    String? title,
    String? description,
    String? creatorNickname,
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
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0),
      lastUpdatedAt: DateTime.fromMillisecondsSinceEpoch(data['lastUpdatedAt'] ?? 0),
      participants: List<String>.from(data['participants'] ?? []),
      isPublic: data['isPublic'] ?? true,
      coverImageUrl: data['coverImageUrl'],
      totalSentences: data['totalSentences'] ?? 0,
    );
  }
}
