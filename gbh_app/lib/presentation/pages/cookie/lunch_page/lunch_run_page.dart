import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/presentation/viewmodels/lunch/lunch_view_model.dart';
import 'package:marshmellow/presentation/widgets/button/button.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/router/routes/cookie_routes.dart';

class LunchRunPage extends ConsumerWidget {
  const LunchRunPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 뷰모델에서 선택된 메뉴 목록 가져오기
    final lunchViewModel = ref.watch(lunchViewModelProvider);
    final selectedMenus = lunchViewModel.selectedMenus;
    
    return Scaffold(
      appBar: CustomAppbar(title: '점심 메뉴 추천 결과'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 결과 타이틀
            const Text(
              '선택한 메뉴 목록',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // 선택된 메뉴가 없을 경우
            if (selectedMenus.isEmpty)
              const Center(
                child: Text('선택된 메뉴가 없습니다.'),
              )
            // 선택된 메뉴 목록 표시
            else
              Expanded(
                child: _buildSelectedMenuList(selectedMenus),
              ),
              
            const Spacer(),
            
            // 돌아가기 버튼
            Button(
              text: '돌아가기',
              onPressed: () {
                // 다시 메뉴 선택 페이지로 이동
                context.replace(CookieRoutes.getLunchPath());
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // 선택된 메뉴 목록 위젯
  Widget _buildSelectedMenuList(List selectedMenus) {
    return ListView.separated(
      itemCount: selectedMenus.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final menu = selectedMenus[index];
        
        return ListTile(
          leading: Image.asset(
            menu.imagePath,
            width: 40,
            height: 40,
          ),
          title: Text(menu.name),
          subtitle: Text('선택 #${index + 1} ${selectedMenus.length}'),
        );
      },
    );
  }
}