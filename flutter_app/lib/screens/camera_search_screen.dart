import 'package:flutter/material.dart';

class CameraSearchScreen extends StatelessWidget {
  const CameraSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('카메라로 검색')),
      body: Center(child: Text('Camera Search Screen')),
    );
  }
}