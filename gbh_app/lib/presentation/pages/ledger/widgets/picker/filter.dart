import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/constants/icon_path.dart';

class TransactionFilterDropdown extends StatefulWidget {
  final Function(String) onFilterSelected;

  const TransactionFilterDropdown({
    Key? key,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  _TransactionFilterDropdownState createState() =>
      _TransactionFilterDropdownState();
}

class _TransactionFilterDropdownState extends State<TransactionFilterDropdown> {
  final List<String> _filterOptions = ['전체', '수입', '지출', '이체'];
  String _selectedFilter = '전체';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _filterOptions.map((filter) {
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
                widget.onFilterSelected(filter);
                Navigator.of(context).pop();
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      _selectedFilter == filter
                          ? IconPath.filtered
                          : IconPath.unfiltered,
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      filter,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: _selectedFilter == filter
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: _selectedFilter == filter
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// 드롭다운을 표시하는 확장 함수
extension ShowDropdown on BuildContext {
  void showTransactionFilterDropdown({
    required GlobalKey dropdownKey,
    required Function(String) onFilterSelected,
  }) {
    final RenderBox renderBox =
        dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero);

    final overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: position.dx,
            top: position.dy + size.height + 5, // 버튼 아래에 위치
            child: TransactionFilterDropdown(
              onFilterSelected: onFilterSelected,
            ),
          ),
        ],
      ),
    );

    Navigator.of(this).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [overlayEntry.builder!(context)],
          ),
        ),
      ),
    );
  }
}
