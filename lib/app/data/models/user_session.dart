import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  final String userId;
  final String nickname;
  final DateTime lastWriteAt;
  final List<String> joinedRooms;

  UserSession({
    required this.userId,
    required this.nickname,
    required this.lastWriteAt,
    this.joinedRooms = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'lastWriteAt': lastWriteAt.millisecondsSinceEpoch,
      'joinedRooms': joinedRooms,
    };
  }

  static UserSession fromJson(Map<String, dynamic> json) {
    return UserSession(
      userId: json['userId'] ?? '',
      nickname: json['nickname'] ?? '',
      lastWriteAt: DateTime.fromMillisecondsSinceEpoch(json['lastWriteAt'] ?? 0),
      joinedRooms: List<String>.from(json['joinedRooms'] ?? []),
    );
  }

  UserSession copyWith({
    String? userId,
    String? nickname,
    DateTime? lastWriteAt,
    List<String>? joinedRooms,
  }) {
    return UserSession(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      lastWriteAt: lastWriteAt ?? this.lastWriteAt,
      joinedRooms: joinedRooms ?? this.joinedRooms,
    );
  }

  static const String _sessionKey = 'user_session';

  static Future<UserSession?> load(SharedPreferences prefs) async {
    final String? stored = prefs.getString(_sessionKey);
    if (stored == null) return null;
    // Try JSON first
    try {
      final Map<String, dynamic> jsonMap = json.decode(stored) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } catch (_) {
      // Fallback to legacy delimited format: nickname:...,lastWriteAt:...,joinedRooms:a|b|c
      try {
        final Map<String, dynamic> map = <String, dynamic>{};
        final List<String> pairs = stored.split(',');
        for (final String pair in pairs) {
          final List<String> keyValue = pair.split(':');
          if (keyValue.length == 2) {
            final String key = keyValue[0];
            final String value = keyValue[1];
            if (key == 'userId') {
              map[key] = value;
            } else if (key == 'nickname') {
              map[key] = value;
            } else if (key == 'lastWriteAt') {
              map[key] = int.tryParse(value) ?? 0;
            } else if (key == 'joinedRooms') {
              map[key] = value.isEmpty ? <String>[] : value.split('|');
            }
          }
        }
        return fromJson(map);
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> save(SharedPreferences prefs) async {
    final Map<String, dynamic> map = toJson();
    await prefs.setString(_sessionKey, json.encode(map));
  }
}
