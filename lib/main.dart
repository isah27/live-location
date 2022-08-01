import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:location_tracker/pages/home_page.dart';
import 'package:flutter_background/flutter_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  const androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "Location Tracker",
    notificationText: "Live location",
    notificationImportance: AndroidNotificationImportance.Max,
    // notificationIcon: AndroidResource(
    //     name: 'background_icon',
    //     defType: 'drawable'), // Default is ic_launcher from folder mipmap
  );
  bool success =
      await FlutterBackground.initialize(androidConfig: androidConfig);
  bool hasPermissions = await FlutterBackground.hasPermissions;
  bool isenable = await FlutterBackground.enableBackgroundExecution();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Google Maps Demo',
      debugShowCheckedModeBanner: false,
      color: Colors.amber,
      home: MainPage(),
    );
  }
}
