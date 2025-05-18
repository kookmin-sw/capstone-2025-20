import 'package:flutter/material.dart';
import '../utils/pill_storage.dart';
import 'home_screen.dart';

class DummyResultScreen extends StatefulWidget {
  const DummyResultScreen({super.key});

  @override
  State<DummyResultScreen> createState() => _DummyResultScreenState();
}

class _DummyResultScreenState extends State<DummyResultScreen> {
  bool isLoading = true;

  final dummyPill = {
    'itemName': '뮤카란캡슐200밀리그램(아세틸시스테인)',
    'entpName': '대웅바이오(주)',
    'itemImage': 'https://nedrug.mfds.go.kr/pbp/cmn/itemImageDownload/1NaZ0VkgbDq',
  };

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            color: Color(0xFFF9FFFD),
            child: ListTile(
              leading: SizedBox(
                width: 100,
                child: Image.network(
                  dummyPill['itemImage']!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.medication, size: 40),
                ),
              ),
              title: Text(dummyPill['itemName']!,
                  maxLines: 2, overflow: TextOverflow.ellipsis),
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