import 'dart:async';

import 'package:esdcustomer/config/app_theme.dart';
import 'package:esdcustomer/firebase_options.dart';
import 'package:esdcustomer/module/view/splash_screen.dart';
import 'package:esdcustomer/services/push_notification_service.dart';
import 'package:esdcustomer/utils/app_binding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await GetStorage.init();

  // Firebase must be up before any messaging call, including the background
  // handler registered below.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  // Permission prompt + listeners. Deliberately not awaited: a slow or failed
  // push setup must never hold up the first frame.
  unawaited(PushNotificationService.instance.init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Electronics Sales Delhi',
      theme: AppTheme.instance.themeData(),
      debugShowCheckedModeBanner: false,
      initialBinding: AppBinding(),
      home: const SplashScreen(),
      defaultTransition: Transition.cupertino,
      builder: EasyLoading.init(),
    );
  }
}
