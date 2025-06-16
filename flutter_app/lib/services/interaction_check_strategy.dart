import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/interaction_result.dart';
import '../settings.dart';

abstract class InteractionCheckStrategy {
  Future<InteractionResult?> check(List<String> itemSeqList);
}

class ServerInteractionCheckStrategy implements InteractionCheckStrategy {
  @override
  Future<InteractionResult?> check(List<String> itemSeqList) async {
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