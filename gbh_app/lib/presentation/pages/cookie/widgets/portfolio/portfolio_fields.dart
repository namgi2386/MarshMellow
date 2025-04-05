import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/portfolio_field.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/editable_memo_filed.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/picker/date_time_wheel_picker.dart';

// PortfolioFields 클래스
class PortfolioFields {
  // 날짜 필드
  static PortfolioField dateField({
    required DateTime selectedDate,
    required BuildContext context,
    required WidgetRef ref,
    required Function(DateTime) onDateChanged,
    bool includeTime = true,
    bool enabled = true,
  }) {
    // 날짜 포맷
    String formattedDate =
        '${selectedDate.year}년 ${selectedDate.month.toString().padLeft(2, '0')}월 ${selectedDate.day.toString().padLeft(2, '0')}일';

    // 시간 포함 시 포맷 변경
    if (includeTime) {
      formattedDate +=
          ' ${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}';
    }

    return PortfolioField(
      label: includeTime ? '날짜 및 시간' : '날짜',
      trailing: Text(
        formattedDate,
        style: AppTextStyles.bodySmall.copyWith(
          color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
      onTap: enabled
          ? () {
              showDateTimePickerBottomSheet(
                context: context,
                ref: ref,
                initialDateTime: selectedDate,
                onDateTimeChanged: onDateChanged,
                initialMode: CupertinoDatePickerMode.date,
                confirmButtonText: includeTime ? '확인' : '선택',
                nextButtonText: '다음',
              );
            }
          : null,
    );
  }

  // 카테고리 필드
  static PortfolioField categoryField({
    required BuildContext context,
    String? selectedCategory,
    required Function(String) onCategorySelected,
    bool enabled = true,
  }) {
    return PortfolioField(
      label: '카테고리',
      value: selectedCategory,
      onTap: enabled
          ? () {
              // 여기에 카테고리 선택 모달 표시 로직 구현
              // 예: 포트폴리오 카테고리 목록을 보여주는 바텀시트 표시
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => _buildCategoryPicker(
                  context, 
                  onCategorySelected
                ),
              );
            }
          : null,
      valueStyle: AppTextStyles.bodySmall.copyWith(
        color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
      ),
    );
  }

  // 파일명 필드 (편집 가능)
  static Widget editableFileNameField({
    String? fileName,
    required Function(String) onFileNameChanged,
    bool enabled = true,
  }) {
    return EditableMemoField(
      label: '파일명',
      initialValue: fileName,
      onChanged: onFileNameChanged,
      enabled: enabled,
    );
  }

  // 메모/키워드 필드 (편집 가능)
  static Widget editableMemoField({
    String? memo,
    required Function(String) onMemoChanged,
    bool enabled = true,
  }) {
    return EditableMemoField(
      label: '메모/키워드',
      initialValue: memo,
      onChanged: onMemoChanged,
      enabled: enabled,
    );
  }

  // 카테고리 선택 피커 구현
  static Widget _buildCategoryPicker(
    BuildContext context,
    Function(String) onCategorySelected,
  ) {
    // 샘플 카테고리 목록
    final categories = [
      "커뮤니케이션 플랫폼",
      "금융 서비스",
      "쇼핑몰",
      "게임",
      "교육",
      "건강/의료",
      "여행",
      "소셜 미디어",
      "엔터테인먼트",
      "기타"
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들바
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                Text(
                  "카테고리 선택",
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),

          // 카테고리 목록
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    categories[index],
                    style: AppTextStyles.bodyMedium,
                  ),
                  onTap: () {
                    onCategorySelected(categories[index]);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          
          // 하단 여백
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}