import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../lang/lang.dart';
import '../../theme/app_theme.dart';
import 'settings_logic.dart';

class SettingsView extends GetView<SettingsLogic> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () => Get.back()),
        title: Text(Lang.settings, style: TextStyle(fontSize: ScreenUtil().setSp(18), fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        child: Column(
          children: [
            _buildAchievement(context),
            SizedBox(height: ScreenUtil().setHeight(24)),
            _buildMergedSection(context),
            SizedBox(height: ScreenUtil().setHeight(32)),
            Text(Lang.copyright, style: TextStyle(fontSize: ScreenUtil().setSp(12), color: theme.colorScheme.onSurface.withOpacity(0.6))),
            SizedBox(height: ScreenUtil().setHeight(8)),
            Text('${Lang.version} ${controller.version}', style: TextStyle(fontSize: ScreenUtil().setSp(12), color: theme.colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievement(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() => Container(
          padding: EdgeInsets.all(ScreenUtil().setWidth(24)),
          decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(ScreenUtil().radius(16)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_camera, color: AppTheme.primary, size: ScreenUtil().setSp(32)),
              SizedBox(width: ScreenUtil().setWidth(12)),
              Text('${controller.photoCount.value}', style: TextStyle(fontSize: ScreenUtil().setSp(36), fontWeight: FontWeight.bold, color: AppTheme.primary)),
              SizedBox(width: ScreenUtil().setWidth(8)),
              Text(Lang.shotCount, style: TextStyle(fontSize: ScreenUtil().setSp(14), color: theme.colorScheme.onSurface.withOpacity(0.6))),
            ],
          ),
        ));
  }

  Widget _buildMergedSection(BuildContext context) {
    return _buildSection(context, Lang.settings, [
      _buildSwitchItem(context, Lang.grid, controller.gridOn, controller.toggleGrid),
      _buildSwitchItem(context, Lang.darkMode, controller.themeController.darkMode, controller.themeController.toggleDarkMode),
      _buildTile(context, Lang.privacy, controller.toPrivacyPolicy),
      _buildTile(context, Lang.terms, controller.toTerms),
    ]);
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: ScreenUtil().setSp(12), color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w500)),
        SizedBox(height: ScreenUtil().setHeight(8)),
        Container(
          decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(ScreenUtil().radius(12)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchItem(BuildContext context, String title, RxBool value, VoidCallback onToggle) {
    final theme = Theme.of(context);
    return Obx(() => SwitchListTile(
          title: Text(title, style: TextStyle(fontSize: ScreenUtil().setSp(16), color: theme.colorScheme.onSurface)),
          value: value.value,
          onChanged: (_) => onToggle(),
          activeColor: AppTheme.primary,
        ));
  }

  Widget _buildTile(BuildContext context, String title, VoidCallback onTap) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: ScreenUtil().setSp(16), color: theme.colorScheme.onSurface)),
      trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.6), size: ScreenUtil().setSp(20)),
      onTap: onTap,
    );
  }
}
