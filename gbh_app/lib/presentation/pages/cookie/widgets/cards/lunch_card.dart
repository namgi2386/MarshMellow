import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/router/routes/cookie_routes.dart';

class LunchCard extends StatelessWidget {
  const LunchCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => context.push(CookieRoutes.getLunchPath()),
      child: Container(
        height: screenHeight * 0.4,
        decoration: BoxDecoration(
          color: AppColors.yellowPrimary,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // 그림자 색상 및 투명도
              spreadRadius: 0.5, // 그림자 확산 범위
              blurRadius: 8, // 그림자 흐림 정도
              offset: Offset(0, 4), // 그림자 위치 (x, y)
            ),
          ],
        ),
        child: Stack(
          children: [
            // 제목과 부제목
            Positioned(
              top: 20,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '점심 메뉴 추천',
                    style: AppTextStyles.mainTitle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '우리 부서 메뉴 족보로 점심 고민 타파!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.greyPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // 오른쪽 화살표
            Positioned(
              top: 20,
              right: 20,
              child: SvgPicture.asset(IconPath.caretRight),
            ),

            // 인용부호와 메뉴 텍스트를 담은 컨테이너
            Positioned(
              top: screenHeight * 0.17,
              right: 20, // 오른쪽으로 정렬
              width: screenWidth * 0.6, // 적절한 너비 조정
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
                children: [
                  Transform.translate(
                    offset: Offset(0, -10), // Y축으로 -10 이동 (위로 올라감)
                    child: SvgPicture.asset(
                      IconPath.quoteLeft,
                      width: 20,
                      height: 20,
                    ),
                  ),
                  // !!!!!!!!!!!!!!!!!!!!!!여기를 바꾸면 됩니다 !!!!!!!!!!!!!!!!!!
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      '김치찌개',
                      style: AppTextStyles.modalTitle.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, -10), // Y축으로 -10 이동 (위로 올라감)
                    child: SvgPicture.asset(
                      IconPath.quoteRight,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ),
            ),

            // 캐릭터 이미지
            Positioned(
              bottom: 10,
              left: 20,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(3.14159),
                child: Image.asset(
                  'assets/images/characters/char_chair_phone.png',
                  height: screenHeight * 0.175,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // 새로고침 버튼
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  // !!!!!!!!!!!!!!!!!!!!!!여기를 바꾸면 됩니다 !!!!!!!!!!!!!!!!!!
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    IconPath.refesh,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
