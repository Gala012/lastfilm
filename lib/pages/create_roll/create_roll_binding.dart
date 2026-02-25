import 'package:get/get.dart';
import 'create_roll_logic.dart';

class CreateRollBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateRollLogic>(() => CreateRollLogic());
  }
}
