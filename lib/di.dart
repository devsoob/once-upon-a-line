import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/write/data/local_line_repository.dart';

final GetIt di = GetIt.instance;

class DiConfig {
  static Future<void> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    di.registerSingleton<SharedPreferences>(prefs);
    di.registerLazySingleton<LocalLineRepository>(
      () => LocalLineRepository(di<SharedPreferences>()),
    );
  }
}
