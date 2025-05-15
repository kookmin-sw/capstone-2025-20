import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
import '../model/pill.dart';
import '../settings.dart';

class PillInfoApiService {
  static Future<Pill?> fetchPillByCode(int itemSeq) async {
    final url = '${ApiConstants.drugInfoUrl}?serviceKey=${ApiConstants.drugInfoKey}&itemSeq=$itemSeq';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final Xml2Json xml2json = Xml2Json();
      xml2json.parse(utf8.decode(response.bodyBytes));
      final jsonStr = xml2json.toParker();
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);

      final item = jsonMap['response']?['body']?['items']?['item'];
      if (item == null) return null;

      // Parker 방식은 {$t: value} 구조이므로 flatten 처리
      final cleanItem = <String, dynamic>{};
      item.forEach((key, value) {
        cleanItem[key] = value is Map && value.containsKey('\$t') ? value['\$t'] : value;
      });

      return Pill.fromJson(cleanItem);
    } catch (e, stacktrace) {
      print('Error in fetchPillByCode: $e');
      print('Stacktrace: $stacktrace');
      return null;
    }
  }

  static Future<List<Pill>> fetchPillsByName(String name) async {
    final encodedName = Uri.encodeComponent(name);
    final url = Uri.parse('${ApiConstants.drugNameSearchUrl}?search=$encodedName');

    try {
      final response = await http.get(url);

      print('요청 URL: $url');
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 바디: ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode != 200) {
        print('Failed to load data');
        return [];
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final items = data['results'] as List<dynamic>?;

      if (items == null || items.isEmpty) return [];

      for (var item in items) {
        print('이미지 URL: ${item['item_image']}');
      }

      return items.map((item) => Pill.fromJson(item)).toList();
    } catch (e) {
      print('Exception occurred: $e');
      return [];
    }
  }

  static Future<List<Pill>> fetchPillsByFeatures({
    required List<String> shapeList,
    required List<String> colorList,
    required List<String> formList,
    required String identifier,
  }) async {
    final uri = Uri.parse(ApiConstants.featureSearchUrl);

    final body = jsonEncode({
      'shapes': shapeList,
      'colors': colorList,
      'forms': formList,
      'print': identifier,
    });

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        print('서버 오류: ${response.statusCode}');
        return [];
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final items = data['body']['items'] as List<dynamic>?;

      if (items == null) return [];

      return items.map((item) => Pill.fromJson(item)).toList();
    } catch (e, stacktrace) {
      print('Error in fetchPillsByFeatures: $e');
      print('Stacktrace: $stacktrace');
      return [];
    }
  }
}