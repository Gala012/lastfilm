import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main_logic.dart';
import '../home/home_view.dart';

class MainView extends GetView<MainLogic> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomeView(),
    );
  }
}
