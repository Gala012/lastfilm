import 'package:get/get.dart';

import 'film_library_logic.dart';

class FilmLibraryBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      FilmLibraryLogic(),
      permanent: true,
    );
  }
}
