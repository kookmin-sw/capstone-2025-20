import 'package:flutter/material.dart';

class FeatureSearchScreen extends StatelessWidget {
  const FeatureSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('특징으로 검색')),
      body: Center(child: Text('Feature Search Screen')),
    );
  }
}