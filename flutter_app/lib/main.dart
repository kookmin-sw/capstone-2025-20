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
      theme: ThemeData(
        primaryColor: Color(0xFFA5D6A7),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF22CE7D),
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF22CE7D),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF22CE7D),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xFF167A4A),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFA5D6A7), width: 2.0),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          labelStyle: TextStyle(color: Colors.grey),
        ),
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: Color(0xFF22CE7D),
        ),
      ),
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