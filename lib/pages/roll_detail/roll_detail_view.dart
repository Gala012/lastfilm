import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../lang/lang.dart';
import '../../theme/app_theme.dart';
import 'roll_detail_logic.dart';

class RollDetailView extends GetView<RollDetailLogic> {
  const RollDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () => Get.back()),
        title: Text(controller.roll?.name ?? Lang.rollName, style: TextStyle(fontSize: ScreenUtil().setSp(18), fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.roll == null) {
          return Center(child: Text(Lang.noRoll));
        }
        if (controller.photos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_outlined, size: ScreenUtil().setSp(64), color: theme.colorScheme.onSurface.withOpacity(0.6)),
                SizedBox(height: ScreenUtil().setHeight(16)),
                Text(Lang.noPhotos, style: TextStyle(fontSize: ScreenUtil().setSp(14), color: theme.colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          );
        }
        return GridView.builder(
          padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: ScreenUtil().setWidth(8),
            mainAxisSpacing: ScreenUtil().setWidth(8),
            childAspectRatio: 1,
          ),
          itemCount: controller.photos.length,
          itemBuilder: (context, index) {
            final path = controller.photoPath(index);
            return GestureDetector(
              onTap: () => controller.toPhotoDetail(index),
              child: path != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(ScreenUtil().radius(8)),
                      child: Image.file(File(path), fit: BoxFit.cover),
                    )
                  : Container(color: theme.colorScheme.surface, child: Icon(Icons.broken_image, color: theme.colorScheme.onSurface.withOpacity(0.6))),
            );
          },
        );
      }),
    );
  }
}
