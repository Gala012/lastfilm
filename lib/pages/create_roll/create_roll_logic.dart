import 'dart:io';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../config/films.dart';
import '../../db_last_film/db_last_film_entity.dart';
import '../../db_last_film/db_last_film_helper.dart';
import '../../lang/lang.dart';
import '../../utils/logger.dart';

class CreateRollLogic extends GetxController {
  final DbLastFilmHelper _db = DbLastFilmHelper();
  final ImagePicker _picker = ImagePicker();

  final selectedPaths = <String>[].obs;
  final selectedFilm = filmConfigs.first.obs;
  final rollName = ''.obs;
  final isCreating = false.obs;

  void selectFilm(FilmConfig film) {
    selectedFilm.value = film;
  }

  Future<void> pickImages() async {
    try {
      final list = await _picker.pickMultiImage();
      if (list.isNotEmpty) {
        selectedPaths.addAll(list.map((e) => e.path));
      }
    } catch (e) {
      Logger.e('Pick images error', e);
      Get.snackbar('', Lang.pickImagesFailed);
    }
  }

  void removeImage(String path) {
    selectedPaths.remove(path);
  }

  Future<void> createRoll(String name) async {
    final n = name.trim().isEmpty ? Lang.newRollName : name.trim();
    if (selectedPaths.isEmpty) {
      return;
    }
    if (selectedPaths.isEmpty) {
      Get.snackbar('', Lang.pleaseSelectPhotos);
      return;
    }
    isCreating.value = true;
    try {
      final roll = RollEntity(
        name: n,
        filmId: selectedFilm.value.id,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        category: 0,
      );
      final rollId = await _db.insertRoll(roll);
      final dir = await getApplicationDocumentsDirectory();
      final photoDir = '${dir.path}/photos';
      await Directory(photoDir).create(recursive: true);
      String? coverPath;
      for (var i = 0; i < selectedPaths.length; i++) {
        final bytes = await File(selectedPaths[i]).readAsBytes();
        var image = img.decodeImage(bytes);
        if (image != null) {
          final p = selectedFilm.value.filterParams;
          image = img.adjustColor(image, brightness: p.brightness, contrast: p.contrast, saturation: p.saturation, hue: p.hue);
          final path = '$photoDir/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          await File(path).writeAsBytes(img.encodeJpg(image));
          await _db.insertPhoto(PhotoEntity(rollId: rollId, filePath: path, createdAt: DateTime.now().millisecondsSinceEpoch));
          if (coverPath == null) coverPath = path;
        }
      }
      if (coverPath != null) {
        final updated = RollEntity(id: rollId, name: roll.name, filmId: roll.filmId, coverPath: coverPath, createdAt: roll.createdAt, category: roll.category);
        await _db.updateRoll(updated);
      }
      Get.back();
      Get.snackbar('', Lang.createSuccess);
    } catch (e) {
      Logger.e('Create roll error', e);
      Get.snackbar('', Lang.createFailed);
    } finally {
      isCreating.value = false;
    }
  }
}
