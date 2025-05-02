import 'package:flutter/material.dart';
import '../utils/pill_storage.dart';
import 'home_screen.dart'; // 홈 화면 import

class DummyResultScreen extends StatelessWidget {
  const DummyResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyPill = {
      'itemName': '뮤카란캡슐200밀리그램(아세틸시스테인)',
      'entpName': '대웅바이오(주)',
      'itemImage': 'https://nedrug.mfds.go.kr/pbp/cmn/itemImageDownload/1NaZ0VkgbDq',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('검색 결과'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
            );
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: ListTile(
              leading: Image.network(
                dummyPill['itemImage']!,
                height: 48,
                width: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported),
              ),
              title: Text(dummyPill['itemName']!, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(dummyPill['entpName']!),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await PillStorage.addPill(int.parse('202003464'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('복용약에 추가되었습니다')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}