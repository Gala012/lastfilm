import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../pages/main/main_binding.dart';
import '../pages/main/main_view.dart';
import '../pages/home/home_binding.dart';
import '../pages/home/home_view.dart';
import '../pages/album/album_binding.dart';
import '../pages/album/album_view.dart';
import '../pages/settings/settings_binding.dart';
import '../pages/settings/settings_view.dart';
import '../pages/roll_detail/roll_detail_binding.dart';
import '../pages/roll_detail/roll_detail_view.dart';
import '../pages/create_roll/create_roll_binding.dart';
import '../pages/create_roll/create_roll_view.dart';
import '../pages/photo_detail/photo_detail_binding.dart';
import '../pages/photo_detail/photo_detail_view.dart';
import '../pages/privacy_policy/privacy_policy_binding.dart';
import '../pages/privacy_policy/privacy_policy_view.dart';
import '../pages/terms/terms_binding.dart';
import '../pages/terms/terms_view.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final themeCtrl = Get.find<ThemeController>();
        return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Last Film',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeCtrl.darkMode.value ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/last_main',
          getPages: Film,
        ));
      },
    );
  }
}
List<GetPage<dynamic>> Film = [
  GetPage(name: '/last_main', page: () => const MainView(), binding: MainBinding()),
  GetPage(name: '/last_home', page: () => const HomeView(), binding: HomeBinding()),
  GetPage(name: '/last_album', page: () => const AlbumView(), binding: AlbumBinding()),
  GetPage(name: '/last_settings', page: () => const SettingsView(), binding: SettingsBinding()),
  GetPage(name: '/last_roll_detail', page: () => const RollDetailView(), binding: RollDetailBinding()),
  GetPage(name: '/last_create_roll', page: () => const CreateRollView(), binding: CreateRollBinding()),
  GetPage(name: '/last_photo_detail', page: () => const PhotoDetailView(), binding: PhotoDetailBinding()),
  GetPage(name: '/last_privacy_policy', page: () => const PrivacyPolicyView(), binding: PrivacyPolicyBinding()),
  GetPage(name: '/last_terms', page: () => const TermsView(), binding: TermsBinding()),
];