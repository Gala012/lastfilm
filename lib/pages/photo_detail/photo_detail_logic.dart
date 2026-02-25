import 'dart:io';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import '../../db_last_film/db_last_film_entity.dart';
import '../../db_last_film/db_last_film_helper.dart';
import '../../lang/lang.dart';
import '../../utils/logger.dart';

class PhotoDetailLogic extends GetxController {
  final DbLastFilmHelper _db = DbLastFilmHelper();

  PhotoEntity? photo;
  RollEntity? roll;
  final filePath = Rxn<String>();
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    photo = args?['photo'] as PhotoEntity?;
    roll = args?['roll'] as RollEntity?;
    if (photo != null) filePath.value = photo!.filePath;
  }

  Future<void> cropPhoto() async {
    final path = filePath.value;
    if (path == null || !File(path).existsSync()) return;
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      );
      if (cropped != null && cropped.path.isNotEmpty) {
        await _replaceWithNewFile(cropped.path);
      }
    } catch (e) {
      Logger.e('Crop error', e);
      Get.snackbar('', '${Lang.crop} ${Lang.operationFailed}');
    }
  }


  Future<void> _replaceWithNewFile(String newPath) async {
    if (photo == null) return;
    isSaving.value = true;
    try {
      final updated = PhotoEntity(id: photo!.id, rollId: photo!.rollId, filePath: newPath, createdAt: photo!.createdAt);
      await _db.updatePhoto(updated);
      filePath.value = newPath;
      photo = updated;
      if (roll != null) {
        final r = RollEntity(id: roll!.id, name: roll!.name, filmId: roll!.filmId, coverPath: newPath, createdAt: roll!.createdAt, category: roll!.category);
        await _db.updateRoll(r);
        roll = r;
      }
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deletePhoto() async {
    if (photo == null || photo!.id == null) return;
    try {
      final path = photo!.filePath;
      if (roll != null && roll!.coverPath == path) {
        final others = await _db.getPhotosByRollId(photo!.rollId);
        final newCover = others.where((p) => p.id != photo!.id).map((p) => p.filePath).firstOrNull;
        final updated = RollEntity(id: roll!.id, name: roll!.name, filmId: roll!.filmId, coverPath: newCover, createdAt: roll!.createdAt, category: roll!.category);
        await _db.updateRoll(updated);
      }
      await _db.deletePhoto(photo!.id!);
      if (File(path).existsSync()) File(path).deleteSync();
      Get.back();
      Get.snackbar('', Lang.deleteSuccess);
    } catch (e) {
      Logger.e('Delete photo error', e);
      Get.snackbar('', '${Lang.delete} ${Lang.operationFailed}');
    }
  }
}
