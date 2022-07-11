import 'package:flutter/material.dart';
import 'package:webrtcmeet/screen/home_screen.dart';


void main() {
  runApp(MyApp());
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
