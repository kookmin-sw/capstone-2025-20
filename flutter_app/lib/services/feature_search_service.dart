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

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(json['items']);
    } else {
      throw Exception('서버 오류: ${response.statusCode}');
    }
  }
}