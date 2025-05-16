import 'dart:convert';
import 'package:http/http.dart' as http;
import '../settings.dart';
import '../model/pill.dart';

class FeatureSearchService {
  static Future<List<Pill>> searchByFeatures({
    required List<String> shape,
    required List<String> color,
    required List<String> form,
    List<String>? line,
    List<String>? text,
  }) async {
    final url = Uri.parse(ApiConstants.featureSearchUrl);

    final body = {
      'shape': shape,
      'color': color,
      'form': form,
      if (line != null && line.isNotEmpty) 'line': line,
      if (text != null && text.isNotEmpty) 'text': text,
    };

    print('요청 바디: ${jsonEncode(body)}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final decoded = utf8.decode(response.bodyBytes);
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 바디 (원본): $decoded');

      if (response.statusCode == 200) {
        final json = jsonDecode(decoded);
        print('응답 JSON (포맷팅): ${const JsonEncoder.withIndent('  ').convert(json)}');

        final items = json['data'] as List<dynamic>?;
        if (items == null || items.isEmpty) return [];
        return items.map((item) => Pill.fromJson(item)).toList();
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