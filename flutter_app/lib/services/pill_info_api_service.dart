import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';
import '../model/pill.dart';
import '../model/interaction_result.dart';
import '../settings.dart';

class PillInfoApiService {
  // 제품 번호로 검색 - 공공 API에서
  // static Future<Pill?> fetchPillByCode(int itemSeq) async {
  //   final url = '${ApiConstants.drugInfoUrl}?serviceKey=${ApiConstants.drugInfoKey}&itemSeq=$itemSeq';
  //
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     if (response.statusCode != 200) return null;
  //
  //     final Xml2Json xml2json = Xml2Json();
  //     xml2json.parse(utf8.decode(response.bodyBytes));
  //     final jsonStr = xml2json.toParker();
  //     final Map<String, dynamic> jsonMap = json.decode(jsonStr);
  //
  //     final item = jsonMap['response']?['body']?['items']?['item'];
  //     if (item == null) return null;
  //
  //     // Parker 방식은 {$t: value} 구조이므로 flatten 처리
  //     final cleanItem = <String, dynamic>{};
  //     item.forEach((key, value) {
  //       cleanItem[key] = value is Map && value.containsKey('\$t') ? value['\$t'] : value;
  //     });
  //
  //     return Pill.fromJson(cleanItem);
  //   } catch (e, stacktrace) {
  //     print('Error in fetchPillByCode: $e');
  //     print('Stacktrace: $stacktrace');
  //     return null;
  //   }
  // }

  // 제품 번호로 검색 - 우리 서버에서 검색
  static Future<Pill?> fetchPillByCode(int itemSeq) async {
    final url = Uri.parse('${ApiConstants.drugSeqSearchUrl}?search=$itemSeq');

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final items = data['body']?['items'] as List?;
      if (items == null || items.isEmpty) return null;

      return Pill.fromJson(items.first);
    } catch (e, stacktrace) {
      print('Error in fetchPillByCode: $e');
      print('Stacktrace: $stacktrace');
      return null;
    }
  }

  // 제품명으로 검색 - 공공 API에서 검색
  // static Future<List<Pill>> fetchPillsByName(String name) async {
  //   final encodedName = Uri.encodeComponent(name);
  //   final url = Uri.parse(
  //     '${ApiConstants.drugInfoUrl}?serviceKey=${ApiConstants.drugInfoKey}&itemName=$encodedName&pageNo=1&numOfRows=20&type=json',
  //   );
  //
  //   try {
  //     final response = await http.get(url);
  //     print('Request URL: $url');
  //     print('Status code: ${response.statusCode}');
  //
  //     if (response.statusCode != 200) {
  //       print('Failed to load data');
  //       return [];
  //     }
  //
  //     print('Response body: ${response.body}');
  //     final data = json.decode(response.body);
  //     final items = data['body']['items'] as List<dynamic>?;
  //     if (items == null) return [];
  //
  //     return items.map((item) => Pill.fromJson(item)).toList();
  //   } catch (e) {
  //     print('Exception occurred: $e');
  //     return [];
  //   }
  // }

  // 제품명으로 검색 - 우리 서버에서 검색
  static Future<List<Pill>> fetchPillsByName(String name) async {
    final encodedName = Uri.encodeComponent(name);
    final url = Uri.parse(
        '${ApiConstants.drugNameSearchUrl}?search=$encodedName');

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) {
        print('Failed to load data');
        return [];
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final items = data['body']['items'] as List<dynamic>?;
      if (items == null) return [];

      return items.map((item) => Pill.fromJson(item)).toList();
    } catch (e) {
      print('Exception occurred: $e');
      return [];
    }
  }

  // 병용 금기 검사
  static Future<InteractionResult?> checkInteractions(
      List<int> itemSeqList) async {
    final url = Uri.parse(ApiConstants.checkInteractionUrl);
    final body = jsonEncode({'itemSeqList': itemSeqList});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return InteractionResult.fromJson(data);
      } else {
        print('병용 금기 요청 실패: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('병용 금기 검사 오류: $e');
      return null;
    }
  }
}