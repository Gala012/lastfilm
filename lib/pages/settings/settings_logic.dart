import 'package:get/get.dart';
import '../../db_last_film/db_last_film_helper.dart';
import '../../theme/theme_controller.dart';

class SettingsLogic extends GetxController {
  final DbLastFilmHelper _db = DbLastFilmHelper();

  final gridOn = true.obs;
  final photoCount = 0.obs;
  final version = '1.0.0';

  ThemeController get themeController => Get.find<ThemeController>();

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    gridOn.value = (await _db.getSetting('grid_on')) != '0';
    photoCount.value = await _db.getPhotoCount();
  }

  Future<void> toggleGrid() async {
    gridOn.value = !gridOn.value;
    await _db.setSetting('grid_on', gridOn.value ? '1' : '0');
  }

  void toPrivacyPolicy() {
    Get.toNamed('/last_privacy_policy');
  }

  void toTerms() {
    Get.toNamed('/last_terms');
  }
}
