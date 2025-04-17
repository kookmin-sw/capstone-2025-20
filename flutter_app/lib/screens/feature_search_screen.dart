import 'package:flutter/material.dart';
import 'dummy_result_screen.dart'; //시연용 더미 검색 결과

class FeatureSearchScreen extends StatefulWidget {
  const FeatureSearchScreen({super.key});

  @override
  State<FeatureSearchScreen> createState() => _FeatureSearchScreenState();
}

class _FeatureSearchScreenState extends State<FeatureSearchScreen> {
  int step = 0;

  String? selectedShape;
  List<String> selectedColors = [];
  String? selectedForm;
  String? identifierText;

  final TextEditingController identifierController = TextEditingController();

  // void nextStep() {
  //   setState(() {
  //     if (step < 3) step++;
  //   });
  // }

  void nextStep() {
    if (step < 3) {
      setState(() {
        step++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DummyResultScreen()),
      );
    }
  }

  void prevStep() {
    setState(() {
      if (step > 0) step--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('특징으로 검색')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(child: _buildStepContent()),
            const SizedBox(height: 16),
            Row(
              children: [
                if (step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: prevStep,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      child: const Text('이전'),
                    ),
                  ),
                if (step > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: nextStep,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: Text(step < 4 ? '다음' : '검색'),
                  ),
                ),
              ],
            ),
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
        return _buildIdentifierStep();
      default:
        return const SizedBox.shrink(); // fallback 처리
    }
  }

  Widget _buildShapeStep() {
    final shapes = [
      '전체', '원형', '타원형', '반원형', '삼각형',
      '사각형', '마름모', '장방형', '오각형',
      '육각형', '팔각형', '기타'
    ];

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
              final isSelected = selectedShape == shape;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedShape = shape;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.lightBlue[100] : Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      shape,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue[900] : Colors.black,
                      ),
                    ),
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
              final isSelected = selectedColors.contains(color);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedColors.remove(color);
                    } else {
                      selectedColors.add(color);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.lightBlue[100] : Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      color,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue[900] : Colors.black,
                      ),
                    ),
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
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemBuilder: (context, index) {
              final form = forms[index];
              final isSelected = selectedForm == form;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedForm = form;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.lightBlue[100] : Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      form,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue[900] : Colors.black,
                      ),
                    ),
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
          controller: identifierController,
          decoration: const InputDecoration(
            labelText: '식별 문자',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              identifierText = value;
            });
          },
        ),
      ],
    );
  }
}