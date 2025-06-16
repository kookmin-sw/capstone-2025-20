import '../model/pill.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../settings.dart';


// 전략 패턴
abstract class PillSearchStrategy {
  Future<List<Pill>> search();
}


class FeatureSearchStrategy implements PillSearchStrategy {
  final List<String> shape;
  final List<String> color;
  final List<String> form;
  final List<String>? line;
  final List<String>? text;

  FeatureSearchStrategy({
    required this.shape,
    required this.color,
    required this.form,
    this.line,
    this.text,
  });

  @override
  Future<List<Pill>> search() async {
    final url = Uri.parse(ApiConstants.featureSearchUrl);

    final body = {
      'shape': shape,
      'color': color,
      'form': form,
      if (line != null && line!.isNotEmpty) 'line': line,
      if (text != null && text!.isNotEmpty) 'text': text,
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
      print('Error in FeatureSearchStrategy: $e');
      return [];
    }
  }
}


class CameraSearchStrategy implements PillSearchStrategy {
  final File imageFile;

  CameraSearchStrategy(this.imageFile);

  @override
  Future<List<Pill>> search() async {
    final uri = Uri.parse(ApiConstants.cameraSearchUrl);

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final decoded = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decoded);
      final List pillsJson = data['data'];
      return pillsJson.map((json) => Pill.fromJson(json)).toList();
    } else {
      throw Exception('이미지 검색 실패: ${response.statusCode}');
    }
  }
}


class NameSearchStrategy implements PillSearchStrategy {
  final String name;

  NameSearchStrategy(this.name);

  @override
  Future<List<Pill>> search() async {
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

      return items.map((item) => Pill.fromJson(item)).toList();
    } catch (e) {
      print('Exception occurred in NameSearchStrategy: $e');
      return [];
    }
  }
}


class CodeSearchStrategy implements PillSearchStrategy {
  final int itemSeq;

  CodeSearchStrategy(this.itemSeq);

  @override
  Future<List<Pill>> search() async {
    final url = Uri.parse('${ApiConstants.drugSeqSearchUrl}?search=$itemSeq');

    try {
      final response = await http.get(url);
      if (response.statusCode != 200) return [];

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final items = data['results'] as List?;
      if (items == null || items.isEmpty) return [];

      return [Pill.fromJson(items.first)];
    } catch (e) {
      print('Exception occurred in CodeSearchStrategy: $e');
      return [];
    }
  }
}