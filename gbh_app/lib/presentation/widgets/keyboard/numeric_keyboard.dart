// lib/presentation/widgets/keyboard/numeric_keyboard.dart
import 'package:flutter/material.dart';
import 'package:simple_numpad/simple_numpad.dart';

class NumericKeyboard extends StatefulWidget {
  final Function(String) onValueChanged;
  final String initialValue;
  final VoidCallback onClose;
  
  const NumericKeyboard({
    Key? key,
    required this.onValueChanged,
    this.initialValue = '',
    required this.onClose,
  }) : super(key: key);

  @override
  State<NumericKeyboard> createState() => _NumericKeyboardState();
}

class _NumericKeyboardState extends State<NumericKeyboard> {
  late String _currentValue;
  
  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
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
              Text('숫자 입력', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                onPressed: widget.onClose,
              ),
            ],
          ),
          
          // 키패드
          SimpleNumpad(
            buttonWidth: 80,
            buttonHeight: 60,
            gridSpacing: 10,
            buttonBorderRadius: 8,
            useBackspace: true,
            optionText: '전체삭제',
            onPressed: (str) {
              _handleKeyPress(str);
            },
          ),
        ],
      ),
    );
  }
  
  void _handleKeyPress(String str) {
    switch(str) {
      case 'BACKSPACE':
        if (_currentValue.isNotEmpty) {
          setState(() {
            _currentValue = _currentValue.substring(0, _currentValue.length - 1);
          });
        }
        break;
      case '전체삭제':
        setState(() {
          _currentValue = '';
        });
        break;
      default:
        setState(() {
          _currentValue += str;
        });
        break;
    }
    
    // 상위 위젯에 값 전달
    widget.onValueChanged(_currentValue);
  }
}