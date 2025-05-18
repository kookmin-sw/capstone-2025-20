import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dummy_result_screen.dart'; // 더미 결과

class CameraSearchScreen extends StatelessWidget {
  const CameraSearchScreen({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DummyResultScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 촬영이 취소되었습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('카메라로 검색')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 100, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('촬영 가이드', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('• 밝은 곳에서 촬영해주세요.'),
            const Text('• 카메라가 깨끗한지 확인해주세요.'),
            const Text('• 손이 흔들리지 않도록 해주세요.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _pickImage(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF22CE7D),
              ),
              child: const Text('촬영 시작'),
            ),
          ],
        ),
      ),
    );
  }
}