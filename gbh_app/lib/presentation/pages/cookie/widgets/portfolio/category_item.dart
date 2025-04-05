import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_category_model.dart';

class CategoryItem extends StatelessWidget {
  final PortfolioCategory category;
  final VoidCallback onTap;

  const CategoryItem({
    Key? key,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300,
        height: 260,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 폴더 아이콘
            SvgPicture.asset(
              IconPath.folderSimple,
              width: 300,
              height: 260,
              fit: BoxFit.contain,
            ),

            // 텍스트 오버레이
            Positioned(
              top: 50,
              left: 30,
              right: 30,
              child: Column(
                mainAxisSize: MainAxisSize.min, // 컨텐츠에 맞게 크기 조정
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.portfolioCategoryName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.portfolioCategoryMemo,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                    maxLines: 1, // 메모 텍스트 줄 수 제한
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
