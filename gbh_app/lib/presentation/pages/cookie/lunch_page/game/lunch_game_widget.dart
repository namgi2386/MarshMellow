import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'lunch_game.dart';
import 'entities/food_ball.dart';

// 게임을 Flutter 위젯으로 감싸는 클래스
class LunchGameWidget extends StatefulWidget {
  // 선택된 메뉴 정보를 받음
  final List selectedMenus;
  final Function(List<FoodBall> winners)? onGameComplete;
  
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
  List<String> _winners = []; // _winners 변수 추가

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
      setState(() {
        _winners = winners; // 상태 업데이트
      });
      widget.onGameComplete!(finishedBalls); // 부모로 원본 데이터 전달
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget.controlled(
      gameFactory: () => _game,
      overlayBuilderMap: {
        'default': (_, game) => Container(),
      },
      loadingBuilder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorBuilder: (context, error) => Center(
        child: Text(
          '오류가 발생했습니다: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  void startGame() {
    _game.startGame();
  }

  void resetGame() {
    _game.resetGame();
    setState(() {
      _winners = []; // 리셋 시 winners 초기화
    });
  }
}