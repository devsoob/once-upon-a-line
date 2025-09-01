import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/work/data/local_line_repository.dart';
import 'app/data/works_repository.dart';
import 'app/data/sentences_repository.dart';

final GetIt di = GetIt.instance;

class DiConfig {
  static Future<void> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    di.registerSingleton<SharedPreferences>(prefs);
    di.registerLazySingleton<LocalLineRepository>(
      () => LocalLineRepository(di<SharedPreferences>()),
    );
    di.registerLazySingleton<WorksRepository>(() => LocalWorksRepository(di<SharedPreferences>()));
    di.registerLazySingleton<SentencesRepository>(
      () => LocalSentencesRepository(di<SharedPreferences>()),
    );
  }
}
