import 'package:flutter/material.dart';
import '../model/pill.dart';
import '../services/pill_info_api_service.dart';
import '../utils/pill_storage.dart';

class NameSearchScreen extends StatefulWidget {
  const NameSearchScreen({super.key});

  @override
  State<NameSearchScreen> createState() => _NameSearchScreenState();
}

class _NameSearchScreenState extends State<NameSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Pill> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchPills() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    final results = await PillInfoApiService.fetchPillsByName(query);

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  Future<void> _addPill(int itemSeq) async {
    await PillStorage.addPill(itemSeq);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('복용약에 추가되었습니다')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('제품명 검색')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '제품명을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchPills(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchPills,
                  child: const Text('검색'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_searchResults.isEmpty)
              const Text('검색 결과가 없습니다.')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final pill = _searchResults[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: Image.network(
                          pill.itemImage,
                          width: 40,
                          height: 40,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.medication),
                        ),
                        title: Text(pill.itemName),
                        subtitle: Text(pill.entpName),
                        trailing: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => _addPill(pill.itemSeq),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}