class Appearance {
  final String itemSeq;
  final String itemName;
  final String? drugShape;       // 제형
  final String? colorClass1;     // 주요 색상
  final String? colorClass2;     // 보조 색상
  final String? printFront;      // 식별 문자 앞면
  final String? printBack;       // 식별 문자 뒷면
  final String? lineFront;       // 분할선 앞면
  final String? lineBack;        // 분할선 뒷면
  final String? itemImage;       // 이미지

  Appearance({
    required this.itemSeq,
    required this.itemName,
    this.drugShape,
    this.colorClass1,
    this.colorClass2,
    this.printFront,
    this.printBack,
    this.lineFront,
    this.lineBack,
    this.itemImage,
  });

  factory Appearance.fromJson(Map<String, dynamic> json) {
    return Appearance(
      itemSeq: json['item_seq'],
      itemName: json['item_name'],
      drugShape: json['drug_shape'],
      colorClass1: json['color_class1'],
      colorClass2: json['color_class2'],
      printFront: json['print_front'],
      printBack: json['print_back'],
      lineFront: json['line_front'],
      lineBack: json['line_back'],
      itemImage: json['item_image'],
    );
  }
}