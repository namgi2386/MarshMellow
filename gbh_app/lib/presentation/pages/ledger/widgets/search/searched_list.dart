import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:marshmellow/di/providers/date_picker_provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SearchedList extends ConsumerStatefulWidget {
  final String searchTerm;
  final List<dynamic> searchResults; // 검색 결과 데이터
  final VoidCallback onClearAll;

  const SearchedList({
    super.key,
    required this.searchTerm,
    required this.searchResults,
    required this.onClearAll,
  });

  @override
  ConsumerState<SearchedList> createState() => _SearchedListState();
}

class _SearchedListState extends ConsumerState<SearchedList> {
  // 선택된 날짜 범위를 저장할 변수
  PickerDateRange _selectedDateRange = PickerDateRange(
    DateTime.now().subtract(const Duration(days: 30)), // 기본 시작일: 30일 전
    DateTime.now(), // 기본 종료일: 오늘
  );

  // 필터링된 검색 결과
  List<dynamic> _filteredResults = [];

  @override
  void initState() {
    super.initState();
    // 초기 필터링된 결과 설정
    _filteredResults = widget.searchResults;
  }

  @override
  void didUpdateWidget(SearchedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // widget이 업데이트되면 검색 결과도 업데이트
    if (oldWidget.searchResults != widget.searchResults) {
      _filteredResults = widget.searchResults;
    }
  }

  // 날짜 범위에 따라 결과 필터링
  void _filterResultsByDateRange(PickerDateRange range) {
    if (range.startDate == null) return;

    final startDate = range.startDate!;
    final endDate = range.endDate ?? startDate;

    setState(() {
      _selectedDateRange = range;
      _filteredResults = widget.searchResults.where((item) {
        if (item['date'] == null) return false;

        try {
          final itemDate = DateTime.parse(item['date']);
          return (itemDate.isAtSameMomentAs(startDate) ||
                  itemDate.isAfter(startDate)) &&
              (itemDate.isAtSameMomentAs(endDate) ||
                  itemDate.isBefore(endDate.add(const Duration(days: 1))));
        } catch (e) {
          return false;
        }
      }).toList();
    });
  }

  // 날짜 표시 텍스트 생성
  String _getDateRangeText() {
    if (_selectedDateRange.startDate == null) return '전체';

    final startDate = _selectedDateRange.startDate!;
    final endDate = _selectedDateRange.endDate ?? startDate;

    if (startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day) {
      return '${startDate.year}.${startDate.month}.${startDate.day}';
    } else {
      return '${startDate.year}.${startDate.month}.${startDate.day} - ${endDate.year}.${endDate.month}.${endDate.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    // DatePickerProvider 상태 구독
    final datePickerState = ref.watch(datePickerProvider);

    // 날짜가 선택되었을 때 필터링 적용
    if (datePickerState.isConfirmed && datePickerState.selectedRange != null) {
      if (_selectedDateRange != datePickerState.selectedRange) {
        // 새로운 날짜 범위로 필터링
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _filterResultsByDateRange(datePickerState.selectedRange!);
          // 확인 플래그 초기화
          ref.read(datePickerProvider.notifier).resetConfirmation();
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(_getDateRangeText(),
                style: AppTextStyles.bodySmall
                    .copyWith(fontWeight: FontWeight.w300)),
            SizedBox(width: 5),
            IconButton(
              onPressed: () {
                // 아이콘 버튼의 위치 정보 가져오기
                final RenderBox renderBox =
                    context.findRenderObject() as RenderBox;
                final position = renderBox.localToGlobal(Offset.zero);

                // DatePickerOverlay 표시 요청
                ref.read(datePickerProvider.notifier).showDatePicker(
                      position: position,
                      selectionMode: DateRangePickerSelectionMode.range,
                      initialRange: _selectedDateRange,
                    );
              },
              icon: SvgPicture.asset(IconPath.caretDown),
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            )
          ],
        ),
        const Divider(
          color: AppColors.textSecondary,
          thickness: 0.5,
        ),
        const SizedBox(height: 10),

        // 검색 결과 목록 표시
        Expanded(
          child: _filteredResults.isEmpty
              ? _buildNoResultsFound()
              : _buildSearchResultsList(),
        ),
      ],
    );
  }

  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 60),
          Image.asset(
            'assets/images/characters/char_angry_notebook.png',
            height: 150,
          ),
          const SizedBox(height: 30),
          Text(
            widget.searchTerm.isEmpty
                ? '검색 결과가 없습니다.'
                : '\'${widget.searchTerm}\'에 대한 \n검색 결과가 없습니다.',
            style:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsList() {
    return ListView.separated(
      itemCount: _filteredResults.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final result = _filteredResults[index];
        return LedgerItemTile(ledgerItem: result);
      },
    );
  }
}

// 가계부 아이템을 표시하는 위젯
class LedgerItemTile extends StatelessWidget {
  final dynamic ledgerItem;

  const LedgerItemTile({super.key, required this.ledgerItem});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        ledgerItem['title'] ?? '제목 없음',
        style: AppTextStyles.bodyMedium,
      ),
      subtitle: Text(
        '${ledgerItem['date'] ?? ''} • ${ledgerItem['category'] ?? '분류 없음'}',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      trailing: Text(
        '${ledgerItem['amount']?.toString() ?? '0'}원',
        style: AppTextStyles.bodyMedium.copyWith(
          color: (ledgerItem['isExpense'] ?? true)
              ? AppColors.textPrimary
              : AppColors.blueDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        // 아이템 탭 처리 로직
      },
    );
  }
}
