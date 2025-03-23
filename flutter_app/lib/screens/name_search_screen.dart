import 'package:flutter/material.dart';

class NameSearchScreen extends StatelessWidget {
  const NameSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('제품명으로 검색')),
      body: Center(child: Text('Name Search Screen')),
    );
  }
}