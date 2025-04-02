import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
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
      appBar: CustomAppbar(title: 'LunchRunPage'),
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 선택된 메뉴가 없을 경우
          if (selectedMenus.isEmpty)
            const Center(
              child: Text('선택된 메뉴가 없습니다.'),
            )
          // 게임 화면으로 변경
          else
            Expanded(
              child: Container(
                color: Colors.red[400],
                width: double.infinity, // 가로 전체 사용
                height: double.infinity, // 세로 전체 사용
                child: Stack(
                  children: [
                    // 게임 위젯
                    LunchGameWidget(
                      key: _gameKey,
                      selectedMenus: selectedMenus,
                      onGameComplete: _handleGameComplete,
                    ),
                    
                    // 게임 결과 오버레이
                    if (_winners.isNotEmpty)
                      _buildResultOverlay(),
                  ],
                ),
              ),
            ),
            
          // 버튼 row 추가
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 게임 시작/다시하기 버튼
              ElevatedButton(
                onPressed: _gameStarted ? _resetGame : _startGame,
                child: Text(_gameStarted ? '다시하기' : '시작하기'),
              ),
              
              // 돌아가기 버튼
              Button(
                text: '돌아가기',
                width: 100,
                onPressed: () {
                  context.replace(CookieRoutes.getLunchPath());
                },
              ),
              
              // 우승 메뉴 선택 버튼 (결과가 있을 때만)
              if (_winners.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    // 우승 메뉴를 최종 선택으로 설정
                    if (_winners.isNotEmpty) {
                      final winnerName = _winners[0];
                      final winner = selectedMenus.firstWhere(
                        (menu) => menu.name == winnerName,
                        orElse: () => selectedMenus[0],
                      );
                      
                      // 최종 선택을 ViewModel에 저장
                      lunchViewModel.selectFinalMenu(winner);
                      
                      // 다음 화면으로 이동
                      // context.replace(CookieRoutes.getLunchResultPath());
                    }
                  },
                  child: const Text('이 메뉴로 결정'),
                ),
            ],
          ),
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
  void _handleGameComplete(List<String> winners) {
    setState(() {
      _winners = winners;
    });
  }
}