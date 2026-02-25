import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../lang/lang.dart';
import '../../theme/app_theme.dart';
import '../../utils/color_matrix.dart';
import '../../utils/logger.dart';
import 'home_logic.dart';
import 'widgets/film_drawer.dart';

class HomeView extends GetView<HomeLogic> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildCameraArea(context),
        _buildOverlay(context),
        _buildBottomBar(context),
        _buildDrawer(context),
      ],
    );
  }

  Widget _buildCameraArea(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColors = isDark ? AppTheme.cameraPageGradientDark : AppTheme.cameraPageGradientLight;
    final media = MediaQuery.of(context).size;
    return Obx(() {
      final err = controller.cameraError.value;
      if (err != null) {
        final errColor = isDark ? Colors.white70 : AppTheme.textSecondary;
        return Container(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: bgColors)),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(err, style: TextStyle(color: errColor, fontSize: ScreenUtil().setSp(14)), textAlign: TextAlign.center),
                  SizedBox(height: ScreenUtil().setHeight(16)),
                  TextButton(
                    onPressed: () => controller.openAppSettings(),
                    child: Text(Lang.openSettings, style: TextStyle(color: AppTheme.primary)),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(8)),
                  TextButton(
                    onPressed: () => controller.retryCamera(),
                    child: Text(Lang.confirm, style: TextStyle(color: errColor)),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      if (!controller.cameraReady.value || controller.cameraController == null) {
        return Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: bgColors)), child: Center(child: CircularProgressIndicator(color: AppTheme.primary)));
      }
      final cam = controller.cameraController!;
      final r = cam.value.aspectRatio;
      final portrait = media.height > media.width;
      final aspectRatio = (r > 1 && portrait) || (r < 1 && !portrait) ? 1 / r : r;
      final film = controller.currentFilm.value;
      final p = film.filterParams;
      final colorMatrix = buildFilmColorMatrix(p.brightness, p.contrast, p.saturation, p.hue);
      Logger.d('Camera preview: film=${film.name}, matrix=${colorMatrix.take(5).join(', ')}...');
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: bgColors)),
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: 1000,
            height: 1000 / aspectRatio,
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix(colorMatrix),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(cam),
                    if (controller.showGrid.value) _buildGrid(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildGrid() {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GridPainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textPrimary;
    final shadowColor = isDark ? Colors.black54 : Colors.white54;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        child: Row(
          children: [
            Expanded(
              child: Obx(() => Text(
                    controller.currentFilm.value.name,
                    style: TextStyle(color: textColor, fontSize: ScreenUtil().setSp(14), shadows: [Shadow(color: shadowColor, blurRadius: 4)]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barEnd = isDark ? const Color(0xE61A1A1F) : const Color(0xE6F2F5ED);
    final barIconColor = isDark ? Colors.white : AppTheme.textPrimary;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(16), vertical: ScreenUtil().setHeight(20)),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, barEnd])),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFlashBtn(barIconColor),
                  _buildIconBtn(Icons.flip_camera_ios_outlined, Icons.flip_camera_ios, controller.switchCamera, controller.isFrontCamera, barIconColor),
                  _buildTimerBtn(barIconColor),
                  _buildIconBtn(Icons.grid_off, Icons.grid_on, controller.toggleGrid, controller.showGrid, barIconColor),
                  _buildSimpleIconBtn(Icons.settings_outlined, controller.toSettings, barIconColor),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFilmButton(),
                  SizedBox(width: ScreenUtil().setWidth(25)),
                  _buildShutterButton(),
                  SizedBox(width: ScreenUtil().setWidth(25)),
                  _buildAlbumButton(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilmButton() {
    return Obx(() {
      final film = controller.currentFilm.value;
      return GestureDetector(
        onTap: controller.toggleDrawer,
        child: Container(
          width: ScreenUtil().setWidth(64),
          height: ScreenUtil().setWidth(64),
          decoration: BoxDecoration(
            color: film.iconColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(ScreenUtil().radius(12)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(film.name.split(' ').first, style: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(10), fontWeight: FontWeight.w600)),
              Text('ISO ${film.name.split(' ').last}', style: TextStyle(color: Colors.white70, fontSize: ScreenUtil().setSp(9))),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFlashBtn(Color barIconColor) {
    return Obx(() {
      final disabled = controller.isFrontCamera.value;
      return GestureDetector(
        onTap: disabled ? null : controller.toggleFlash,
        child: Icon(
          controller.flashOn.value ? Icons.flash_on : Icons.flash_on_outlined,
          color: disabled ? barIconColor.withOpacity(0.5) : barIconColor,
          size: ScreenUtil().setSp(24),
        ),
      );
    });
  }

  Widget _buildTimerBtn(Color barIconColor) {
    return Obx(() => GestureDetector(
          onTap: controller.showTimerPicker,
          child: Icon(
            Icons.timer_outlined,
            color: controller.timerSeconds.value > 0 ? Colors.amber : barIconColor,
            size: ScreenUtil().setSp(24),
          ),
        ));
  }

  Widget _buildIconBtn(IconData icon, IconData activeIcon, VoidCallback onTap, RxBool isActive, Color barIconColor) {
    return Obx(() => GestureDetector(
          onTap: onTap,
          child: Icon(isActive.value ? activeIcon : icon, color: barIconColor, size: ScreenUtil().setSp(24)),
        ));
  }

  Widget _buildSimpleIconBtn(IconData icon, VoidCallback onTap, Color barIconColor) {
    return GestureDetector(onTap: onTap, child: Icon(icon, color: barIconColor, size: ScreenUtil().setSp(24)));
  }

  Widget _buildShutterButton() {
    return Obx(() => GestureDetector(
          onTap: controller.isProcessing.value ? null : controller.takePhoto,
          child: Container(
            width: ScreenUtil().setWidth(80),
            height: ScreenUtil().setWidth(80),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: controller.isProcessing.value ? Colors.grey : AppTheme.primary,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)],
            ),
            child: controller.isProcessing.value ? Padding(padding: EdgeInsets.all(ScreenUtil().setWidth(24)), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : null,
          ),
        ));
  }

  Widget _buildAlbumButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Get.toNamed('/last_album'),
      child: Container(
        width: ScreenUtil().setWidth(64),
        height: ScreenUtil().setWidth(64),
        decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(ScreenUtil().radius(8)), border: Border.all(color: isDark ? Colors.white54 : Colors.black26)),
        child: Icon(Icons.photo_library_outlined, color: isDark ? Colors.white : AppTheme.textPrimary, size: ScreenUtil().setSp(28)),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Obx(() {
      final open = controller.drawerOpen.value;
      return Stack(
        children: [
          if (open)
            Positioned.fill(
              child: GestureDetector(
                onTap: controller.closeDrawer,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.black26),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            left: open ? 0 : -ScreenUtil().screenWidth,
            top: 0,
            bottom: 0,
            width: ScreenUtil().setWidth(300),
            child: FilmDrawer(
              statusBarHeight: MediaQuery.of(context).padding.top,
              onClose: controller.closeDrawer,
              onSelectFilm: controller.selectFilm,
              onSelectRoll: controller.selectRoll,
              currentFilm: controller.currentFilm.value,
              currentRoll: controller.currentRoll.value,
            ),
          ),
        ],
      );
    });
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.4)..strokeWidth = 1;
    final w = size.width / 3;
    final h = size.height / 3;
    for (int i = 1; i < 3; i++) {
      canvas.drawLine(Offset(w * i, 0), Offset(w * i, size.height), paint);
      canvas.drawLine(Offset(0, h * i), Offset(size.width, h * i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
