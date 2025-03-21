// lib/presentation/widgets/date_picker_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/di/providers/date_picker_provider.dart';
import 'package:marshmellow/presentation/widgets/datepicker/custom_date_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

/// DatePicker를 오버레이로 표시하는 위젯
/// 앱의 최상위 위젯에 배치해야 함
class DatePickerOverlay extends ConsumerWidget {
  final Widget child;

  const DatePickerOverlay({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datePickerState = ref.watch(datePickerProvider);

    return Stack(
      children: [
        child, // 원래 앱 내용
        
        // DatePicker가 표시되어야 할 때만 오버레이 표시
        if (datePickerState.isVisible && datePickerState.position != null)
          Positioned(
            // 위치 계산 (기준점 + 오프셋)
            // left: datePickerState.position!.dx - (MediaQuery.of(context).size.width * 0.9 / 2),
            // left: datePickerState.position!.dx,
            left: MediaQuery.of(context).size.width*0.05,
            top: datePickerState.position!.dy - 2, // 버튼 바로 아래에 표시 (간격 10)
            child: CustomDatePicker(
              selectionMode: datePickerState.selectionMode,
              initialSelectedRange: datePickerState.selectedRange,
              initialSelectedDate: datePickerState.selectedDate,
              initialSelectedDates: datePickerState.selectedDates,
              onConfirm: (range) {
                // 확인 버튼 클릭 시 선택된 범위 업데이트
                ref.read(datePickerProvider.notifier).updateSelectedRange(range);
              },
            ),
          ),
      ],
    );
  }
}