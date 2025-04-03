import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/presentation/pages/cookie/lunch_page/game/entities/food_ball.dart';
import 'package:marshmellow/presentation/viewmodels/lunch/lunch_view_model.dart';
import 'package:marshmellow/presentation/widgets/button/button.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/router/routes/cookie_routes.dart';
import 'game/lunch_game_widget.dart';

class LunchRunPage extends ConsumerStatefulWidget {
  const LunchRunPage({super.key});

  @override
  ConsumerState<LunchRunPage> createState() => _LunchRunPageState();
}

class _LunchRunPageState extends ConsumerState<LunchRunPage> {
  // 게임 위젯 키 - 게임 인스턴스에 접근하기 위해 필요
  final GlobalKey<LunchGameWidgetState> _gameKey = GlobalKey<LunchGameWidgetState>();
  bool _gameStarted = false;
  List<String> _winners = [];
  
  @override
  Widget build(BuildContext context) {
  // 뷰모델에서 선택된 메뉴 목록 가져오기
  final lunchViewModel = ref.watch(lunchViewModelProvider);
  final selectedMenus = lunchViewModel.selectedMenus;
  
  return Scaffold(
    body: Stack(
      children: [
        // 게임 위젯을 전체 화면으로 배치 (최상위 레이어)
        selectedMenus.isEmpty
          ? const Center(child: Text('선택된 메뉴가 없습니다.'))
          : LunchGameWidget(
              key: _gameKey,
              selectedMenus: selectedMenus,
              onGameComplete: _handleGameComplete,
            ),

        // 상단 앱바 (게임 위에 오버레이)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              height: 70,
              alignment: Alignment.center,
              child: Text(
                'Jump Mea Choo', 
                style: AppTextStyles.mainMoneyTitle.copyWith(color: AppColors.background),
              ),
            ),
          ),
        ),

        // 메뉴 리스트 (오른쪽 상단)
        if (selectedMenus.isNotEmpty)
          Positioned(
            top: 80, // 앱바 아래 위치
            right: 10,
            child: Container(
              width: 60,
              height: selectedMenus.length * 60,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    selectedMenus.length > 10 ? 10 : selectedMenus.length, 
                    (index) {
                      final menu = selectedMenus[index];
                      return Container(
                        width: 50,
                        height: 50,
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            menu.imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }
                  ),
                ),
              ),
            ),
          ),

        // 하단 버튼 영역
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 게임 시작/다시하기 버튼
                ElevatedButton(
                  onPressed: _gameStarted ? _resetGame : _startGame,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    backgroundColor: AppColors.buttonBlack,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(_gameStarted ? '다시하기' : '시작하기', 
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[200]),
                  ),
                ),
                SizedBox(width: 12),
                // 돌아가기 버튼
                ElevatedButton(
                  onPressed: () {
                    context.replace(CookieRoutes.getLunchPath());
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    backgroundColor: AppColors.buttonBlack,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('돌아가기', 
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[200]),
                  ),
                ),
                
                // 우승 메뉴 선택 버튼 (결과가 있을 때만)
                if (_winners.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_winners.isNotEmpty) {
                          final winnerName = _winners[0];
                          final winner = selectedMenus.firstWhere(
                            (menu) => menu.name == winnerName,
                            orElse: () => selectedMenus[0],
                          );
                          lunchViewModel.selectFinalMenu(winner);
                        }
                      },
                      child: const Text('이 메뉴로 결정'),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // 게임 결과 오버레이
        if (_winners.isNotEmpty)
          _buildResultOverlay(),
      ],
    ),
  );
}
  
  // 결과 오버레이 위젯
  Widget _buildResultOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🏆 우승 메뉴 🏆',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // 1~3등 표시
            for (int i = 0; i < _winners.length && i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '${i+1}등: ${_winners[i]}',
                  style: TextStyle(
                    color: i == 0 ? Colors.yellow : Colors.white,
                    fontSize: i == 0 ? 20 : 16,
                    fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            
            const SizedBox(height: 40),
            const Text(
              '다시 하려면 "다시하기" 버튼을 누르세요',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 게임 시작 메서드
  void _startGame() {
    setState(() {
      _gameStarted = true;
      _winners = [];
    });
    _gameKey.currentState?.startGame();
  }
  
  // 게임 리셋 메서드
  void _resetGame() {
    setState(() {
      _gameStarted = false;
      _winners = [];
    });
    _gameKey.currentState?.resetGame();
  }
  
  // 게임 결과 처리 콜백
  void _handleGameComplete(List<FoodBall> finishedBalls) {
    final winners = finishedBalls.map((ball) => ball.name).toList();
    setState(() {
      _winners = winners;
    });
  }
}