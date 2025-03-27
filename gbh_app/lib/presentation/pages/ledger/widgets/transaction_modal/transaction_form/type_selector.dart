import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';

class TypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeSelected;

  const TypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 수입 버튼
        Expanded(
          child: _buildTypeButton('수입', selectedType == '수입'),
        ),
        const SizedBox(width: 8),

        // 지출 버튼
        Expanded(
          child: _buildTypeButton('지출', selectedType == '지출'),
        ),
        const SizedBox(width: 8),

        // 이체 버튼
        Expanded(
          child: _buildTypeButton('이체', selectedType == '이체'),
        ),
      ],
    );
  }

  Widget _buildTypeButton(String type, bool isSelected) {
    Color getColor() {
      switch (type) {
        case '수입':
          return AppColors.bluePrimary;
        case '지출':
          return AppColors.pinkPrimary;
        case '이체':
          return AppColors.greenPrimary;
        default:
          return Colors.transparent;
      }
    }

    return GestureDetector(
      onTap: () => onTypeSelected(type),
      child: Container(
        height: 32,
        width: 40,
        decoration: BoxDecoration(
          color: isSelected ? getColor() : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? getColor() : AppColors.textLight,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          type,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textLight,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
