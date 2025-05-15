class Pill {
  final String entpName;
  final String itemName;
  final int itemSeq;
  final String chart;
  final String materialName;
  final String efcyQesitm;
  final String useMethodQesitm;
  final String atpnQesitm;
  final String itemImage;
  final String validTerm;

  Pill({
    required this.entpName,
    required this.itemName,
    required this.itemSeq,
    required this.chart,
    required this.materialName,
    required this.efcyQesitm,
    required this.useMethodQesitm,
    required this.atpnQesitm,
    required this.itemImage,
    required this.validTerm,
  });

  factory Pill.fromJson(Map<String, dynamic> json) {
    String clean(String? text) {
      if (text == null) return '';
      return text
          .replaceAll('\\n', '\n')
          .replaceAll('\\\\', '')
          .replaceAll(RegExp(r'\\(?!n)'), '');
    }

    return Pill(
      entpName: json['entp_name'] ?? '',
      itemName: json['item_name'] ?? '',
      itemSeq: int.tryParse(json['item_seq'] ?? '') ?? 0,
      chart: clean(json['chart']),
      materialName: clean(json['material_name']),
      efcyQesitm: clean(json['ee_doc_data']),
      useMethodQesitm: clean(json['ud_doc_data']),
      atpnQesitm: clean(json['nb_doc_data']),
      itemImage: json['item_image'] ?? '',
      validTerm: json['valid_term'] ?? '',
    );
  }
}