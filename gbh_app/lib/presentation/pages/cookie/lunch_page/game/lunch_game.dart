import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'dart:math' as math;
import 'entities/floor.dart';
import 'entities/food_ball.dart';
import 'entities/wall.dart';

class LunchGame extends Forge2DGame {
  final List selectedMenus;
  bool gameStarted = false;
  final List<FoodBall> foodBalls = [];
  final List<FoodBall> finishedBalls = [];
  Function(List<FoodBall>)? onGameComplete;

  FoodBall? _trackedBall;
  late Vector2 worldSize;

  // 화면 스크롤링을 위한 변수들
  double _worldYOffset = 0;  // 월드의 y축 오프셋
  double _targetYOffset = 0; // 목표 y축 오프셋
  final double _scrollSpeed = 5.0; // 스크롤 속도 조절 (필요에 따라 조정)

  LunchGame({required this.selectedMenus}) : super(gravity: Vector2(0, 40.0)) {
    print('World initialized: ${world != null}');
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 월드 크기 설정 (화면 높이의 2배)
    worldSize = Vector2(size.x, size.y * 2);
    
    // 경계 추가 (벽과 바닥)
    _addBoundaries(worldSize);

    // 장애물 추가
    _addObstacles(worldSize);

    // 공 추가
    _addFoodBalls(worldSize);
  }

  @override
  void update(double dt) {
    super.update(dt * 1.5);
    
    if (gameStarted && _trackedBall != null) {
      // 공의 위치 가져오기
      final ballPosition = _trackedBall!.body.position;
      
      // 목표 오프셋 계산: 공이 화면의 1/3 지점에 위치하도록
      _targetYOffset = ballPosition.y - (size.y / 3);
      
      // 현재 오프셋을 목표 오프셋으로 부드럽게 이동
      _worldYOffset += (_targetYOffset - _worldYOffset) * dt * _scrollSpeed;
      
      // 모든 객체의 렌더링 위치 조정 (이 부분은 renderOffset으로 처리)
      
      // 디버깅
      print('공 위치: $ballPosition, 오프셋: $_worldYOffset');
      
      // 공이 바닥에 닿았는지 확인
      if (ballPosition.y > worldSize.y - 60 && !finishedBalls.contains(_trackedBall)) {
        onBallFinished(_trackedBall!);
      }
    }
  }

  // 객체의 렌더링 위치를 오프셋만큼 조정
  @override
  void render(Canvas canvas) {
    // 캔버스 상태 저장
    canvas.save();
    
    // 캔버스를 오프셋만큼 이동 (화면 스크롤링 효과)
    canvas.translate(0, -_worldYOffset);
    
    // 배경 그리기
    canvas.drawColor(AppColors.backgroundBlack, BlendMode.src);
    
    // 월드 렌더링
    super.render(canvas);
    
    // 캔버스 상태 복원
    canvas.restore();
  }

  // 경계 추가 메서드
  void _addBoundaries(Vector2 worldSize) {
    final wallThickness = worldSize.x * 0.01;
    
    // 바닥 추가
    final floor = Floor(
      position: Vector2(worldSize.x / 2, worldSize.y - 20),
      size: Vector2(worldSize.x, 40),
      color: Colors.white,
    );
    add(floor);
    print('Floor added at ${worldSize.y - 20}');
    
    // 왼쪽 벽
    add(Wall(
      position: Vector2(wallThickness / 2, worldSize.y / 2),
      size: Vector2(wallThickness, worldSize.y),
      color: Colors.brown.shade600,
    ));
    
    // 오른쪽 벽
    add(Wall(
      position: Vector2(worldSize.x - wallThickness / 2, worldSize.y / 2),
      size: Vector2(wallThickness, worldSize.y),
      color: Colors.brown.shade600,
    ));
  }

  // 장애물 추가 메서드 (변경 없음)
  void _addObstacles(Vector2 worldSize) {
    final obstacleWidth = worldSize.x * 0.15;
    final obstacleHeight = worldSize.y * 0.01;
    
    add(Wall(
      position: Vector2(worldSize.x * 0.3, worldSize.y * 0.3),
      size: Vector2(obstacleWidth, obstacleHeight),
      color: AppColors.whitePrimary,
    ));
    
    add(Wall(
      position: Vector2(worldSize.x * 0.7, worldSize.y * 0.5),
      size: Vector2(obstacleWidth, obstacleHeight),
      color: AppColors.whitePrimary,
    ));
    
    add(Wall(
      position: Vector2(worldSize.x * 0.4, worldSize.y * 0.7),
      size: Vector2(obstacleWidth, obstacleHeight),
      color: AppColors.whitePrimary,
    ));
    
    add(Wall(
      position: Vector2(worldSize.x * 0.6, worldSize.y * 0.8),
      size: Vector2(obstacleWidth, obstacleHeight),
      color: AppColors.whitePrimary,
    ));
  }

  // 음식 공 추가 메서드 (변경 없음)
  void _addFoodBalls(Vector2 worldSize) {
    if (selectedMenus.isEmpty) return;
    
    final ballRadius = worldSize.x * 0.05;
    final startY = ballRadius * 2;
    final menuCount = selectedMenus.length;
    final spacing = worldSize.x / (menuCount + 1);
    
    for (int i = 0; i < menuCount; i++) {
      final menu = selectedMenus[i];
      final xPos = spacing * (i + 1);
      
      final colors = [
        Colors.red, Colors.blue, Colors.green,
        Colors.yellow, Colors.purple, Colors.orange
      ];
      final color = colors[i % colors.length];
      
      final foodBall = FoodBall(
        position: Vector2(xPos, startY),
        radius: ballRadius,
        name: menu.name,
        imagePath: menu.imagePath,
        game: this,
        color: color,
      );
      
      foodBalls.add(foodBall);
      add(foodBall);
    }
  }

  // 공이 바닥에 닿았을 때 호출
  void onBallFinished(FoodBall ball) {
    print('Ball finished: ${ball.name}, Position: ${finishedBalls.length}');
    if (!finishedBalls.contains(ball)) {
      finishedBalls.add(ball);
      if (finishedBalls.length == 1) { // 첫 번째 공만 처리
        _finishGame();
      }
    }
  }

  // 게임 종료
  void _finishGame() {
    print('Game finished with winner: ${finishedBalls.first.name}');
    if (onGameComplete != null) {
      onGameComplete!(finishedBalls);
    }
  }

  // 게임 시작
  void startGame() {
    if (gameStarted) return;
    gameStarted = true;
    print('Game started: $gameStarted');
    
    // 월드 오프셋 초기화
    _worldYOffset = 0;
    _targetYOffset = 0;
    
    // 모든 공을 활성화
    for (final ball in foodBalls) {
      ball.activate();
    }
    
    // 추적할 공 선택 (첫 번째 공으로 설정)
    if (foodBalls.isNotEmpty) {
      _trackedBall = foodBalls.first;
      print('Tracked ball set: ${_trackedBall?.name}, position: ${_trackedBall?.body.position}');
    } else {
      print('No food balls to track');
    }
  }

  // 게임 리셋
  void resetGame() {
    gameStarted = false;
    finishedBalls.clear();
    
    // 월드 오프셋 초기화
    _worldYOffset = 0;
    _targetYOffset = 0;
    
    // 공 리셋
    for (final ball in foodBalls) {
      ball.reset();
    }
    
    // 추적 대상 재설정
    if (foodBalls.isNotEmpty) {
      _trackedBall = foodBalls.first;
    }
  }
}