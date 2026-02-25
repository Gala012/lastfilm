import 'package:get/get.dart';
import 'roll_detail_logic.dart';

class RollDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RollDetailLogic>(() => RollDetailLogic());
  }
}
