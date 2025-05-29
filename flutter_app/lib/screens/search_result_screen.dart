import 'package:flutter/material.dart';
import '../model/pill.dart';
import '../widgets/search_result_list.dart';
import '../utils/pill_storage.dart';

class SearchResultScreen extends StatelessWidget {
  final Future<List<Pill>> searchFuture;

  const SearchResultScreen({Key? key, required this.searchFuture}) : super(key: key);

  void _addPill(BuildContext context, int code) async {
    await PillStorage.addPill(code);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('복용약에 추가되었습니다')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('검색 결과'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Pill>>(
        future: searchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final results = snapshot.data ?? [];
          if (results.isEmpty) {
            return const Center(child: Text('검색 결과가 없습니다.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: SearchResultList(
                    pills: results,
                    onAdd: (itemSeq) => _addPill(context, itemSeq),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}