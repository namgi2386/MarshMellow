// presentation/pages/finance/widgets/banner_ad_widget.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BannerAdWidget extends StatelessWidget {
  final VoidCallback? onClose; // 닫기 콜백 추가
  
  const BannerAdWidget({
    Key? key, 
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
  return Stack(
    children: [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bluePrimary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.whiteLight,
                borderRadius: BorderRadius.all(Radius.circular(4.0))
              ),
              width: 60,
              height: 60,
              child: Center(
                child: Container(
                  color: Colors.blue,
                  child: Lottie.asset(
                    'assets/images/loading/test_lottie.json',
                    fit: BoxFit.contain, 
                  ),
                ),
              ),
            ),        
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '내 대출',
                    style: AppTextStyles.bodySmall
                  ),
                  const Text(
                    '한번에 관리해볼까?',
                    style: AppTextStyles.bodyExtraSmall
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '대출 확인하기 >',
                        style: AppTextStyles.moneyBodySmall
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      Positioned(
        top: -8,
        right: -8,
        child: IconButton(
          icon: SvgPicture.asset(IconPath.exitgray,
            width: 16,
            height: 16,
          ),
          onPressed: onClose,
        ),
      ),
    ],
  );
}
}