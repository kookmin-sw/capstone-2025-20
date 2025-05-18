import 'package:flutter/material.dart';
import '../services/feature_search_service.dart';
import 'search_result_screen.dart';

class FeatureSearchScreen extends StatefulWidget {
  const FeatureSearchScreen({super.key});

  @override
  State<FeatureSearchScreen> createState() => _FeatureSearchScreenState();
}

class _FeatureSearchScreenState extends State<FeatureSearchScreen> {
  int step = 0;

  List<String> selectedShapeList = [];
  List<String> selectedColors = [];
  List<String> selectedLineList = [];
  List<String> selectedFormList = [];
  String frontIdentifier = '';
  String backIdentifier = '';

  final TextEditingController identifierController = TextEditingController();

  bool canProceed() {
    switch (step) {
      case 0:
        return selectedShapeList.isNotEmpty;
      case 1:
        return selectedColors.isNotEmpty;
      case 2:
        return selectedFormList.isNotEmpty;
      case 3:
        return selectedFormList.contains('정제') ? selectedLineList.isNotEmpty : true;
      case 4:
        return true;
      default:
        return true;
    }
  }

  void nextStep() async {
    if (step == 2) {
      // 정제를 선택한 경우에만 분할선 단계로 진행
      if (selectedFormList.contains('정제')) {
        setState(() {
          step = 3;
        });
      } else {
        setState(() {
          step = 4;
        });
      }
    } else if (step == 3) {
      // 분할선 다음은 무조건 식별문자 단계
      setState(() {
        step = 4;
      });
    } else if (step == 4) {
      // 검색 실행
      try {
        final results = await FeatureSearchService.searchByFeatures(
          shape: selectedShapeList,
          color: selectedColors,
          form: selectedFormList,
          line: selectedFormList.contains('정제') ? selectedLineList : [],
          text: [frontIdentifier, backIdentifier]
              .where((e) => e.trim().isNotEmpty)
              .toList(),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultScreen(results: results),
          ),
        );
      } catch (e) {
        print('검색 중 오류 발생: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('검색 중 오류가 발생했습니다.')),
        );
      }

    } else {
      // 다음 단계로
      setState(() {
        step++;
      });
    }
  }

  void prevStep() {
    setState(() {
      if (step > 0) step--;
    });
  }

  String? getPreviewImage() {
    if (selectedShapeList.isEmpty) {
      return null;
    } else if (selectedShapeList.length > 1) {
      return 'assets/multiple_shape.png';
    } else {
      final shape = selectedShapeList.first;
      final shapeImageMap = {
        '원형': 'assets/circle.png',
        '타원형': 'assets/oval.png',
        '반원형': 'assets/semicircle.png',
        '삼각형': 'assets/triangle.png',
        '사각형': 'assets/square.png',
        '마름모': 'assets/diamond.png',
        '장방형': 'assets/rectangle.png',
        '오각형': 'assets/pentagon.png',
        '육각형': 'assets/hexagon.png',
        '팔각형': 'assets/octagon.png',
        '기타': 'assets/etc.png',
      };
      return shapeImageMap[shape];
    }
  }

  Color getFlutterColor(String colorName) {
    switch (colorName) {
      case '하양':
        return Colors.white;
      case '노랑':
        return Colors.yellow;
      case '주황':
        return Colors.orange;
      case '분홍':
        return Colors.pinkAccent;
      case '빨강':
        return Colors.red;
      case '갈색':
        return Colors.brown;
      case '연두':
        return Colors.lightGreen;
      case '초록':
        return Colors.green;
      case '청록':
        return Colors.teal;
      case '파랑':
        return Colors.blue;
      case '남색':
        return Colors.indigo;
      case '자주':
        return Colors.deepPurple;
      case '보라':
        return Colors.purple;
      case '회색':
        return Colors.grey;
      case '검정':
        return Colors.black;
      case '투명':
        return Colors.grey.shade200; // 미리보기 영역 배경색
      default:
        return Colors.grey;
    }
  }

  Widget buildPreviewImage() {
    final previewImagePath = getPreviewImage();
    if (previewImagePath == null) return const SizedBox.shrink();

    Widget baseImage;

    if (selectedColors.length == 1) {
      baseImage = ColorFiltered(
        colorFilter: ColorFilter.mode(
          getFlutterColor(selectedColors.first),
          BlendMode.modulate,
        ),
        child: Image.asset(previewImagePath, fit: BoxFit.contain),
      );
    } else if (selectedColors.length == 2) {
      baseImage = SizedBox(
        width: 150,
        height: 150,
        child: Stack(
          children: [
            // 왼쪽
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.5,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        getFlutterColor(selectedColors[0]),
                        BlendMode.modulate,
                      ),
                      child: Image.asset(previewImagePath, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ),
            // 오른쪽
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.centerRight,
                    widthFactor: 0.5,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        getFlutterColor(selectedColors[1]),
                        BlendMode.modulate,
                      ),
                      child: Image.asset(previewImagePath, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (selectedColors.length >= 3) {
      baseImage = Stack(
        children: [
          Image.asset(previewImagePath, fit: BoxFit.contain),
          Positioned(
            right: 4,
            bottom: 4,
            width: 52,
            height: 52,
            child: Image.asset('assets/multiple_color.png', fit: BoxFit.contain),
          ),
        ],
      );
    } else {
      baseImage = Image.asset(
        previewImagePath,
        fit: BoxFit.contain,
      );
    }

    return baseImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('특징으로 검색')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: selectedShapeList.isEmpty
                  ? const SizedBox.shrink()
                  : buildPreviewImage(),
            ),
            const SizedBox(height: 8),
            const Text(
              '위 그림은 예시입니다.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(child: _buildStepContent()),
            const SizedBox(height: 16),
            Row(
              children: [
                if (step > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: prevStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF22CE7D),
                        side: const BorderSide(color: Color(0xFF22CE7D), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: const Text(
                        '이전',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (step > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canProceed() ? nextStep : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF22CE7D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: Text(
                      step < 3 ? '다음' : '검색',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (step) {
      case 0:
        return _buildShapeStep();
      case 1:
        return _buildColorStep();
      case 2:
        return _buildFormStep();
      case 3:
        return selectedFormList.contains('정제')
            ? _buildLineStep()
            : _buildIdentifierStep();
      case 4:
        return _buildIdentifierStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildShapeStep() {
    final shapes = [
      '전체', '원형', '타원형', '반원형', '삼각형',
      '사각형', '마름모', '장방형', '오각형',
      '육각형', '팔각형', '기타'
    ];

    final shapeImageMap = {
      '전체': 'assets/multiple_shape.png',
      '원형': 'assets/circle.png',
      '타원형': 'assets/oval.png',
      '반원형': 'assets/semicircle.png',
      '삼각형': 'assets/triangle.png',
      '사각형': 'assets/square.png',
      '마름모': 'assets/diamond.png',
      '장방형': 'assets/rectangle.png',
      '오각형': 'assets/pentagon.png',
      '육각형': 'assets/hexagon.png',
      '팔각형': 'assets/octagon.png',
      '기타': 'assets/etc.png',
    };

    bool isAllSelected() {
      final nonTotalShapes = shapes.where((e) => e != '전체').toSet();
      final selectedSet = selectedShapeList.toSet();
      return selectedSet.containsAll(nonTotalShapes) && selectedSet.length == nonTotalShapes.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('모양을 선택해주세요', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            itemCount: shapes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final shape = shapes[index];
              final isSelected = shape == '전체'
                  ? isAllSelected()
                  : selectedShapeList.contains(shape);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (shape == '전체') {
                      if (isAllSelected()) {
                        selectedShapeList.clear();
                      } else {
                        selectedShapeList = shapes.where((e) => e != '전체').toList();
                      }
                    } else {
                      if (selectedShapeList.contains(shape)) {
                        selectedShapeList.remove(shape);
                      } else {
                        selectedShapeList.add(shape);
                      }
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFFA6F3D0) : Colors.white,
                    border: Border.all(
                      color: isSelected ? Color(0xFF22CE7D) : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (shapeImageMap.containsKey(shape))
                        Center(
                          child: SizedBox(
                            height: 36,
                            width: 36,
                            child: Image.asset(
                              shapeImageMap[shape]!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        shape,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isSelected ? Color(0xFF105938) : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorStep() {
    final colors = [
      '전체', '하양', '노랑', '주황', '분홍', '빨강',
      '갈색', '연두', '초록', '청록', '파랑', '남색',
      '자주', '보라', '회색', '검정', '투명'
    ];

    final colorMap = {
      '하양': Colors.white,
      '노랑': Colors.yellow,
      '주황': Colors.orange,
      '분홍': Colors.pinkAccent,
      '빨강': Colors.red,
      '갈색': Colors.brown,
      '연두': Colors.lightGreen,
      '초록': Colors.green,
      '청록': Colors.teal,
      '파랑': Colors.blue,
      '남색': Colors.indigo,
      '자주': Colors.deepPurple,
      '보라': Colors.purple,
      '회색': Colors.grey,
      '검정': Colors.black,
      '투명': Colors.transparent,
    };

    bool isAllSelected() {
      final nonTotalColors = colors.where((e) => e != '전체').toSet();
      final selectedSet = selectedColors.toSet();
      return selectedSet.containsAll(nonTotalColors) && selectedSet.length == nonTotalColors.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('색상을 선택해주세요', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            itemCount: colors.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final color = colors[index];
              final isSelected = color == '전체'
                  ? isAllSelected()
                  : selectedColors.contains(color);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (color == '전체') {
                      if (isAllSelected()) {
                        selectedColors.clear();
                      } else {
                        selectedColors = colors.where((e) => e != '전체').toList();
                      }
                    } else {
                      if (selectedColors.contains(color)) {
                        selectedColors.remove(color);
                      } else {
                        selectedColors.add(color);
                      }
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFFA6F3D0) : Colors.white,
                    border: Border.all(
                      color: isSelected ? Color(0xFF22CE7D) : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (color != '전체')
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorMap[color] ?? Colors.transparent,
                            border: Border.all(
                              color: (color == '하양' || color == '투명')
                                  ? const Color(0xFFCCCCCC)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: color == '투명'
                              ? const Icon(Icons.clear, color: Colors.grey, size: 18)
                              : null,
                        )
                      else
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: Image.asset(
                            'assets/multiple_color.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        color,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isSelected ? Color(0xFF105938) : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormStep() {
    final forms = ['전체', '정제', '경질캡슐', '연질캡슐'];

    final formImageMap = {
      '정제': 'assets/tablet.png',
      '경질캡슐': 'assets/hard_capsule.png',
      '연질캡슐': 'assets/soft_capsule.png',
    };

    bool isAllFormsSelected() {
      final nonTotalForms = forms.where((e) => e != '전체').toSet();
      final selectedSet = selectedFormList.toSet();
      return selectedSet.containsAll(nonTotalForms) && selectedSet.length == nonTotalForms.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('제형을 선택해주세요', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            itemCount: forms.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1, // 버튼을 정사각형에 가깝게
            ),
            itemBuilder: (context, index) {
              final form = forms[index];
              final isSelected = form == '전체'
                  ? isAllFormsSelected()
                  : selectedFormList.contains(form);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (form == '전체') {
                      if (isAllFormsSelected()) {
                        selectedFormList.clear();
                      } else {
                        selectedFormList = forms.where((e) => e != '전체').toList();
                      }
                    } else {
                      if (selectedFormList.contains(form)) {
                        selectedFormList.remove(form);
                      } else {
                        selectedFormList.add(form);
                      }
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFFA6F3D0) : Colors.white,
                    border: Border.all(
                      color: isSelected ? Color(0xFF22CE7D) : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (formImageMap.containsKey(form)) ...[
                        Expanded(
                          child: Image.asset(
                            formImageMap[form]!,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 1),
                      ],
                      Text(
                        form,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Color(0xFF105938) : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLineStep() {
    final lines = ['전체', '없음', '-형', '+형'];
    final lineServerValueMap = {'-형': '-', '+형': '+'};

    final lineImageMap = {
      '-형': 'assets/line1.png',
      '+형': 'assets/line2.png',
    };

    bool isAllLinesSelected() {
      final nonTotal = lines.where((e) => e != '전체').map((e) => lineServerValueMap[e] ?? e).toSet();
      final selectedSet = selectedLineList.toSet();
      return selectedSet.containsAll(nonTotal) && selectedSet.length == nonTotal.length;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('분할선을 선택해주세요', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            itemCount: lines.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final line = lines[index];
              final isSelected = line == '전체'
                  ? isAllLinesSelected()
                  : selectedLineList.contains(lineServerValueMap[line] ?? line);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (line == '전체') {
                      if (isAllLinesSelected()) {
                        selectedLineList.clear();
                      } else {
                        selectedLineList = lines.where((e) => e != '전체').map((e) => lineServerValueMap[e] ?? e).toList();
                      }
                    } else {
                      if (selectedLineList.contains(lineServerValueMap[line] ?? line)) {
                        selectedLineList.remove(lineServerValueMap[line] ?? line);
                      } else {
                        selectedLineList.add(lineServerValueMap[line] ?? line);
                      }
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Color(0xFFA6F3D0) : Colors.white,
                    border: Border.all(
                      color: isSelected ? Color(0xFF22CE7D) : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (lineImageMap.containsKey(line)) ...[
                        Expanded(
                          child: Image.asset(
                            lineImageMap[line]!,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        line,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Color(0xFF105938) : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIdentifierStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('식별 문자 입력', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            labelText: '앞면 식별 문자',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              frontIdentifier = value.trim();
            });
          },
        ),
        const SizedBox(height: 12),
        TextField(
          enabled: frontIdentifier.isNotEmpty,
          decoration: const InputDecoration(
            labelText: '뒷면 식별 문자',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              backIdentifier = value.trim();
            });
          },
        ),
      ],
    );
  }
}