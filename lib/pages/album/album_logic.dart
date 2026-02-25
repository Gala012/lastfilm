import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../db_last_film/db_last_film_entity.dart';
import '../../db_last_film/db_last_film_helper.dart';
import '../../lang/lang.dart';
import '../../utils/logger.dart';

class AlbumLogic extends GetxController {
  final DbLastFilmHelper _db = DbLastFilmHelper();
  final photos = <PhotoEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPhotos();
  }

  Future<void> loadPhotos() async {
    await _db.ensureDefaultRolls();
    photos.value = await _db.getAllPhotos();
  }

  String? photoPath(int index) {
    if (index >= photos.length) return null;
    final path = photos[index].filePath;
    return File(path).existsSync() ? path : null;
  }

  void toPhotoDetail(int index) async {
    if (index >= photos.length) return;
    final photo = photos[index];
    final roll = await _db.getRollById(photo.rollId);
    Get.toNamed('/last_photo_detail', arguments: {'photo': photo, 'roll': roll})?.then((_) => loadPhotos());
  }

  void showDeleteConfirm(int index) {
    if (index >= photos.length) return;
    final photo = photos[index];
    Get.dialog(
      AlertDialog(
          title: Text(Lang.delete),
          content: Text(Lang.deletePhotoConfirm),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text(Lang.cancel)),
            TextButton(
              onPressed: () {
                Get.back();
                _deletePhoto(photo);
              },
              child: Text(Lang.delete, style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
    );
  }

  Future<void> _deletePhoto(PhotoEntity photo) async {
    if (photo.id == null) return;
    try {
      final path = photo.filePath;
      final roll = await _db.getRollById(photo.rollId);
      if (roll != null && roll.coverPath == path) {
        final others = await _db.getPhotosByRollId(photo.rollId);
        final newCover = others.where((p) => p.id != photo.id).map((p) => p.filePath).firstOrNull;
        final updated = RollEntity(id: roll.id, name: roll.name, filmId: roll.filmId, coverPath: newCover, createdAt: roll.createdAt, category: roll.category);
        await _db.updateRoll(updated);
      }
      await _db.deletePhoto(photo.id!);
      if (File(path).existsSync()) File(path).deleteSync();
      await loadPhotos();
      Get.snackbar('', Lang.deleteSuccess);
    } catch (e) {
      Logger.e('Delete photo error', e);
      Get.snackbar('', '${Lang.delete} ${Lang.operationFailed}');
    }
  }
}
