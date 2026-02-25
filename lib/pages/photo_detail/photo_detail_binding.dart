import 'package:get/get.dart';
import 'photo_detail_logic.dart';

class PhotoDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhotoDetailLogic>(() => PhotoDetailLogic());
  }
}
