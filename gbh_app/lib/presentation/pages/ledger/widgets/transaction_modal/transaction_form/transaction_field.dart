import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';

class TransactionField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool? showDivider;
  final EdgeInsetsGeometry? padding;

  const TransactionField({
    super.key,
    required this.label,
    this.value,
    this.onTap,
    this.trailing,
    this.showDivider = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 17),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding!,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 라벨 텍스트
                Text(
                  label,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),

                const SizedBox(width: 100),

                // 오른쪽 콘텐츠
                trailing ?? _buildDefaultTrailing(),
              ],
            ),
          ),
        ),
        if (showDivider!) const Divider(height: 0.5),
      ],
    );
  }

  Widget _buildDefaultTrailing() {
    return Text(
      value ?? '',
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
    );
  }
}
