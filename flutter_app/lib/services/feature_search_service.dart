import 'dart:convert';
import 'package:http/http.dart' as http;
import '../settings.dart';

class FeatureSearchService {
  static Future<List<Map<String, dynamic>>> searchByFeatures({
    required List<String> shapes,
    required List<String> colors,
    required List<String> forms,
    List<String>? lines,
    List<String>? identifiers,
  }) async {
    final url = Uri.parse(ApiConstants.featureSearchUrl);

    final body = {
      'shapes': shapes,
      'colors': colors,
      'forms': forms,
      if (lines != null && lines.isNotEmpty) 'lines': lines,
      if (identifiers != null && identifiers.isNotEmpty) 'identifiers': identifiers,
    };

    print('요청 바디: ${jsonEncode(body)}'); // 콘솔에 출력

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('응답 바디: ${response.body}'); // 콘솔에 출력

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final json = jsonDecode(decoded);
        final items = json['data'] as List<dynamic>?;

        if (items == null || items.isEmpty) return [];

        return items
            .where((item) => item['drug_info'] != null)
            .map((item) => Pill.fromJson(item['drug_info']))
            .toList();
      } else {
        print('서버 오류: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error in FeatureSearchService: $e');
      return [];
    }
  }
}