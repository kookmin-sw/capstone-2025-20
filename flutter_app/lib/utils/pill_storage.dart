import 'package:shared_preferences/shared_preferences.dart';

class PillStorage {
  static const _key = 'takenPills';

  static Future<List<int>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final codes = prefs.getStringList(_key) ?? [];
    print('Loaded codes: $codes');
    return codes.map(int.parse).toList();
  }

  static Future<void> save(List<int> codes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, codes.map((e) => e.toString()).toList());
  }

  static Future<void> addPill(int code) async {
    final prefs = await SharedPreferences.getInstance();
    final codes = await load();
    if (!codes.contains(code)) {
      codes.add(code);
      await save(codes);
    }
  }
}