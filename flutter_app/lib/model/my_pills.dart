import '../services/pill_info_api_service.dart';
import 'pill.dart';

class MyPills {
  final List<int> itemSeqList;

  MyPills({required this.itemSeqList});

  Future<List<Pill>> fetchAll() async {
    final futures = itemSeqList.map(PillInfoApiService.fetchPillByCode);
    final results = await Future.wait(futures);
    return results.whereType<Pill>().toList();
  }

  Future<void> add(int code) async {
    if (!itemSeqList.contains(code)) {
      itemSeqList.add(code);
    }
  }

  Future<void> remove(int code) async {
    itemSeqList.remove(code);
  }
}