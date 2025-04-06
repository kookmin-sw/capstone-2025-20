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
    final url = Uri.parse(
      '${ApiConstants.drugInfoUrl}?serviceKey=${ApiConstants.drugInfoKey}&itemName=$encodedName&pageNo=1&numOfRows=20&type=json',
    );

    try {
      final response = await http.get(url);
      print('Request URL: $url');
      print('Status code: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('Failed to load data');
        return [];
      }

      print('Response body: ${response.body}');
      final data = json.decode(response.body);
      final items = data['body']['items'] as List<dynamic>?;
      if (items == null) return [];

      return items.map((item) => Pill.fromJson(item)).toList();
    } catch (e) {
      print('Exception occurred: $e');
      return [];
    }
  }
}