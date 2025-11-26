import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app/data/repositories/story_room_repository.dart';
import 'app/data/repositories/local_story_room_repository.dart';
import 'app/data/repositories/story_sentence_repository.dart';
import 'app/data/repositories/local_story_sentence_repository.dart';
import 'app/data/services/user_session_service.dart';
import 'app/data/services/story_starter_service.dart';
import 'app/data/services/random_sentence_service.dart';
import 'app/data/repositories/local_adapters.dart';
import 'core/logger.dart';

final GetIt di = GetIt.instance;
bool _isFirebaseInitialized = false;

class DiConfig {
  static Future<void> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    di.registerSingleton<SharedPreferences>(prefs);
    di.registerSingleton<FirebaseFirestore>(firestore);
    _isFirebaseInitialized = true;

    di.registerLazySingleton<StorySentenceRepository>(
      () => FirebaseStorySentenceRepository(di<FirebaseFirestore>()),
    );
    di.registerLazySingleton<StoryRoomRepository>(
      () => FirebaseStoryRoomRepository(di<FirebaseFirestore>()),
    );

    di.registerLazySingleton<UserSessionService>(
      () => LocalUserSessionService(di<SharedPreferences>()),
    );

    di.registerLazySingleton<StoryStarterService>(() => StoryStarterService());
    di.registerLazySingleton<RandomSentenceService>(() => RandomSentenceService());
  }

  static Future<void> initWithoutFirebase() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      di.registerSingleton<SharedPreferences>(prefs);

      final LocalStoryRoomRepository localRoom = LocalStoryRoomRepository(di<SharedPreferences>());
      final LocalStorySentenceRepository localSentence = LocalStorySentenceRepository(
        di<SharedPreferences>(),
      );
      di.registerSingleton<LocalStoryRoomRepository>(localRoom);
      di.registerSingleton<LocalStorySentenceRepository>(localSentence);
      di.registerLazySingleton<StoryRoomRepository>(
        () => LocalStoryRoomRepositoryAdapter(localRoom),
      );
      di.registerLazySingleton<StorySentenceRepository>(
        () => LocalStorySentenceRepositoryAdapter(localSentence),
      );

      di.registerLazySingleton<UserSessionService>(
        () => LocalUserSessionService(di<SharedPreferences>()),
      );

      // StoryStarterService는 Firebase 의존성이 없으므로 안전하게 초기화
      di.registerLazySingleton<StoryStarterService>(() => StoryStarterService());
      di.registerLazySingleton<RandomSentenceService>(() => RandomSentenceService());
    } catch (e) {
      logger.e('[DiConfig] initWithoutFirebase failed: $e');
      rethrow;
    }
  }

  static bool get isFirebaseInitialized => _isFirebaseInitialized;
}
