// lib/presentation/widgets/keyboard/calculator_keyboard.dart
import 'package:flutter/material.dart';
import 'package:simple_numpad/simple_numpad.dart';

class CalculatorKeyboard extends StatefulWidget {
  final Function(String) onValueChanged;
  final String initialValue;
  final VoidCallback onClose;
  
  const CalculatorKeyboard({
    Key? key,
    required this.onValueChanged,
    this.initialValue = '',
    required this.onClose,
  }) : super(key: key);

  @override
  State<CalculatorKeyboard> createState() => _CalculatorKeyboardState();
}

class _CalculatorKeyboardState extends State<CalculatorKeyboard> {
  late String _currentExpression;
  late String _displayValue;
  
  @override
  void initState() {
    super.initState();
    _currentExpression = widget.initialValue;
    _displayValue = widget.initialValue;
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
              Text('계산기', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                onPressed: widget.onClose,
              ),
            ],
          ),
          
          // 계산기 키패드 커스텀 구현
          // 여기서는 simple_numpad를 확장해 사칙연산 버튼 추가 필요
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildOperatorButton('+'),
              const SizedBox(width: 10),
              _buildOperatorButton('-'),
              const SizedBox(width: 10),
              _buildOperatorButton('×'),
              const SizedBox(width: 10),
              _buildOperatorButton('÷'),
            ],
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _calculate,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('=', style: TextStyle(fontSize: 24)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOperatorButton(String operator) {
    return ElevatedButton(
      onPressed: () => _handleKeyPress(operator),
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(60, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(operator, style: const TextStyle(fontSize: 24)),
    );
  }
  
  void _handleKeyPress(String str) {
    switch(str) {
      case 'BACKSPACE':
        if (_currentExpression.isNotEmpty) {
          setState(() {
            _currentExpression = _currentExpression.substring(0, _currentExpression.length - 1);
            _displayValue = _currentExpression;
          });
        }
        break;
      case '전체삭제':
        setState(() {
          _currentExpression = '';
          _displayValue = '';
        });
        break;
      case '+':
      case '-':
      case '×':
      case '÷':
        setState(() {
          // 마지막 문자가 연산자라면 교체, 아니면 추가
          if (_currentExpression.isNotEmpty) {
            final lastChar = _currentExpression[_currentExpression.length - 1];
            if (lastChar == '+' || lastChar == '-' || lastChar == '×' || lastChar == '÷') {
              _currentExpression = _currentExpression.substring(0, _currentExpression.length - 1) + str;
            } else {
              _currentExpression += str;
            }
          }
          _displayValue = _currentExpression;
        });
        break;
      default:
        setState(() {
          _currentExpression += str;
          _displayValue = _currentExpression;
        });
        break;
    }
    
    // 상위 위젯에 값 전달
    widget.onValueChanged(_displayValue);
  }
  
  void _calculate() {
    try {
      // 계산식 처리
      String expression = _currentExpression;
      
      // 곱셈/나눗셈 기호 변환
      expression = expression.replaceAll('×', '*').replaceAll('÷', '/');
      
      // 계산 결과 구하기 (간단한 계산기 로직 - 실제로는 더 복잡할 수 있음)
      // 여기서는 간단한 계산만 시도
      List<String> numbers = [];
      List<String> operators = [];
      
      String currentNumber = '';
      for (int i = 0; i < expression.length; i++) {
        if ('0123456789'.contains(expression[i])) {
          currentNumber += expression[i];
        } else if ('+-*/'.contains(expression[i])) {
          if (currentNumber.isNotEmpty) {
            numbers.add(currentNumber);
            currentNumber = '';
          }
          operators.add(expression[i]);
        }
      }
      
      if (currentNumber.isNotEmpty) {
        numbers.add(currentNumber);
      }
      
      if (numbers.isEmpty) return;
      
      double result = double.parse(numbers[0]);
      for (int i = 0; i < operators.length; i++) {
        if (i + 1 < numbers.length) {
          double nextNum = double.parse(numbers[i + 1]);
          switch (operators[i]) {
            case '+':
              result += nextNum;
              break;
            case '-':
              result -= nextNum;
              break;
            case '*':
              result *= nextNum;
              break;
            case '/':
              if (nextNum != 0) {
                result /= nextNum;
              }
              break;
          }
        }
      }
      
      // 결과 표시 (소수점 처리)
      _currentExpression = result % 1 == 0 ? result.toInt().toString() : result.toString();
      _displayValue = _currentExpression;
      
      // 상위 위젯에 값 전달
      widget.onValueChanged(_displayValue);
      
      setState(() {});
    } catch (e) {
      // 계산 오류 처리
      setState(() {
        _displayValue = '오류';
      });
    }
  }
}