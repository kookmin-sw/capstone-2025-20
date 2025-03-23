import 'package:flutter/material.dart';
import 'package:flutter_app/screens/home_screen.dart';
import 'package:flutter_app/screens/guide_screen.dart';
import 'package:flutter_app/screens/camera_search_screen.dart';
import 'package:flutter_app/screens/feature_search_screen.dart';
import 'package:flutter_app/screens/name_search_screen.dart';
import 'package:flutter_app/screens/my_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeScreen(),
        '/guide': (context) => GuideScreen(),
        '/camera': (context) => CameraSearchScreen(),
        '/feature': (context) => FeatureSearchScreen(),
        '/name': (context) => NameSearchScreen(),
        '/my': (context) => MyScreen(),
      },
    );
  }
}