import 'package:get/get.dart';
import 'main_logic.dart';
import '../home/home_logic.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainLogic>(() => MainLogic());
    Get.lazyPut<HomeLogic>(() => HomeLogic());
  }
}
