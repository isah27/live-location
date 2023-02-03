import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:location_tracker/classes/db_conn.dart';
import 'package:location_tracker/model/user.dart';
import 'package:location_tracker/pages/home_page.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:sizer/sizer.dart';

import 'classes/user_name_loc_db.dart';

User user = User();
Future<User> fetchUserInfo() async {
  DataBaseHelper? _baseHelpe = DataBaseHelper.instance;
  return await _baseHelpe.fetchUser();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  user = await fetchUserInfo();
  await Firebase.initializeApp();
  DatabaseConnection connection = DatabaseConnection();
  const androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "Location Tracker",
    notificationText: "Live location",
    notificationImportance: AndroidNotificationImportance.Max,
    // notificationIcon: AndroidResource(
    //     name: 'background_icon',
    //     defType: 'drawable'), // Default is ic_launcher from folder mipmap
  );
  connection.requestPermission();
  await FlutterBackground.initialize(androidConfig: androidConfig);
  await FlutterBackground.hasPermissions;
  await FlutterBackground.enableBackgroundExecution();
  // runApp(DevicePreview(
  //   enabled: true,
  //   builder: (context) => MyApp(),
  // ));
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        title: 'Location tracker',
        debugShowCheckedModeBanner: false,
        useInheritedMediaQuery: true,
        builder: DevicePreview.appBuilder,
        locale: DevicePreview.locale(context),
        color: Colors.amber,
        home: MainPage(user: user),
      );
    });
  }
}
