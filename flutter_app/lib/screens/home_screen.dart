import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget buildButton({
    required BuildContext context,
    required String label,
    required String routeName,
    IconData? icon,
    Color backgroundColor = const Color(0xFFE0E0E0),
    Color textColor = Colors.black,
    bool isCameraButton = false,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
        height: isCameraButton ? 80 : 60,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isCameraButton
              ? [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Icon(icon, color: Colors.black),
              ),
            if (icon != null)
              const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: isCameraButton ? 20 : 18,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildButton(
                context: context,
                label: '안전을 위하여',
                routeName: '/guide',
                icon: Icons.info,
              ),
              buildButton(
                context: context,
                label: '카메라로 검색',
                routeName: '/camera',
                icon: Icons.camera_alt,
                backgroundColor: Colors.grey.shade700,
                textColor: Colors.white,
                isCameraButton: true,
              ),
              buildButton(
                context: context,
                label: '생김새로 검색',
                routeName: '/feature',
              ),
              buildButton(
                context: context,
                label: '제품명으로 검색',
                routeName: '/name',
              ),
              buildButton(
                context: context,
                label: '나의 복용약',
                routeName: '/my',
                backgroundColor: Colors.greenAccent.shade200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}