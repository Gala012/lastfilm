import 'package:get/get.dart';
import '../db_last_film/db_last_film_helper.dart';

class ThemeController extends GetxController {
  final DbLastFilmHelper _db = DbLastFilmHelper();

  final darkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    darkMode.value = (await _db.getSetting('dark_mode')) == '1';
  }

  Future<void> toggleDarkMode() async {
    darkMode.value = !darkMode.value;
    await _db.setSetting('dark_mode', darkMode.value ? '1' : '0');
  }
}
