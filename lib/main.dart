import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webrtcmeet/screen/home_screen.dart';
import 'dart:core';

import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride, kIsWeb;
import 'package:flutter_background/flutter_background.dart';

void main() async{

  //await startForegroundTask();
  WidgetsFlutterBinding.ensureInitialized();
  if(!kIsWeb)
  {
    startForegroundService();
  }

  runApp(MyApp());
}

Future<bool> startForegroundService() async {
  const androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: 'Title of the notification',
    notificationText: 'Text of the notification',
    notificationImportance: AndroidNotificationImportance.Default,
    notificationIcon: AndroidResource(
        name: 'background_icon',
        defType: 'drawable'),
  );
  await FlutterBackground.initialize(androidConfig: androidConfig);
  return FlutterBackground.enableBackgroundExecution();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meet X',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:HomeScreen(title: 'Home',),// MyHomePage(), //
//      initialRoute: '/',
//      routes: {
//        '/': (context) => HomeScreen(title: 'Home'),
//        '/meeting': (context) => MeetingScreen(),
//      },
    );
  }
}
