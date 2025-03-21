import 'package:flutter/material.dart';
import 'package:marshmellow/core/widgets/text_input.dart';
import 'package:marshmellow/core/widgets/select_input.dart';

class InputPage extends StatefulWidget {
  const InputPage({Key? key}) : super(key: key);

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryController =
      TextEditingController(); // 새로 추가

  String? _emailError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _countryController.dispose(); // 추가된 컨트롤러 dispose
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text;

    if (email.isEmpty) {
      setState(() {
        _emailError = null;
      });
      return;
    }

    // 이메일 유효성 검증 정규식
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _emailError = '유효한 이메일 주소를 입력해주세요';
      });
    } else {
      setState(() {
        _emailError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('텍스트 인풋'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextInput(
              label: '이름',
              controller: _nameController,
              onChanged: (value) {
                print('이름: $value');
              },
            ),
            const SizedBox(height: 20),
            SelectInput<String>(
              label: "국가 선택",
              modalTitle: "국가 선택",
              controller: _countryController,
              items: ["미국", "캐나다", "영국", "호주", "일본", "한국"],
              itemBuilder: (context, item, isSelected) =>
                  ListTile(title: Text(item)),
              onItemSelected: (value) {
                print("선택된 국가: $value");
              },
            ),
            const SizedBox(height: 20),
            TextInput(
              label: '이메일',
              controller: _emailController,
              errorText: _emailError,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _validateEmail(); // 버튼 클릭 시 한번 더 검증
                if (_emailError == null && _emailController.text.isNotEmpty) {
                  print(
                      '폼 제출: 이름=${_nameController.text}, 이메일=${_emailController.text}, 국가=${_countryController.text}');
                }
              },
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}
