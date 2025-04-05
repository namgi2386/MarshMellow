import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_model.dart';

class PortfolioItem extends StatelessWidget {
  final Portfolio portfolio;
  final VoidCallback onTap;

  const PortfolioItem({
    Key? key,
    required this.portfolio,
    required this.onTap,
  }) : super(key: key);

  // 파일 확장자에 따른 아이콘을 선택하는 메서드
  String _selectFileIcon(String fileName) {
    // 파일명에서 확장자 추출 (대소문자 구분 없이)
    final extension = _extractFileExtension(fileName);

    // 확장자에 따른 아이콘 매핑
    return switch (extension) {
      'pdf' => IconPath.filePdf,
      'doc' || 'docx' => IconPath.fileDoc,
      'xls' || 'xlsx' => IconPath.fileXls,
      'ppt' || 'pptx' => IconPath.filePpt,
      'jpg' || 'jpeg' => IconPath.fileJpg,
      'png' => IconPath.filePng,
      'svg' => IconPath.fileSvg,
      'txt' => IconPath.fileTxt,
      'zip' || 'rar' => IconPath.fileZip,
      'csv' => IconPath.fileCsv,
      _ => IconPath.fileText
    };
  }

  // 안전하게 파일 확장자를 추출하는 메서드
  String _extractFileExtension(String fileName) {
    try {
      // URL이나 전체 경로에서도 확장자 추출 가능
      final parts = fileName.split('.');
      return parts.isNotEmpty ? parts.last.toLowerCase() : '';
    } catch (e) {
      // 예외 발생 시 기본값 반환
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            SvgPicture.asset(
              _selectFileIcon(portfolio.originFileName),
              width: 30,
              height: 30,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(
                AppColors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),

            // 파일 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 파일명
                  Text(
                    portfolio.fileName,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // 파일 메모
                  Text(
                    portfolio.portfolioMemo,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w300,
                    ),
                    maxLines: 1,
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
