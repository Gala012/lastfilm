import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../lang/lang.dart';
import '../../theme/app_theme.dart';
import 'terms_logic.dart';

class TermsView extends GetView<TermsLogic> {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () => Get.back()),
        title: Text(Lang.terms, style: TextStyle(fontSize: ScreenUtil().setSp(18), fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScreenUtil().setWidth(16)),
        child: Text(
          _content,
          style: TextStyle(fontSize: ScreenUtil().setSp(14), color: theme.colorScheme.onSurface, height: 1.6),
        ),
      ),
    );
  }

  static const String _content = '''
Last Film Terms of Service

Last Updated: 2025

1. Acceptance of Terms

By downloading, installing, or using the Last Film application ("the app"), you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app.

2. Description of Service

Last Film is a film simulation camera application that allows you to capture photos with various film-style effects. The app operates entirely on your device and does not require an internet connection for its core functionality.

3. Use of the App

You agree to use the app only for lawful purposes. You may not:
- Use the app to create, store, or distribute illegal content
- Reverse engineer, decompile, or disassemble the app
- Remove or alter any proprietary notices on the app
- Use the app in any way that could harm, disable, or overburden the app or any network

4. Intellectual Property

All content, features, and functionality of the app, including but not limited to text, graphics, logos, and software, are the property of YooDoo Inc. and are protected by copyright and other intellectual property laws.

5. Disclaimer of Warranties

The app is provided "as is" without warranty of any kind. We do not warrant that the app will be uninterrupted, error-free, or free of harmful components. Your use of the app is at your sole risk.

6. Limitation of Liability

To the maximum extent permitted by law, YooDoo Inc. shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the app.

7. Data and Privacy

The app stores all data locally on your device. Please refer to our Privacy Policy for detailed information about data handling.

8. Modifications

We reserve the right to modify these Terms of Service at any time. Continued use of the app after such modifications constitutes acceptance of the updated terms.

9. Termination

We may terminate or suspend your access to the app at any time, without prior notice, for any reason.

10. Contact

For questions regarding these Terms of Service, please contact us through the app settings.
''';
}
