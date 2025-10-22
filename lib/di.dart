import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app/data/repositories/story_room_repository.dart';
import 'app/data/repositories/local_story_room_repository.dart';
import 'app/data/repositories/story_sentence_repository.dart';
import 'app/data/repositories/local_story_sentence_repository.dart';
import 'app/data/services/user_session_service.dart';
import 'app/data/repositories/local_adapters.dart';

final GetIt di = GetIt.instance;
bool _isFirebaseInitialized = false;

class DiConfig {
  static Future<void> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    di.registerSingleton<SharedPreferences>(prefs);
    di.registerSingleton<FirebaseFirestore>(firestore);
    _isFirebaseInitialized = true;

    // Repositories via interfaces (Firebase implementations)
    di.registerLazySingleton<StorySentenceRepository>(
      () => FirebaseStorySentenceRepository(di<FirebaseFirestore>()),
    );
    di.registerLazySingleton<StoryRoomRepository>(
      () => FirebaseStoryRoomRepository(di<FirebaseFirestore>()),
    );

    // Services
    di.registerLazySingleton<UserSessionService>(
      () => LocalUserSessionService(di<SharedPreferences>()),
    );
  }

  static Future<void> initWithoutFirebase() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    di.registerSingleton<SharedPreferences>(prefs);

    // Register local repositories and expose via interface adapters
    final LocalStoryRoomRepository localRoom = LocalStoryRoomRepository(di<SharedPreferences>());
    final LocalStorySentenceRepository localSentence = LocalStorySentenceRepository(di<SharedPreferences>());
    // Register concrete types for direct lookup by UI fallback paths
    di.registerSingleton<LocalStoryRoomRepository>(localRoom);
    di.registerSingleton<LocalStorySentenceRepository>(localSentence);
    di.registerLazySingleton<StoryRoomRepository>(() => LocalStoryRoomRepositoryAdapter(localRoom));
    di.registerLazySingleton<StorySentenceRepository>(() => LocalStorySentenceRepositoryAdapter(localSentence));

    // Services
    di.registerLazySingleton<UserSessionService>(
      () => LocalUserSessionService(di<SharedPreferences>()),
    );
  }

  static bool get isFirebaseInitialized => _isFirebaseInitialized;
}
