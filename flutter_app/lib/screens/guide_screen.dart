import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('안전을 위하여')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            const Text(
              '🛡️ 안전을 위하여',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '‘뭐약’은 사용자의 복약 안전을 돕기 위한 정보 제공용 앱입니다.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            bullet('본 앱은 복용해야 할 약을 결정하지 않습니다.\n의사의 처방이나 약사의 상담을 통해 복용약을 결정하시기 바랍니다.'),
            bullet('앱은 현재 복용 중인 의약품 간의 병용 금기 여부를 확인해주는 기능만 제공합니다.\n함께 복용해도 되는지에 대한 확인이며, 복용을 권장하거나 처방을 제안하지 않습니다.'),
            bullet('공공데이터 및 신뢰 가능한 출처에 기반하여 정보를 제공합니다.\n하지만 최신 데이터 반영에는 일정한 시차가 있을 수 있습니다.'),
            bullet('건강에 이상이 있거나 새로운 증상이 발생한 경우,\n반드시 가까운 의료기관이나 약사와 상담하시기 바랍니다.'),
            const SizedBox(height: 24),
            const Divider(thickness: 1.5),
            const SizedBox(height: 24),
            const Text(
              '💡 이 앱을 올바르게 사용하는 방법',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...[
              '복용 중인 약의 제품명 또는 생김새로 검색하여 리스트에 추가해 주세요.',
              '리스트에 등록된 약들 간 병용 금기 여부를 확인할 수 있습니다.',
              '처방 여부, 복용 용량, 증상에 대한 판단은 전문가와 상담하시기 바랍니다.',
            ].asMap().entries.map((e) => step(e.key, e.value)).toList(),
          ],
        ),
      ),
    );
  }

  static Widget bullet(String text) {
    final lines = text.split('\n');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: '${lines.first}\n',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (lines.length > 1)
                    TextSpan(text: lines.sublist(1).join('\n')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget step(int index, String text) {
    final lines = text.split('\n');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${index + 1}. ', style: const TextStyle(fontSize: 16)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: '${lines.first}\n',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (lines.length > 1)
                    TextSpan(text: lines.sublist(1).join('\n')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}