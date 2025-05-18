import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/pill.dart';
import '../settings.dart';

class CameraSearchService {
  static Future<List<Pill>> searchByImage(File imageFile) async {
    final uri = Uri.parse(ApiConstants.cameraSearchUrl);

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List pillsJson = data['data'];
      return pillsJson.map((json) => Pill.fromJson(json)).toList();
    } else {
      throw Exception('이미지 검색 실패: ${response.statusCode}');
    }
  }
}