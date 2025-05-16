import 'package:html/parser.dart' show parse;
import 'package:xml/xml.dart';

class Pill {
  final String itemSeq;
  final String itemName;
  final String entpName;
  final String chart;
  final String materialName;
  final String storageMethod;
  final String validTerm;
  final String eeDocData;
  final String udDocData;
  final String nbDocData;
  final String itemImage;
  final String validTerm;

  Pill({
    required this.itemSeq,
    required this.itemName,
    required this.entpName,
    required this.chart,
    required this.materialName,
    required this.storageMethod,
    required this.validTerm,
    required this.eeDocData,
    required this.udDocData,
    required this.nbDocData,
    required this.itemImage,
    required this.validTerm,
  });

  static String _sanitize(String? value) {
    if (value == null) return '';
    final cdataReg = RegExp(r'<!\[CDATA\[(.*?)\]\]>', dotAll: true);
    final cdataMatches = cdataReg.firstMatch(value);
    final rawText = cdataMatches != null ? cdataMatches.group(1) : value;
    final document = parse(rawText);
    return parse(document.body?.text ?? '').documentElement?.text?.trim() ?? '';
  }

  static String _extractParagraphs(String? xmlData) {
    if (xmlData == null) return '';
    final document = XmlDocument.parse(xmlData);
    final paragraphs = document.findAllElements('PARAGRAPH');
    return paragraphs.map((p) => p.innerText.trim()).join('\n');
  }

  factory Pill.fromJson(Map<String, dynamic> json) {
    return Pill(
      itemSeq: json['item_seq'] ?? '',
      itemName: _sanitize(json['item_name']),
      entpName: _sanitize(json['entp_name']),
      chart: _sanitize(json['chart']),
      materialName: _sanitize(json['material_name']),
      storageMethod: _sanitize(json['storage_method']),
      validTerm: _sanitize(json['valid_term']),
      eeDocData: _extractParagraphs(json['ee_doc_data']),
      udDocData: _extractParagraphs(json['ud_doc_data']),
      nbDocData: _extractParagraphs(json['nb_doc_data']),
      itemImage: json['item_image'] ?? '',
    );
  }
}