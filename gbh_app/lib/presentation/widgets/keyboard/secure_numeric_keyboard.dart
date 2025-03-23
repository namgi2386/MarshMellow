// lib/presentation/widgets/keyboard/secure_numeric_keyboard.dart
import 'package:flutter/material.dart';
import 'dart:math';

class SecureNumericKeyboard extends StatefulWidget {
  final Function(String) onValueChanged;
  final String initialValue;
  final VoidCallback onClose;
  final int maxLength;
  final bool obscureText;
  
  const SecureNumericKeyboard({
    Key? key,
    required this.onValueChanged,
    this.initialValue = '',
    required this.onClose,
    this.maxLength = 0, // 0이면 제한 없음
    this.obscureText = true,
  }) : super(key: key);

  @override
  State<SecureNumericKeyboard> createState() => _SecureNumericKeyboardState();
}

class _SecureNumericKeyboardState extends State<SecureNumericKeyboard> {
  late String _currentValue;
  late List<String> _keypadNumbers;
  
  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _randomizeKeypad();
  }
  
  void _randomizeKeypad() {
    // 0-9까지 숫자 배열 생성 후 섞기
    _keypadNumbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    _keypadNumbers.shuffle(Random());
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 바
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),
              Text('보안 키패드', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                onPressed: widget.onClose,
              ),
            ],
          ),
          
          // 현재 입력값 표시 (마스킹 처리)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              widget.obscureText ? '•' * _currentValue.length : _currentValue,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
            ),
          ),
          
          // 보안 키패드 구현
          _buildSecureKeypad(),
        ],
      ),
    );
  }
  
  Widget _buildSecureKeypad() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1-9 숫자 키패드 (3x3)
        for (int row = 0; row < 3; row++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int col = 0; col < 3; col++)
                _buildKeypadButton(_keypadNumbers[row * 3 + col]),
            ],
          ),
        
        // 마지막 줄 (삭제, 0, 확인)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKeypadButton('삭제', isSpecial: true),
            _buildKeypadButton(_keypadNumbers[9]),
            _buildKeypadButton('확인', isSpecial: true),
          ],
        ),
      ],
    );
  }
  
  Widget _buildKeypadButton(String value, {bool isSpecial = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () => _handleKeyPress(value),
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(80, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: isSpecial ? Colors.grey.shade200 : null,
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: isSpecial ? 16 : 24,
            fontWeight: isSpecial ? FontWeight.normal : FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  void _handleKeyPress(String value) {
    switch(value) {
      case '삭제':
        if (_currentValue.isNotEmpty) {
          setState(() {
            _currentValue = _currentValue.substring(0, _currentValue.length - 1);
          });
        }
        break;
      case '확인':
        // 여기서 확인 버튼 기능 구현 (필요하면)
        widget.onClose();
        break;
      default:
        // 최대 길이 제한 확인
        if (widget.maxLength > 0 && _currentValue.length >= widget.maxLength) {
          return;
        }
        setState(() {
          _currentValue += value;
        });
        break;
    }
    
    // 상위 위젯에 값 전달
    widget.onValueChanged(_currentValue);
  }
}