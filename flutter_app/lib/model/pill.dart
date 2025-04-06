class Pill {
  final String entpName;
  final String itemName;
  final int itemSeq;
  final String efcyQesitm;
  final String useMethodQesitm;
  final String atpnWarnQesitm;
  final String atpnQesitm;
  final String intrcQesitm;
  final String seQesitm;
  final String depositMethodQesitm;
  final String openDe;
  final String updateDe;
  final String itemImage;

  Pill({
    required this.entpName,
    required this.itemName,
    required this.itemSeq,
    required this.efcyQesitm,
    required this.useMethodQesitm,
    required this.atpnWarnQesitm,
    required this.atpnQesitm,
    required this.intrcQesitm,
    required this.seQesitm,
    required this.depositMethodQesitm,
    required this.openDe,
    required this.updateDe,
    required this.itemImage,
  });

  factory Pill.fromJson(Map<String, dynamic> json) {
    String clean(String? text) {
      if (text == null) return '';
      return text
          .replaceAll('\\n', '\n')   // \n 줄바꿈 처리
          .replaceAll('\\\\', '')    // 이중 백슬래시 제거
          .replaceAll(RegExp(r'\\(?!n)'), ''); // 나머지 역슬래시 제거
    }

    return Pill(
      entpName: json['entpName'] ?? '',
      itemName: json['itemName'] ?? '',
      itemSeq: int.parse(json['itemSeq']),
      efcyQesitm: clean(json['efcyQesitm']),
      useMethodQesitm: clean(json['useMethodQesitm']),
      atpnWarnQesitm: clean(json['atpnWarnQesitm']),
      atpnQesitm: clean(json['atpnQesitm']),
      intrcQesitm: clean(json['intrcQesitm']),
      seQesitm: clean(json['seQesitm']),
      depositMethodQesitm: clean(json['depositMethodQesitm']),
      openDe: json['openDe'] ?? '',
      updateDe: json['updateDe'] ?? '',
      itemImage: json['itemImage'] ?? '',
    );
  }
}