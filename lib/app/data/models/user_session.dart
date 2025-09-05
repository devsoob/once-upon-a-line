import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  final String nickname;
  final DateTime lastWriteAt;
  final List<String> joinedRooms;

  UserSession({required this.nickname, required this.lastWriteAt, this.joinedRooms = const []});

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'lastWriteAt': lastWriteAt.millisecondsSinceEpoch,
      'joinedRooms': joinedRooms,
    };
  }

  static UserSession fromJson(Map<String, dynamic> json) {
    return UserSession(
      nickname: json['nickname'] ?? '',
      lastWriteAt: DateTime.fromMillisecondsSinceEpoch(json['lastWriteAt'] ?? 0),
      joinedRooms: List<String>.from(json['joinedRooms'] ?? []),
    );
  }

  UserSession copyWith({String? nickname, DateTime? lastWriteAt, List<String>? joinedRooms}) {
    return UserSession(
      nickname: nickname ?? this.nickname,
      lastWriteAt: lastWriteAt ?? this.lastWriteAt,
      joinedRooms: joinedRooms ?? this.joinedRooms,
    );
  }

  static const String _sessionKey = 'user_session';

  static Future<UserSession?> load(SharedPreferences prefs) async {
    final String? jsonString = prefs.getString(_sessionKey);
    if (jsonString == null) return null;
    try {
      // Simple JSON-like format: nickname:value,lastWriteAt:value,joinedRooms:value1,value2
      final Map<String, dynamic> json = {};
      final List<String> pairs = jsonString.split(',');
      for (final String pair in pairs) {
        final List<String> keyValue = pair.split(':');
        if (keyValue.length == 2) {
          final String key = keyValue[0];
          final String value = keyValue[1];
          if (key == 'nickname') {
            json[key] = value;
          } else if (key == 'lastWriteAt') {
            json[key] = int.tryParse(value) ?? 0;
          } else if (key == 'joinedRooms') {
            json[key] = value.isEmpty ? <String>[] : value.split('|');
          }
        }
      }
      return fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(SharedPreferences prefs) async {
    final Map<String, dynamic> json = toJson();
    final List<String> pairs = [];
    pairs.add('nickname:${json['nickname']}');
    pairs.add('lastWriteAt:${json['lastWriteAt']}');
    pairs.add('joinedRooms:${(json['joinedRooms'] as List<String>).join('|')}');
    await prefs.setString(_sessionKey, pairs.join(','));
  }
}
