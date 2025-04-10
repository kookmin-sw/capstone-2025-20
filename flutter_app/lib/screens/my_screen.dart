import 'package:flutter/material.dart';
import '../model/pill.dart';
import '../model/my_pills.dart';
import '../services/pill_info_api_service.dart';
import '../utils/pill_storage.dart';

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  List<Pill> pills = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadMyPills();
  }

  Future<void> loadMyPills() async {
    await Future.delayed(const Duration(seconds: 1)); // 로딩 효과용

    final codes = await PillStorage.load();
    final futures = codes.map(PillInfoApiService.fetchPillByCode);
    final results = await Future.wait(futures);

    setState(() {
      pills = results.whereType<Pill>().toList(); // null 제거
      isLoading = false;
    });
  }

  Future<void> removePill(int itemSeq) async {
    final codes = await PillStorage.load();
    codes.remove(itemSeq);
    await PillStorage.save(codes);
    await loadMyPills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('나의 복용약')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 16),
          buildStatusBox(isSafe: true),
          const SizedBox(height: 8),
          const Text(
            '해당 제품들은 함께 복용해도 안전합니다.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: pills.length,
              itemBuilder: (context, index) {
                final pill = pills[index];
                return buildPillCard(pill);
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[300],
              foregroundColor: Colors.black,
            ),
            child: const Text('돌아가기'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget buildStatusBox({required bool isSafe}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: isSafe ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isSafe ? '안전' : '위험',
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildPillCard(Pill pill) {
    bool isExpanded = false;

    return StatefulBuilder(
      builder: (context, setInnerState) {
        return GestureDetector(
          onTap: () => setInnerState(() => isExpanded = !isExpanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft, // 왼쪽 기준으로 자르기
                        widthFactor: 0.5,                // 가로 절반만 보이게
                        child: Image.network(
                          pill.itemImage,
                          width: 160, // 원래 너비 기준
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.medication),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        pill.itemName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.grey[800]),
                      onPressed: () => removePill(pill.itemSeq),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('효능: ${pill.efcyQesitm}'),
                        Text('사용법: ${pill.useMethodQesitm}'),
                        Text('주의사항: ${pill.atpnQesitm}'),
                        Text('상호작용: ${pill.intrcQesitm}'),
                        Text('부작용: ${pill.seQesitm}'),
                      ],
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 100),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}