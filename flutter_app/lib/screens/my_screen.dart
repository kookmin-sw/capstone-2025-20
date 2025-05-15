import 'package:flutter/material.dart';
import '../model/pill.dart';
import '../model/my_pills.dart';
import '../model/interaction_result.dart';
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
  InteractionResult? interactionResult;

  @override
  void initState() {
    super.initState();
    loadMyPills();
  }

  Future<void> loadMyPills() async {
    await Future.delayed(const Duration(seconds: 1));

    final codes = await PillStorage.load();
    final futures = codes.map(PillInfoApiService.fetchPillByCode);
    final results = await Future.wait(futures);
    final validPills = results.whereType<Pill>().toList();

    final interaction = await PillInfoApiService.checkInteractions(
      validPills.map((e) => e.itemSeq).toList(),
    );

    setState(() {
      pills = validPills;
      interactionResult = interaction;
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
          buildStatusBox(isSafe: interactionResult?.isSafe ?? true),
          const SizedBox(height: 8),
          Text(
            interactionResult?.isSafe ?? true
                ? '해당 제품들은 함께 복용해도 안전합니다.'
                : '일부 약물은 함께 복용하면 위험합니다.',
            style: const TextStyle(fontSize: 14),
          ),
          if (!(interactionResult?.isSafe ?? true))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Builder(
                builder: (context) {
                  // Map<itemSeq as String, itemName>
                  final pillMap = {
                    for (var pill in pills) pill.itemSeq.toString(): pill.itemName
                  };

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: interactionResult!.conflicts.map((conflict) {
                      final drugAName = pillMap[conflict.drugA] ?? conflict.drugA;
                      final drugBName = pillMap[conflict.drugB] ?? conflict.drugB;

                      return Text('$drugAName와(과) $drugBName은(는) 함께 복용할 수 없습니다.\n${conflict.reason}',
                        style: const TextStyle(fontWeight: FontWeight.bold,),
                      );
                    }).toList(),
                  );
                },
              ),
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
                    Image.network(
                      pill.itemImage,
                      width: 100,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.medication),
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
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('효능', pill.efcyQesitm),
                        _buildInfoRow('사용법', pill.useMethodQesitm),
                        _buildInfoRow('주의사항', pill.atpnQesitm),
                        _buildInfoRow('제형', pill.chart),
                        _buildInfoRow('성분', pill.materialName),
                        _buildInfoRow('유통기한', pill.validTerm),
                      ],
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 100),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}