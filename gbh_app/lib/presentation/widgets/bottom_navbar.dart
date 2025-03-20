import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';

/*
  하단 네비게이션 바 위젯
*/
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final List<String> iconPaths;
  final List<String> labels;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.iconPaths,
    required this.labels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double navBarHeight = 70.0;

    return Container(
      width: screenWidth,
      height: navBarHeight,
      color: AppColors.backgroundBlack,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(iconPaths.length, (index) {
          return _buildNavItem(index);
        }),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    bool isSelected = selectedIndex == index;
    final double circleSize = 56.0;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end:isSelected ? 1 : 0),
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 300), 
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // 선택된 탭 = 흰색 원 배경
                    if (value > 0)
                      Container(
                        width: circleSize * value,
                        height: circleSize * value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.buttonActive.withOpacity(value),
                        ),  
                      ),

                      // 아이콘 = 선택된 탭 검정색, 아닐 경우 흰색
                      SvgPicture.asset(
                        iconPaths[index],
                        width: 24 + (value * 4),
                        height: 24 + (value * 4),
                        colorFilter : ColorFilter.mode(
                          Color.lerp(
                            AppColors.whiteLight,
                            AppColors.backgroundBlack,
                            value 
                          )!,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 4),

              // 탭 이름
              Text(
                labels[index],
                style: AppTextStyles.bodyExtraSmall.copyWith(
                  color: AppColors.whiteLight,
                ),
              ),
            ],
        ),
      )
    );
  }

}