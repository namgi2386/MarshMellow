import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'lunch_game.dart';
import 'entities/food_ball.dart';

// 게임을 Flutter 위젯으로 감싸는 클래스
class LunchGameWidget extends StatefulWidget {
  // 선택된 메뉴 정보를 받음
  final List selectedMenus;
  final Function(List<String> winners)? onGameComplete;
  
  const LunchGameWidget({
    Key? key,
    required this.selectedMenus,
    this.onGameComplete,
  }) : super(key: key);

  @override
  State<LunchGameWidget> createState() => LunchGameWidgetState();
}

class LunchGameWidgetState extends State<LunchGameWidget> {
  // 게임 인스턴스
  late LunchGame _game;
  
  @override
  void initState() {
    super.initState();
    _game = LunchGame(selectedMenus: widget.selectedMenus);
    _game.onGameComplete = _handleGameComplete;
  }
  
  // 게임 완료 처리
  void _handleGameComplete(List<FoodBall> finishedBalls) {
    if (widget.onGameComplete != null) {
      // 메뉴 이름 목록으로 변환
      final winners = finishedBalls.map((ball) => ball.name).toList();
      widget.onGameComplete!(winners);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Flame의 GameWidget으로 우리 게임을 감싸서 반환
    return GameWidget(
      game: _game,
      // 로딩 화면 표시
      loadingBuilder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
      // 에러 발생시 표시할 화면
      errorBuilder: (context, error) => Center(
        child: Text(
          '오류가 발생했습니다: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
  
  // 게임 시작 메서드 - 외부에서 호출
  void startGame() {
    _game.startGame();
  }
  
  // 게임 리셋 메서드 - 외부에서 호출
  void resetGame() {
    _game.resetGame();
  }
}