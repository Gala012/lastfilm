import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../config/films.dart';
import '../../lang/lang.dart';
import '../../theme/app_theme.dart';
import 'create_roll_logic.dart';

class CreateRollView extends GetView<CreateRollLogic> {
  const CreateRollView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.close), onPressed: () => Get.back()),
        title: Text(Lang.createRoll, style: TextStyle(fontSize: ScreenUtil().setSp(18), fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSelectPhotos(),
            SizedBox(height: ScreenUtil().setHeight(24)),
            _buildSelectFilm(),
            SizedBox(height: ScreenUtil().setHeight(24)),
            _buildRollName(),
            SizedBox(height: ScreenUtil().setHeight(32)),
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectPhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Lang.selectPhotos, style: TextStyle(fontSize: ScreenUtil().setSp(16), fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        SizedBox(height: ScreenUtil().setHeight(12)),
        Obx(() {
          final paths = controller.selectedPaths;
          return Container(
            height: ScreenUtil().setHeight(120),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(ScreenUtil().radius(12)), border: Border.all(color: AppTheme.primary.withOpacity(0.3))),
            child: paths.isEmpty
                ? GestureDetector(
                    onTap: controller.pickImages,
                    child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_photo_alternate, size: ScreenUtil().setSp(40), color: AppTheme.primary), SizedBox(height: ScreenUtil().setHeight(8)), Text(Lang.selectPhotos, style: TextStyle(color: AppTheme.textSecondary))])),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(ScreenUtil().setWidth(8)),
                    itemCount: paths.length + 1,
                    itemBuilder: (context, index) {
                      if (index == paths.length) {
                        return GestureDetector(
                          onTap: controller.pickImages,
                          child: Container(
                            width: ScreenUtil().setWidth(80),
                            margin: EdgeInsets.only(right: ScreenUtil().setWidth(8)),
                            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(ScreenUtil().radius(8))),
                            child: Icon(Icons.add, color: AppTheme.primary, size: ScreenUtil().setSp(32)),
                          ),
                        );
                      }
                      final path = paths[index];
                      return Stack(
                        children: [
                          Container(
                            width: ScreenUtil().setWidth(80),
                            margin: EdgeInsets.only(right: ScreenUtil().setWidth(8)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(ScreenUtil().radius(8)),
                              child: File(path).existsSync() ? Image.file(File(path), fit: BoxFit.cover) : Container(color: AppTheme.surface),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: ScreenUtil().setWidth(12),
                            child: GestureDetector(
                              onTap: () => controller.removeImage(path),
                              child: Container(
                                padding: EdgeInsets.all(ScreenUtil().setWidth(4)),
                                decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: Icon(Icons.close, size: ScreenUtil().setSp(16), color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          );
        }),
      ],
    );
  }

  Widget _buildSelectFilm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Lang.selectFilm, style: TextStyle(fontSize: ScreenUtil().setSp(16), fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        SizedBox(height: ScreenUtil().setHeight(12)),
        Obx(() => Wrap(
              spacing: ScreenUtil().setWidth(8),
              runSpacing: ScreenUtil().setHeight(8),
              children: filmConfigs.map((f) {
                final isSelected = controller.selectedFilm.value.id == f.id;
                return GestureDetector(
                  onTap: () => controller.selectFilm(f),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(12), vertical: ScreenUtil().setHeight(8)),
                    decoration: BoxDecoration(
                      color: isSelected ? f.iconColor.withOpacity(0.2) : Colors.white,
                      borderRadius: BorderRadius.circular(ScreenUtil().radius(20)),
                      border: Border.all(color: isSelected ? f.iconColor : AppTheme.textSecondary.withOpacity(0.3)),
                    ),
                    child: Text(f.name, style: TextStyle(fontSize: ScreenUtil().setSp(14), color: isSelected ? f.iconColor : AppTheme.textPrimary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildRollName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Lang.rollName, style: TextStyle(fontSize: ScreenUtil().setSp(16), fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        SizedBox(height: ScreenUtil().setHeight(12)),
        TextField(
          onChanged: (v) => controller.rollName.value = v,
          decoration: InputDecoration(
            hintText: Lang.newRollName,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(ScreenUtil().radius(12)), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16), vertical: ScreenUtil().setHeight(14)),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return Obx(() => ElevatedButton(
          onPressed: controller.isCreating.value ? null : () => controller.createRoll(controller.rollName.value),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(16)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScreenUtil().radius(12))),
          ),
          child: controller.isCreating.value ? SizedBox(height: ScreenUtil().setHeight(24), width: ScreenUtil().setHeight(24), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(Lang.confirm),
        ));
  }
}
