import 'package:flutter/material.dart';
import '../model/pill.dart';

class SearchResultList extends StatelessWidget {
  final List<Pill> pills;
  final void Function(int itemSeq) onAdd;

  const SearchResultList({
    super.key,
    required this.pills,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (pills.isEmpty) {
      return const Text('검색 결과가 없습니다.');
    }

    return Expanded(
      child: ListView.builder(
        itemCount: pills.length,
        itemBuilder: (context, index) {
          final pill = pills[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: Image.network(
                pill.itemImage,
                width: 100,
                fit: BoxFit.contain, // 세로 기준으로 자연 비율 표시
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: 100,
                  child: Icon(Icons.medication, size: 40),
                ),
              ),
              title: Text(pill.itemName),
              subtitle: Text(pill.entpName),
              trailing: IconButton(
                icon: const Icon(Icons.add, size: 20), // 작은 + 아이콘
                onPressed: () => onAdd(pill.itemSeq),
              ),
            ),
          );
        },
      ),
    );
  }
}