import 'package:flutter/material.dart';
import '../model/pill.dart';
import '../widgets/search_result_list.dart';
import '../utils/pill_storage.dart';

class SearchResultScreen extends StatelessWidget {
  final List<Pill> results;

  const SearchResultScreen({
    Key? key,
    required this.results,
  }) : super(key: key);

  void _addPill(BuildContext context, int code) async {
    await PillStorage.addPill(code);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('복용약에 추가되었습니다')),
    );
    Navigator.pop(context, true); // 결과 반영을 위해 true 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('검색 결과')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: results.isEmpty
            ? const Center(child: Text('검색 결과가 없습니다.'))
            : Column(
          children: [
            Expanded(
              child: SearchResultList(
                pills: results,
                onAdd: (itemSeq) => _addPill(context, itemSeq),
              ),
            ),
          ],
        ),
      ),
    );
  }
}