import 'dart:io';
import 'package:get/get.dart';
import '../../db_last_film/db_last_film_entity.dart';
import '../../db_last_film/db_last_film_helper.dart';

class RollDetailLogic extends GetxController {
  final DbLastFilmHelper _db = DbLastFilmHelper();
  RollEntity? roll;
  final photos = <PhotoEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    roll = args?['roll'] as RollEntity?;
    if (roll != null) {
      loadPhotos();
    }
  }

  Future<void> loadPhotos() async {
    if (roll == null) return;
    photos.value = await _db.getPhotosByRollId(roll!.id!);
  }

  bool get hasPhotos => photos.isNotEmpty;

  String? photoPath(int index) {
    if (index >= photos.length) return null;
    final path = photos[index].filePath;
    return File(path).existsSync() ? path : null;
  }

  void toPhotoDetail(int index) {
    if (index >= photos.length) return;
    Get.toNamed('/last_photo_detail', arguments: {'photo': photos[index], 'roll': roll})?.then((_) => loadPhotos());
  }
}
