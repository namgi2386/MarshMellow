// presentation/pages/finance/widgets/simple_toggle_button_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/presentation/viewmodels/finance/finance_viewmodel.dart';

// 간편 모드 토글 상태를 위한 Provider
final simpleViewModeProvider = StateProvider<bool>((ref) => false);

class SimpleToggleButton extends ConsumerWidget {
  const SimpleToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSimpleToggleOn = ref.watch(simpleViewModeProvider);
    
    return GestureDetector(
      onTap: () {
        ref.read(simpleViewModeProvider.notifier).state = !isSimpleToggleOn;
        // 여기에 토글 동작 코드 추가
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: isSimpleToggleOn ? Colors.black : Colors.grey,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: const Text(
          "간편",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}