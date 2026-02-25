import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../lang/lang.dart';
import 'photo_detail_logic.dart';

class PhotoDetailView extends GetView<PhotoDetailLogic> {
  const PhotoDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () => Get.back()),
        title: Text(Lang.editPhoto, style: TextStyle(fontSize: ScreenUtil().setSp(18), fontWeight: FontWeight.w600)),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz, color: Colors.white),
            color: theme.colorScheme.surface,
            onSelected: (v) {
              if (v == Lang.crop) {
                controller.cropPhoto();
              } else if (v == Lang.delete) {
                _showDeleteConfirm(context);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: Lang.crop, child: Text(Lang.crop)),
              PopupMenuItem(value: Lang.delete, child: Text(Lang.delete, style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
        elevation: 0,
      ),
      body: Obx(() {
        final path = controller.filePath.value;
        if (path == null || !File(path).existsSync()) {
          return Center(child: Text(Lang.noPhotos, style: TextStyle(color: Colors.white70)));
        }
        return Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: Image.file(File(path), fit: BoxFit.contain),
          ),
        );
      }),
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text(Lang.delete),
        content: Text(Lang.deletePhotoConfirm),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(Lang.cancel)),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deletePhoto();
            },
            child: Text(Lang.delete, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

}
