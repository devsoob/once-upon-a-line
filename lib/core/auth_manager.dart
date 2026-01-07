import 'package:firebase_auth/firebase_auth.dart';
import '../core/logger.dart';

class AuthManager {
  static Future<void> signInAnonymouslyIfNotAuthenticated() async {
    logger.i('[Auth] Before signInAnonymously');
    final auth = FirebaseAuth.instance;

    try {
      // 이미 로그인된 사용자가 있는지 확인
      if (auth.currentUser == null) {
        await auth.signInAnonymously().timeout(const Duration(seconds: 10));
        logger.i('[Auth] signInAnonymously success: ${auth.currentUser?.uid}');
      } else {
        logger.i('[Auth] Already signed in: ${auth.currentUser?.uid}');
      }
      logger.i('[Auth] signInAnonymously OK');

      // Verify authentication succeeded
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || !user.isAnonymous) {
        logger.e('[Auth] Authentication failed - no valid user after signInAnonymously');
        throw Exception('Authentication failed - no valid user');
      }
      logger.i('[Auth] Successfully authenticated anonymously: ${user.uid}');
    } catch (e, st) {
      logger.e('[Auth] signInAnonymously failed: $e', error: e, stackTrace: st);

      // Check if user is already authenticated (might be a cached session)
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.isAnonymous) {
        logger.i('[Auth] Using existing anonymous session: ${currentUser.uid}');
        // Continue with existing session
      } else {
        // If sign-in fails and no existing session, switch to local mode
        logger.w(
          '[Auth] No existing session and signInAnonymously failed, switching to local mode',
        );
        // Don't throw error, continue with local mode initialization
      }
    }
  }

  static void debugHealthcheck() {
    final user = FirebaseAuth.instance.currentUser;
    logger.i('[Auth] isAnonymous=${user?.isAnonymous} uid=${user?.uid}');
  }
}
