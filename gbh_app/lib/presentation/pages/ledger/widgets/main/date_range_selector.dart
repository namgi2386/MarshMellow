import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:marshmellow/di/providers/date_picker_provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class DateRangeSelector extends ConsumerWidget {
  final String? dateRange;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onNextPressed;
  final double? width;
  final VoidCallback? onTap;

  const DateRangeSelector({
    Key? key,
    this.dateRange,
    this.onPreviousPressed,
    this.onNextPressed,
    this.width,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = width ?? screenWidth * 0.52;
    final datePickerState = ref.watch(datePickerProvider);
    final selectedRange = datePickerState.selectedRange;


    // 월급날 정보 들어오면 수정하세요!!!!!!!!!!!!!  
    // 표시할 날짜 문자열 계산
    String displayDateRange = dateRange ?? '';

    // DatePicker에서 선택된 범위가 있는 경우
    if (datePickerState.selectedRange != null &&
        datePickerState.selectedRange!.startDate != null) {
      final startDate = datePickerState.selectedRange!.startDate!;
      final endDate = datePickerState.selectedRange!.endDate ?? startDate;

      // 날짜 포맷 (YY.MM.dd)
      final formatter = DateFormat('yy.MM.dd');
      displayDateRange =
          '${formatter.format(startDate)} - ${formatter.format(endDate)}';
    } else {
      // 선택된 범위가 없는 경우 현재 월의 1일부터 한 달간으로 설정
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth =
          DateTime(now.year, now.month + 1, 0); // 다음 달의 0일 = 현재 달의 마지막 날

      final formatter = DateFormat('yy.MM.dd');
      displayDateRange =
          '${formatter.format(firstDayOfMonth)} - ${formatter.format(lastDayOfMonth)}';

      // 범위 업데이트 (선택적)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(datePickerProvider.notifier).updateSelectedRange(
            PickerDateRange(firstDayOfMonth, lastDayOfMonth));
      });
    }

    return GestureDetector(
      onTap: () {
        // 현재 위젯의 위치 정보를 가져와서 DatePicker를 표시
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;

        // DatePicker 오버레이 표시 요청
        ref.read(datePickerProvider.notifier).showDatePicker(
              // showPicker -> showDatePicker로 변경
              position: Offset(position.dx, position.dy + size.height),
              selectionMode: DateRangePickerSelectionMode.range,
            );

        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        height: 50,
        width: containerWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onPreviousPressed,
              child: SvgPicture.asset(IconPath.caretLeft),
            ),
            Text(
              displayDateRange,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            GestureDetector(
              onTap: onNextPressed,
              child: SvgPicture.asset(IconPath.caretRight),
            ),
          ],
        ),
      ),
    );
  }
}
