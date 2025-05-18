class ApiConstants {
  // static const String drugInfoUrl = 'http://apis.data.go.kr/1471000/DrbEasyDrugInfoService/getDrbEasyDrugList';
  // static const String drugInfoKey = '-'; // 업로드 시 삭제 요망!!!

  static const String baseUrl = 'http://3.34.208.34:8000'; // 서버 URL 입력

  static const String featureSearchUrl = '$baseUrl/api/drug/search/appearance/';
  static const String cameraSearchUrl = '$baseUrl/api/drug/search/image/';
  static const String drugNameSearchUrl = '$baseUrl/api/drug/';
  static const String drugSeqSearchUrl = '$baseUrl/api/drug/';
  static const String checkInteractionUrl = '$baseUrl/api/checkInteractions/';
}