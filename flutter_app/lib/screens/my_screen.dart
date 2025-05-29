import 'package:flutter/material.dart';
import '../model/pill.dart';
import '../model/interaction_result.dart';
import '../services/pill_info_api_service.dart';
import '../utils/pill_storage.dart';
import 'package:flutter/cupertino.dart';

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
    final futures = codes.map((code) => PillInfoApiService.fetchPillByCode(code));
    final results = await Future.wait(futures);
    final validPills = results.whereType<Pill>().toList();

    InteractionResult? interaction;
    if (validPills.length > 1) {
      interaction = await PillInfoApiService.checkInteractions(
        validPills.map((e) => e.itemSeq).toList(),
      );
    }

    setState(() {
      pills = validPills;
      interactionResult = interaction;
      isLoading = false;
    });
  }

  Future<void> removePill(String itemSeq) async {
    final codes = await PillStorage.load();
    codes.removeWhere((code) => code.toString() == itemSeq);
    await PillStorage.save(codes);

    setState(() {
      pills.removeWhere((pill) => pill.itemSeq == itemSeq);
    });

    final stillValid = pills.length > 1;

    if (!stillValid) {
      setState(() => interactionResult = null);
      return;
    }

    if (interactionResult?.isSafe == false) {
      final conflicts = interactionResult!.conflicts;

      final isConflictDrugDeleted = conflicts.any((conflict) =>
      conflict.drugA == itemSeq || conflict.drugB == itemSeq
      );

      if (isConflictDrugDeleted) {
        final newInteraction = await PillInfoApiService.checkInteractions(
          pills.map((e) => e.itemSeq).toList(),
        );
        setState(() => interactionResult = newInteraction);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('나의 복용약')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pills.isEmpty
          ? const Center(
        child: Text(
          '복용약을 추가해주세요',
          style: TextStyle(fontSize: 16),
        ),
      )
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
                  final pillMap = {
                    for (var pill in pills) pill.itemSeq.toString(): pill.itemName
                  };

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: interactionResult!.conflicts.map((conflict) {
                      final drugAName = pillMap[conflict.drugA] ?? conflict.drugA;
                      final drugBName = pillMap[conflict.drugB] ?? conflict.drugB;

                      return Text(
                        '$drugAName와(과)\n'
                            '$drugBName은(는)\n'
                            '함께 복용할 수 없습니다.\n'
                            '이유: ${conflict.reason}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
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
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            child: Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF22CE7D),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(180, 48),
                ),
                label: const Text('전체 삭제'),
                onPressed: () async {
                  final confirm = await showCupertinoDialog<bool>(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('전체 삭제'),
                      content: const Text('복용약을 모두 삭제하시겠습니까?'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text(
                            '취소',
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () =>
                              Navigator.of(context).pop(false),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          child: const Text('삭제'),
                          onPressed: () =>
                              Navigator.of(context).pop(true),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await PillStorage.save([]);
                    await loadMyPills();
                    showCupertinoDialog(
                      context: context,
                      builder: (context) => CupertinoAlertDialog(
                        title: const Text('삭제 완료'),
                        content: const Text('완쾌를 축하드립니다.'),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text(
                              '확인',
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () =>
                                Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      )
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
                        _buildInfoRow('제형', pill.chart),
                        _buildInfoRow('효능', pill.eeDocData),
                        _buildInfoRow('사용법', pill.udDocData),
                        _buildInfoRow('성분', pill.materialName),
                        _buildInfoRow('유통기한', pill.validTerm),
                        _buildInfoRow('주의사항', pill.nbDocData),
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