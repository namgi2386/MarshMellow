import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/ledger/category/transactions.dart';
import 'package:marshmellow/data/models/ledger/category/transaction_category.dart';
import 'package:marshmellow/presentation/viewmodels/ledger/transaction_list_viewmodel.dart';
import 'package:marshmellow/di/providers/date_picker_provider.dart'; // 이 import 추가

// 캘린더 기간 프로바이더 - 월급일 기준
final calendarPeriodProvider =
    StateProvider<(DateTime start, DateTime end)>((ref) {
  final now = DateTime.now();
  int payday = 1; // 기본 월급일

  DateTime startDay;
  // 현재 날짜가 월급일 이전이면 전 달부터, 아니면 현재 달부터
  if (now.day < payday) {
    startDay = DateTime(now.year, now.month - 1, payday);
  } else {
    startDay = DateTime(now.year, now.month, payday);
  }

  // 다음 월급일 계산
  DateTime endDay;
  if (startDay.month == 12) {
    endDay = DateTime(startDay.year + 1, 1, payday)
        .subtract(const Duration(days: 1));
  } else {
    endDay = DateTime(startDay.year, startDay.month + 1, payday)
        .subtract(const Duration(days: 1));
  }

  return (startDay, endDay);
});

// 캘린더 트랜잭션 프로바이더
final calendarTransactionsProvider =
    FutureProvider<List<Transaction>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final period = ref.watch(calendarPeriodProvider);

  return repository.getTransactions(
    startDate: period.$1,
    endDate: period.$2,
  );
});

class LedgerCalendar extends ConsumerStatefulWidget {
  const LedgerCalendar({super.key});

  @override
  ConsumerState<LedgerCalendar> createState() => _LedgerCalendarState();
}

class _LedgerCalendarState extends ConsumerState<LedgerCalendar> {
  late DateTime _selectedDay;
  final _numberFormat = NumberFormat('#,###', 'ko_KR');
  final _dayNames = ['일', '월', '화', '수', '목', '금', '토'];

  // DatePicker와 Calendar 동기화 여부를 추적하는 변수
  DateTime? _lastSyncDatePickerUpdate;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();

    // 초기 로드 시 날짜 동기화를 위해 추가
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncCalendarWithDatePicker();
    });
  }

  // DatePicker의 날짜와 Calendar의 날짜를 동기화하는 메서드
  void _syncCalendarWithDatePicker() {
    final datePickerState = ref.read(datePickerProvider);
    if (datePickerState.selectedRange != null &&
        datePickerState.selectedRange!.startDate != null) {
      final startDate = datePickerState.selectedRange!.startDate!;
      final endDate = datePickerState.selectedRange!.endDate ?? startDate;

      // 현재 설정된 캘린더 기간과 다른 경우에만 업데이트
      final currentPeriod = ref.read(calendarPeriodProvider);
      if (currentPeriod.$1 != startDate || currentPeriod.$2 != endDate) {
        ref.read(calendarPeriodProvider.notifier).state = (startDate, endDate);
        _lastSyncDatePickerUpdate = DateTime.now(); // 업데이트 시간 기록
      }
    }
  }

  // 특정 날짜의 거래 합계 계산
  Map<String, double> _calculateDailySummary(
      List<Transaction> transactions, DateTime date) {
    double income = 0;
    double expense = 0;

    for (var transaction in transactions) {
      if (transaction.dateTime.year == date.year &&
          transaction.dateTime.month == date.month &&
          transaction.dateTime.day == date.day) {
        if (transaction.classification == TransactionClassification.DEPOSIT) {
          income += transaction.householdAmount.toDouble();
        } else if (transaction.classification ==
            TransactionClassification.WITHDRAWAL) {
          expense += transaction.householdAmount.toDouble();
        }
      }
    }

    return {
      'income': income,
      'expense': expense,
    };
  }

  @override
  Widget build(BuildContext context) {
    // DatePicker의 변경을 감지
    final datePickerState = ref.watch(datePickerProvider);

    // DatePicker가 변경될 때 캘린더 기간도 업데이트
    if (datePickerState.selectedRange != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncCalendarWithDatePicker();
      });
    }

    // 현재 기간 조회
    final periodState = ref.watch(calendarPeriodProvider);
    final startDay = periodState.$1;
    final endDay = periodState.$2;

    // 트랜잭션 데이터 구독
    final transactionsAsync = ref.watch(calendarTransactionsProvider);

    // 화면 크기에 따라 달력 셀 높이 계산
    final screenWidth = MediaQuery.of(context).size.width;
    final cellWidth = screenWidth / 7; // 7일
    final cellHeight = cellWidth * 1.35; // 높이는 너비의 1.35배로 고정

    return transactionsAsync.when(
      data: (transactions) {
        // 달력 그리드를 위한 데이터 준비
        final daysInPeriod = _generateDaysForCalendar(startDay, endDay);

        return Column(
          children: [
            // 요일 헤더
            Container(
              height: 30,
              child: Row(
                children: _dayNames
                    .map((day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w300,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 8),

            // 달력 그리드
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: cellWidth / cellHeight,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                ),
                itemCount: daysInPeriod.length,
                itemBuilder: (context, index) {
                  final day = daysInPeriod[index];

                  // 날짜가 null이면 빈 셀
                  if (day == null) {
                    return const SizedBox.shrink();
                  }

                  // 해당 날짜의 거래 합계 계산
                  final summary = _calculateDailySummary(transactions, day);
                  final hasIncome = summary['income']! > 0;
                  final hasExpense = summary['expense']! > 0;

                  // 오늘 날짜 확인
                  final isToday = day.year == DateTime.now().year &&
                      day.month == DateTime.now().month &&
                      day.day == DateTime.now().day;

                  // 선택된 날짜 확인
                  final isSelected = day.year == _selectedDay.year &&
                      day.month == _selectedDay.month &&
                      day.day == _selectedDay.day;

                  // 주말 확인
                  final isWeekend = day.weekday == DateTime.saturday ||
                      day.weekday == DateTime.sunday;

                  // 현재 월 또는 표시 기간의 날짜인지 확인
                  final isInDisplayPeriod = (day.compareTo(startDay) >= 0 &&
                      day.compareTo(endDay) <= 0);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDay = day;
                      });
                      // 선택된 날짜의 트랜잭션을 보여주는 다이얼로그 등을 여기서 구현할 수 있음
                    },
                    child: Container(
                      height: cellHeight,
                      width: cellWidth,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 날짜
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color:
                                    isToday ? Colors.black : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${day.day}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isToday
                                      ? Colors.white
                                      : !isInDisplayPeriod
                                          ? AppColors.textLight
                                          : isWeekend
                                              ? AppColors.textPrimary
                                              : AppColors.textPrimary,
                                  fontWeight: isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // 수입 표시
                          if (hasIncome)
                            Text(
                              '+ ${_numberFormat.format(summary['income'])}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.blueDark,
                                fontSize: 8,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),

                          // 지출 표시
                          if (hasExpense)
                            Text(
                              '- ${_numberFormat.format(summary['expense'])}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 8,
                              ),
                              overflow: TextOverflow.ellipsis,
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('오류가 발생했습니다: $error'),
      ),
    );
  }

  List<DateTime?> _generateDaysForCalendar(DateTime startDay, DateTime endDay) {
    List<DateTime?> days = [];

    // 첫 번째 월의 1일
    final firstDayOfMonth = DateTime(startDay.year, startDay.month, 1);

    // 첫 번째 월의 1일의 요일 (0: 일요일, 1: 월요일, ...)
    final firstWeekday = firstDayOfMonth.weekday % 7;

    // 시작일과 종료일 사이의 총 일수
    final totalDaysInPeriod = endDay.difference(startDay).inDays + 1;

    // 달력에 표시할 총 날짜 수 (빈 칸 포함)
    final totalDays = firstWeekday + totalDaysInPeriod;

    // 달력 행의 수 (7일씩, 올림 처리)
    final totalWeeks = (totalDays / 7).ceil();

    // 달력의 시작일부터 이전 날짜 빈 칸 추가
    for (int i = 0; i < firstWeekday; i++) {
      days.add(null);
    }

    // startDay부터 endDay까지의 모든 날짜 추가
    for (int i = 0; i < totalDaysInPeriod; i++) {
      days.add(startDay.add(Duration(days: i)));
    }

    // 마지막 주가 7일이 되도록 빈 칸 추가
    while (days.length < totalWeeks * 7) {
      days.add(null);
    }

    return days;
  }
}
