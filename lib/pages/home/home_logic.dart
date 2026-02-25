import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../../config/films.dart';
import '../../db_last_film/db_last_film_entity.dart';
import '../../db_last_film/db_last_film_helper.dart';
import '../../lang/lang.dart';
import '../../utils/logger.dart';

Uint8List _processImageInIsolate(List<int> bytes, double brightness, double contrast, double saturation, double hue) {
  final image = img.decodeImage(Uint8List.fromList(bytes));
  if (image == null) return Uint8List.fromList(bytes);
  final adjusted = img.adjustColor(image, brightness: brightness, contrast: contrast, saturation: saturation, hue: hue);
  return Uint8List.fromList(img.encodeJpg(adjusted));
}

class HomeLogic extends GetxController {
  final DbLastFilmHelper _db = DbLastFilmHelper();

  final drawerOpen = false.obs;
  final currentFilm = filmConfigs.first.obs;
  final currentRoll = Rxn<RollEntity>();
  final flashOn = false.obs;
  final timerSeconds = 0.obs;
  final showGrid = true.obs;
  final isFrontCamera = false.obs;
  final isProcessing = false.obs;

  CameraController? cameraController;
  List<CameraDescription> cameras = [];
  final flashMode = FlashMode.off.obs;
  final cameraReady = false.obs;
  final cameraError = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await _loadSettings();
    await _loadCurrentRoll();
    await _initCamera();
  }

  Future<void> _loadSettings() async {
    final filmId = await _db.getSetting('current_film_id');
    if (filmId != null) {
      final f = filmConfigs.where((x) => x.id == filmId).firstOrNull;
      if (f != null) currentFilm.value = f;
    }
    flashOn.value = (await _db.getSetting('flash_on')) == '1';
    showGrid.value = (await _db.getSetting('grid_on')) != '0';
    timerSeconds.value = int.tryParse(await _db.getSetting('timer_sec') ?? '0') ?? 0;
    flashMode.value = flashOn.value ? FlashMode.always : FlashMode.off;
  }

  Future<void> _loadCurrentRoll() async {
    await _db.ensureDefaultRolls();
    final rolls = await _db.getAllRolls();
    final rollIdStr = await _db.getSetting('current_roll_id');
    if (rollIdStr != null) {
      currentRoll.value = rolls.where((r) => r.id.toString() == rollIdStr).firstOrNull;
    }
    if (currentRoll.value == null && rolls.isNotEmpty) {
      currentRoll.value = rolls.first;
      await _db.setSetting('current_roll_id', rolls.first.id.toString());
    }
  }

  Future<void> _initCamera() async {
    try {
      cameraError.value = null;
      cameraReady.value = false;
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        cameraError.value = Lang.cameraNoDevice;
        cameraReady.value = false;
        Logger.e('Camera init: no cameras available');
        return;
      }
      final cam = isFrontCamera.value && cameras.length > 1 ? cameras[1] : cameras[0];
      cameraController = CameraController(cam, ResolutionPreset.high, enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
      await cameraController!.initialize();
      if (!isFrontCamera.value) {
        await cameraController!.setFlashMode(flashMode.value);
      }
      final initialized = cameraController!.value.isInitialized;
      cameraReady.value = initialized;
      Logger.d('Camera init: success, isInitialized=$initialized');
      if (!initialized) {
        cameraError.value = Lang.cameraInitFailed;
        Logger.e('Camera init: controller initialized but isInitialized=false');
      }
    } catch (e, st) {
      Logger.e('Camera init error', e, st);
      cameraError.value = Lang.cameraInitFailed;
      cameraReady.value = false;
      cameraController = null;
    }
  }

  Future<void> openAppSettings() async {
    await permission_handler.openAppSettings();
  }

  Future<void> retryCamera() async {
    await _initCamera();
  }

  void toggleDrawer() {
    drawerOpen.value = !drawerOpen.value;
  }

  void closeDrawer() {
    drawerOpen.value = false;
  }

  void selectFilm(FilmConfig film) {
    Logger.d('Select film: ${film.name}, brightness=${film.filterParams.brightness}, contrast=${film.filterParams.contrast}, saturation=${film.filterParams.saturation}, hue=${film.filterParams.hue}');
    currentFilm.value = film;
    _db.setSetting('current_film_id', film.id);
    closeDrawer();
  }

  void selectRoll(RollEntity roll) {
    currentRoll.value = roll;
    _db.setSetting('current_roll_id', roll.id.toString());
    closeDrawer();
  }

  void toggleFlash() {
    if (isFrontCamera.value) return;
    flashOn.value = !flashOn.value;
    flashMode.value = flashOn.value ? FlashMode.always : FlashMode.off;
    cameraController?.setFlashMode(flashMode.value);
    _db.setSetting('flash_on', flashOn.value ? '1' : '0');
  }

  void _turnOffFlashForFrontCamera() {
    flashOn.value = false;
    flashMode.value = FlashMode.off;
    _db.setSetting('flash_on', '0');
  }

  void toggleGrid() {
    showGrid.value = !showGrid.value;
    _db.setSetting('grid_on', showGrid.value ? '1' : '0');
  }

  void switchCamera() {
    if (cameras.length < 2) return;
    isFrontCamera.value = !isFrontCamera.value;
    if (isFrontCamera.value) _turnOffFlashForFrontCamera();
    _reinitCamera();
  }

  Future<void> _reinitCamera() async {
    cameraReady.value = false;
    await cameraController?.dispose();
    cameraController = null;
    await _initCamera();
  }

  Future<void> takePhoto() async {
    if (cameraController == null) {
      Logger.e('Take photo: cameraController is null');
      Get.snackbar('', Lang.cameraNotInitialized);
      return;
    }
    if (!cameraController!.value.isInitialized) {
      Logger.e('Take photo: camera not initialized, isInitialized=${cameraController!.value.isInitialized}');
      Get.snackbar('', Lang.cameraNotReady);
      return;
    }
    if (isProcessing.value) {
      Logger.d('Take photo: already processing');
      return;
    }
    final roll = currentRoll.value;
    if (roll == null) {
      Logger.e('Take photo: currentRoll is null');
      Get.snackbar('', Lang.noRollHint);
      return;
    }
    final rollId = roll.id;
    if (rollId == null) {
      Logger.e('Take photo: roll.id is null');
      Get.snackbar('', Lang.shotFailed);
      return;
    }
    isProcessing.value = true;
    Timer? safetyTimer;
    safetyTimer = Timer(Duration(seconds: 25), () {
      if (isProcessing.value) {
        isProcessing.value = false;
        Logger.e('Take photo safety timer: force stop spinner after 25s');
      }
    });
    try {
      Logger.d('Take photo: start, rollId=$rollId');
      await _takePhotoCore(rollId).timeout(
        Duration(seconds: 20),
        onTimeout: () {
          Logger.e('Take photo: timeout after 20s');
          throw TimeoutException('Photo capture timeout');
        },
      );
      Logger.d('Take photo: success');
      Get.snackbar('', Lang.shotSuccess);
    } on TimeoutException catch (e) {
      Logger.e('Take photo timeout: ${e.toString()}');
      Get.snackbar('', Lang.shotFailed);
    } catch (e, st) {
      Logger.e('Take photo error', e, st);
      Get.snackbar('', Lang.shotFailed);
    } finally {
      safetyTimer.cancel();
      isProcessing.value = false;
      Logger.d('Take photo: finished, isProcessing=false');
    }
  }

  Future<void> _takePhotoCore(int rollId) async {
    Logger.d('_takePhotoCore: start, rollId=$rollId, timer=${timerSeconds.value}s');
    if (timerSeconds.value > 0) {
      Logger.d('_takePhotoCore: waiting ${timerSeconds.value}s for timer');
      await Future.delayed(Duration(seconds: timerSeconds.value));
    }
    if (cameraController == null) {
      Logger.e('_takePhotoCore: cameraController is null');
      throw StateError('Camera controller is null');
    }
    if (!cameraController!.value.isInitialized) {
      Logger.e('_takePhotoCore: camera not initialized, isInitialized=${cameraController!.value.isInitialized}');
      throw StateError('Camera not initialized');
    }
    if (cameraController!.value.isTakingPicture) {
      Logger.e('_takePhotoCore: camera is already taking picture');
      throw StateError('Camera is already taking picture');
    }
    Logger.d('_takePhotoCore: camera state check passed, isInitialized=${cameraController!.value.isInitialized}, isTakingPicture=${cameraController!.value.isTakingPicture}');
    await Future.delayed(Duration(milliseconds: 150));
    XFile photoFile;
    try {
      Logger.d('_takePhotoCore: calling takePicture(), camera state: isInitialized=${cameraController!.value.isInitialized}, isTakingPicture=${cameraController!.value.isTakingPicture}');
      final startTime = DateTime.now();
      photoFile = await cameraController!.takePicture().timeout(
        Duration(seconds: 15),
        onTimeout: () {
          final elapsed = DateTime.now().difference(startTime);
          Logger.e('takePicture() timeout after ${elapsed.inSeconds}s');
          throw TimeoutException('takePicture timeout after ${elapsed.inSeconds}s');
        },
      );
      final elapsed = DateTime.now().difference(startTime);
      Logger.d('_takePhotoCore: takePicture() completed in ${elapsed.inMilliseconds}ms, path=${photoFile.path}');
    } catch (e, st) {
      Logger.e('takePicture failed', e, st);
      rethrow;
    }
    Uint8List bytes;
    try {
      Logger.d('_takePhotoCore: reading bytes from file');
      bytes = await photoFile.readAsBytes();
      Logger.d('_takePhotoCore: readAsBytes completed, length=${bytes.length}');
    } catch (e, st) {
      Logger.e('readAsBytes failed', e, st);
      rethrow;
    }
    if (bytes.isEmpty) {
      Logger.e('Take photo: bytes empty');
      throw StateError('Photo bytes empty');
    }
    Logger.d('Take photo: bytes length=${bytes.length}');
    final dir = await getApplicationDocumentsDirectory();
    final photoDir = '${dir.path}/photos';
    final path = '$photoDir/${DateTime.now().millisecondsSinceEpoch}.jpg';
    Logger.d('_takePhotoCore: photo path=$path');
    try {
      Logger.d('_takePhotoCore: creating directory');
      await Directory(photoDir).create(recursive: true);
      Logger.d('_takePhotoCore: directory created');
    } catch (e, st) {
      Logger.e('Create photo dir failed', e, st);
      rethrow;
    }
    Uint8List bytesToSave = bytes;
    final p = currentFilm.value.filterParams;
    try {
      Logger.d('_takePhotoCore: starting filter in isolate, brightness=${p.brightness}, contrast=${p.contrast}, saturation=${p.saturation}, hue=${p.hue}');
      final filtered = await Isolate.run(() => _processImageInIsolate(bytes, p.brightness, p.contrast, p.saturation, p.hue)).timeout(Duration(seconds: 10), onTimeout: () {
        Logger.e('Filter timeout after 10s');
        throw TimeoutException('Filter timeout');
      });
      Logger.d('_takePhotoCore: filter completed, filtered length=${filtered.length}');
      if (filtered.isNotEmpty) {
        bytesToSave = filtered;
      }
    } on TimeoutException catch (_) {
      Logger.e('Filter timeout, saving raw');
    } catch (e) {
      Logger.e('Filter error, saving raw', e);
    }
    try {
      Logger.d('_takePhotoCore: writing file, size=${bytesToSave.length}');
      await File(path).writeAsBytes(bytesToSave);
      Logger.d('_takePhotoCore: file written');
    } catch (e, st) {
      Logger.e('Write photo file failed', e, st);
      rethrow;
    }
    final photoEntity = PhotoEntity(rollId: rollId, filePath: path, createdAt: DateTime.now().millisecondsSinceEpoch);
    try {
      Logger.d('_takePhotoCore: inserting photo to DB');
      await _db.insertPhoto(photoEntity);
      Logger.d('_takePhotoCore: photo inserted to DB');
    } catch (e, st) {
      Logger.e('insertPhoto failed', e, st);
      try {
        await File(path).delete();
      } catch (_) {}
      rethrow;
    }
    try {
      Logger.d('_takePhotoCore: updating roll cover');
      final rolls = await _db.getAllRolls();
      final updatedRoll = rolls.where((r) => r.id == rollId).firstOrNull;
      if (updatedRoll != null) {
        final updated = RollEntity(id: updatedRoll.id, name: updatedRoll.name, filmId: updatedRoll.filmId, coverPath: path, createdAt: updatedRoll.createdAt, category: updatedRoll.category);
        await _db.updateRoll(updated);
        currentRoll.value = updated;
        Logger.d('_takePhotoCore: roll cover updated');
      }
    } catch (e) {
      Logger.e('Update roll cover failed', e);
    }
    Logger.d('_takePhotoCore: completed successfully');
  }

  void setTimer(int seconds) {
    timerSeconds.value = seconds;
    _db.setSetting('timer_sec', seconds.toString());
  }

  String _timerLabel(int s) {
    switch (s) {
      case 0: return Lang.timerOff;
      case 3: return Lang.timer3s;
      case 5: return Lang.timer5s;
      case 8: return Lang.timer8s;
      case 10: return Lang.timer10s;
      default: return Lang.timerOff;
    }
  }

  void showTimerPicker() {
    final options = [0, 3, 5, 8, 10];
    Get.bottomSheet(
      Container(
        color: Colors.grey[900],
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(Lang.selectTimer, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              ...options.map((s) => ListTile(
                title: Text(_timerLabel(s), style: const TextStyle(color: Colors.white)),
                onTap: () {
                  setTimer(s);
                  Get.back();
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  void toSettings() {
    Get.toNamed('/last_settings');
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
