import 'package:shared_preferences/shared_preferences.dart';
import 'package:once_upon_a_line/app/data/models/user_session.dart';

abstract class UserSessionService {
  Future<UserSession?> getCurrentSession();
  Future<void> saveSession(UserSession session);
  Future<void> clearSession();
  Future<bool> hasSession();
}

class LocalUserSessionService implements UserSessionService {
  LocalUserSessionService(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<UserSession?> getCurrentSession() async {
    return await UserSession.load(_prefs);
  }

  @override
  Future<void> saveSession(UserSession session) async {
    await session.save(_prefs);
  }

  @override
  Future<void> clearSession() async {
    await _prefs.remove('user_session');
  }

  @override
  Future<bool> hasSession() async {
    final UserSession? session = await getCurrentSession();
    return session != null && session.nickname.isNotEmpty;
  }
}
