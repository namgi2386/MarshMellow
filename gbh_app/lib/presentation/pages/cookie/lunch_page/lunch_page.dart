import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:marshmellow/core/constants/lunch_menu_data.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/presentation/viewmodels/lunch/lunch_view_model.dart';
import 'package:marshmellow/presentation/widgets/button/button.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/router/routes/cookie_routes.dart';

class LunchPage extends ConsumerWidget {
  const LunchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 뷰모델 가져오기
    final lunchViewModel = ref.watch(lunchViewModelProvider);
    
    return Scaffold(
      appBar: CustomAppbar(title: '점심 메뉴 추천'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 상단 타이틀
            const Text(
              'Jump Mea Choo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '점심 메뉴 추천',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            
            // 선택된 메뉴 표시 영역
            _buildSelectedMenusSection(lunchViewModel),
            const SizedBox(height: 16),
            
            // 메뉴 그리드 영역
            Expanded(
              child: _buildMenuGrid(context, lunchViewModel),
            ),
            
            // 시작 버튼
            Button(
              text: '시작',
              onPressed: () {
                // 시작 페이지로 이동
                context.replace(CookieRoutes.getLunchRunPath());
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 선택된 메뉴 목록을 보여주는 위젯 (2행 5열 그리드)
  Widget _buildSelectedMenusSection(LunchViewModel viewModel) {
    // 2행 4열 = 총 8개의 슬롯
    const int rows = 2;
    const int columns = 4;
    const int totalSlots = rows * columns; // 8개 슬롯
    
    return Container(
      height: 120, // 그리드 높이 조정
      child: Row(
        children: [
          // 그리드 설명 텍스트
          Container(
            // color: AppColors.pinkPrimary,
            width: 140, // 왼쪽 영역 너비 고정
            height: 120, // 높이 고정
            alignment: Alignment.centerLeft,
            child: 
            // Lottie.asset(
            //   'assets/images/loading/pot.json', fit: BoxFit.contain,),
            Image.asset(
              'assets/images/characters/char_jump.png',
              fit: BoxFit.contain,
            )
          ),
          // 그리드 영역
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns, // 4열
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1, // 정사각형
              ),
              itemCount: totalSlots, // 총 8개 슬롯
              itemBuilder: (context, index) {
                // 선택된 메뉴가 있는 경우 메뉴 표시, 없는 경우 빈 슬롯 표시
                if (index < viewModel.selectedMenus.length) {
                  return _buildFilledMenuSlot(viewModel, index);
                } else {
                  return _buildEmptyMenuSlot();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // 선택된 메뉴가 채워진 슬롯 위젯
  Widget _buildFilledMenuSlot(LunchViewModel viewModel, int index) {
    final menu = viewModel.selectedMenus[index];
    
    return GestureDetector(
      onTap: () {
        // 선택 취소
        viewModel.unselectMenuAt(index);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.blackPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.buttonBlack),
        ),
        child: Stack(
          children: [
            // 메뉴 이미지
            Center(
              child: Image.asset(
                menu.imagePath,
                width: 40,
                height: 40,
              ),
            ),
            // 삭제 아이콘
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 0, 0, 0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Color.fromARGB(255, 122, 122, 122)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 빈 메뉴 슬롯 위젯
  Widget _buildEmptyMenuSlot() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.blackLight),
      ),
    );
  }

  // 메뉴 그리드 위젯
  Widget _buildMenuGrid(BuildContext context, LunchViewModel viewModel) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,  // 4x4 그리드
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,  // 정사각형 버튼
      ),
      itemCount: allLunchMenus.length,
      itemBuilder: (context, index) {
        final menu = allLunchMenus[index];
        return _buildMenuButton(context, menu, viewModel);
      },
    );
  }

  // 개별 메뉴 버튼 위젯
  Widget _buildMenuButton(
    BuildContext context,
    LunchMenu menu,
    LunchViewModel viewModel,
  ) {
    return GestureDetector(
      onTap: () {
        if (!viewModel.isMaxSelected) {
          viewModel.selectMenu(menu);
        } else {
          // 최대 선택 개수에 도달하면 알림 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('최대 8개까지 선택 가능합니다'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  menu.imagePath,
                  fit: BoxFit.contain,
                ),
              ),
              // const SizedBox(height: 4),
              // Text(
              //   menu.name,
              //   style: const TextStyle(
              //     color: Colors.white,
              //     fontSize: 12,
              //   ),
              //   textAlign: TextAlign.center,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}