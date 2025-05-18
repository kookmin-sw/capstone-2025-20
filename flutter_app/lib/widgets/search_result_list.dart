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

    return ListView.builder(
      itemCount: pills.length,
      itemBuilder: (context, index) {
        final pill = pills[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          color: Color(0xFFF3FFF8),
          child: ListTile(
            leading: SizedBox(
              width: 100,
              child: Image.network(
                pill.itemImage,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.medication, size: 40),
              ),
            ),
            title: Text(pill.itemName),
            subtitle: Text(pill.entpName),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => onAdd(int.parse(pill.itemSeq)),
            ),
          ),
        );
      },
    );
  }
}