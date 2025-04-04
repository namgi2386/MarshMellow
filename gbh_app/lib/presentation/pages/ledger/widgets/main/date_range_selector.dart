import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:marshmellow/di/providers/date_picker_provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/presentation/viewmodels/ledger/ledger_viewmodel.dart';
import 'package:marshmellow/di/providers/calendar_providers.dart';
import 'package:marshmellow/di/providers/my/salary_provider.dart';

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
    final payday = ref.watch(paydayProvider);

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
      // 현재 날짜와 월급일을 기준으로 날짜 범위 계산
      final now = DateTime.now();

      DateTime startDate;
      DateTime endDate;

      // 현재 날짜가 월급일 이전이면 전 달의 월급일부터
      if (now.day < payday) {
        startDate = DateTime(now.year, now.month - 1, payday);
        endDate = DateTime(now.year, now.month, payday - 1);
      } else {
        // 현재 날짜가 월급일 이후면 현재 달의 월급일부터
        startDate = DateTime(now.year, now.month, payday);

        // 다음 달의 월급일 이전 날까지
        if (startDate.month == 12) {
          endDate = DateTime(startDate.year + 1, 1, payday - 1);
        } else {
          endDate = DateTime(now.year, now.month + 1, payday - 1);
        }
      }

      final formatter = DateFormat('yy.MM.dd');
      displayDateRange =
          '${formatter.format(startDate)} - ${formatter.format(endDate)}';

      // 범위 업데이트 (선택적)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(datePickerProvider.notifier)
            .updateSelectedRange(PickerDateRange(startDate, endDate));

        // 초기 데이터 로드 추가
        ref
            .read(ledgerViewModelProvider.notifier)
            .loadHouseholdData(PickerDateRange(startDate, endDate));
      });
    }

    // 이전 기간으로 이동하는 함수
    void moveToPreviousPeriod() {
      if (datePickerState.selectedRange != null &&
          datePickerState.selectedRange!.startDate != null) {
        final startDate = datePickerState.selectedRange!.startDate!;
        final endDate = datePickerState.selectedRange!.endDate ?? startDate;

        DateTime newStartDate;
        DateTime newEndDate;

        // 월급일 기준으로 이전 기간 계산
        if (startDate.day == payday) {
          // 이전 달의 월급일
          if (startDate.month == 1) {
            // 1월인 경우 특별 처리
            newStartDate = DateTime(startDate.year - 1, 12, payday);
            newEndDate = DateTime(startDate.year, 1, payday - 1);
          } else {
            newStartDate =
                DateTime(startDate.year, startDate.month - 1, payday);
            newEndDate = DateTime(startDate.year, startDate.month, payday - 1);
          }
        } else {
          // 월 단위가 아닌 경우는 기존 로직 사용
          final duration = endDate.difference(startDate);
          newStartDate = startDate.subtract(duration + const Duration(days: 1));
          newEndDate = startDate.subtract(const Duration(days: 1));
        }

        ref
            .read(datePickerProvider.notifier)
            .updateSelectedRange(PickerDateRange(newStartDate, newEndDate));

        // 캘린더 프로바이더도 함께 업데이트
        ref.read(calendarPeriodProvider.notifier).state =
            (newStartDate, newEndDate);

        // 새 날짜 범위로 데이터 로드
        ref
            .read(ledgerViewModelProvider.notifier)
            .loadHouseholdData(PickerDateRange(newStartDate, newEndDate));
      }

      // 외부에서 전달된 콜백이 있으면 실행
      if (onPreviousPressed != null) {
        onPreviousPressed!();
      }
    }

    // 다음 기간으로 이동하는 함수
    void moveToNextPeriod() {
      if (datePickerState.selectedRange != null &&
          datePickerState.selectedRange!.startDate != null) {
        final startDate = datePickerState.selectedRange!.startDate!;
        final endDate = datePickerState.selectedRange!.endDate ?? startDate;

        DateTime newStartDate;
        DateTime newEndDate;

        // 월급일 기준으로 다음 기간 계산
        if (startDate.day == payday) {
          // 다음 달의 월급일
          if (startDate.month == 12) {
            // 12월인 경우 특별 처리
            newStartDate = DateTime(startDate.year + 1, 1, payday);
            newEndDate = DateTime(startDate.year + 1, 2, payday - 1);
          } else {
            newStartDate =
                DateTime(startDate.year, startDate.month + 1, payday);
            newEndDate =
                DateTime(startDate.year, startDate.month + 2, payday - 1);
          }
        } else {
          // 월 단위가 아닌 경우는 기존 로직 사용
          final duration = endDate.difference(startDate);
          newStartDate = endDate.add(const Duration(days: 1));
          newEndDate = newStartDate.add(duration);
        }

        ref
            .read(datePickerProvider.notifier)
            .updateSelectedRange(PickerDateRange(newStartDate, newEndDate));

        // 캘린더 프로바이더도 함께 업데이트
        ref.read(calendarPeriodProvider.notifier).state =
            (newStartDate, newEndDate);

        // 새 날짜 범위로 데이터 로드
        ref
            .read(ledgerViewModelProvider.notifier)
            .loadHouseholdData(PickerDateRange(newStartDate, newEndDate));
      }

      // 외부에서 전달된 콜백이 있으면 실행
      if (onNextPressed != null) {
        onNextPressed!();
      }
    }

    return GestureDetector(
      onTap: () {
        // 현재 위젯의 위치 정보를 가져와서 DatePicker를 표시
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;

        // DatePicker 오버레이 표시 요청
        ref.read(datePickerProvider.notifier).showDatePicker(
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
              onTap: moveToPreviousPeriod,
              child: SvgPicture.asset(IconPath.caretLeft),
            ),
            Text(
              displayDateRange,
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            GestureDetector(
              onTap: moveToNextPeriod,
              child: SvgPicture.asset(IconPath.caretRight),
            ),
          ],
        ),
      ),
    );
  }
}
