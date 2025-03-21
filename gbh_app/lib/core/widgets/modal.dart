import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart'; // 앱 텍스트 스타일 참조
import 'package:marshmellow/core/theme/app_colors.dart'; // 앱 색상 참조

class Modal extends StatelessWidget {
  final Color backgroundColor;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double? maxHeight;
  final String? title; // 제목 추가
  final TextStyle? titleStyle; // 제목 스타일 추가
  final bool showDivider; // 제목과 콘텐츠 사이 구분선 표시 여부

  const Modal({
    Key? key,
    required this.backgroundColor,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    this.maxHeight,
    this.title, // 제목 파라미터
    this.titleStyle, // 제목 스타일 파라미터
    this.showDivider = true, // 기본값으로 구분선 표시
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final effectiveMaxHeight = maxHeight ?? screenHeight * 0.8;

    return Container(
      constraints: BoxConstraints(
        maxHeight: effectiveMaxHeight,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목이 있는 경우에만 표시
          if (title != null) ...[
            Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 25,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title!,
                  style: titleStyle ?? AppTextStyles.bodyMedium,
                  textAlign: TextAlign.left,
                ),
              ),
            ),

            // 구분선 표시 옵션이 활성화된 경우에만 표시
            if (showDivider)
              Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.textSecondary.withOpacity(0.3),
              ),

            SizedBox(height: 8), // 제목과 내용 사이 간격
          ],

          // 기존 내용
          Flexible(
            child: Padding(
              padding: EdgeInsets.only(
                top: title != null ? 0 : padding.vertical / 2,
                bottom: padding.vertical / 2,
                left: padding.horizontal / 2,
                right: padding.horizontal / 2,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

// EdgeInsetsGeometry에 horizontal과 vertical 속성 추가 (편의성)
extension EdgeInsetsGeometryExtension on EdgeInsetsGeometry {
  double get horizontal {
    if (this is EdgeInsets) {
      final edgeInsets = this as EdgeInsets;
      return edgeInsets.left + edgeInsets.right;
    }
    return 32.0; // 기본값
  }

  double get vertical {
    if (this is EdgeInsets) {
      final edgeInsets = this as EdgeInsets;
      return edgeInsets.top + edgeInsets.bottom;
    }
    return 40.0; // 기본값
  }
}
