import 'package:flutter/material.dart';
import '../model/pill.dart';
import '../widgets/search_result_list.dart';

class SearchResultScreen extends StatelessWidget {
  final List<Map<String, dynamic>> results;

  const SearchResultScreen({
    Key? key,
    required this.results,
  }) : super(key: key);

  void _addPill(int code) {
    // 예: PillStorage.addPill(code);
  }

  @override
  Widget build(BuildContext context) {
    final pills = results.map((json) => Pill.fromJson(json)).toList();

    // 디버깅용 출력
    print('검색 결과 개수: ${pills.length}');
    for (final pill in pills) {
      print('약 이름: ${pill.itemName}, 코드: ${pill.itemSeq}');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('검색 결과')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: pills.isEmpty
            ? const Center(child: Text('검색 결과가 없습니다.'))
            : SearchResultList(
          pills: pills,
          onAdd: _addPill,
        ),
      ),
    );
  }
}