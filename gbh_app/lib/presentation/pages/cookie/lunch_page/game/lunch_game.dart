import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'entities/floor.dart';
import 'entities/food_ball.dart';
import 'entities/wall.dart';
import 'entities/finish_line.dart';

// Forge2D 게임 확장하는 기본 게임 클래스
class LunchGame extends Forge2DGame with ContactCallbacks {
  // 선택된 메뉴 정보
  final List selectedMenus;
  bool gameStarted = false;
  final List<FoodBall> foodBalls = [];
  final List<FoodBall> finishedBalls = [];
  
  // 결과 콜백 함수
  Function(List<FoodBall>)? onGameComplete;
  
  // 생성자에서 중력 설정 (기본 지구 중력)
  LunchGame({required this.selectedMenus}) 
    : super(gravity: Vector2(0, 10.0));
  
  @override
  Future<void> onLoad() async {
    // 카메라 설정 (화면에 맞게)
    camera.viewport = FixedResolutionViewport(resolution: Vector2(1080, 1920));
    
    // 화면 크기 계산
    final viewportSize = camera.viewport.size;
    final worldSize = screenToWorld(Vector2(viewportSize.x, viewportSize.y));
    
    // 경계(벽과 바닥) 추가
    _addBoundaries(worldSize);
    
    // 장애물 추가
    _addObstacles(worldSize);
    
    // 결승선 추가
    _addFinishLine(worldSize);
    
    // 공 추가 (아직 떨어지지 않게 대기)
    _addFoodBalls(worldSize);
    
    await super.onLoad();
  }

  // 경계 추가 메서드
  void _addBoundaries(Vector2 worldSize) {
    // 기존 코드 그대로 유지
    final wallThickness = worldSize.x * 0.04; // 화면 너비의 2%
    final floorHeight = worldSize.y * 0.05; // 화면 높이의 5%
    
    // 바닥 추가
    add(Floor(
      position: Vector2(worldSize.x / 2, worldSize.y - floorHeight / 2),
      size: Vector2(worldSize.x, floorHeight),
      color: Colors.blueGrey.shade700,
    ));
    
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
  
  // 장애물 추가 메서드 (기존 코드 유지)
  void _addObstacles(Vector2 worldSize) {
    // 기존 코드 그대로 유지
    final random = math.Random();
    final obstacleWidth = worldSize.x * 0.15; // 화면 너비의 15%
    final obstacleHeight = worldSize.y * 0.04; // 화면 높이의 2%
    
    // 첫 번째 장애물 (왼쪽에서 오른쪽으로)
    add(Wall(
      position: Vector2(
        worldSize.x * 0.3, 
        worldSize.y * 0.3
      ),
      size: Vector2(obstacleWidth, obstacleHeight),
      color: Colors.grey.shade800,
    ));
    
    // 두 번째 장애물 (오른쪽에서 왼쪽으로)
    add(Wall(
      position: Vector2(
        worldSize.x * 0.7, 
        worldSize.y * 0.5
      ),
      size: Vector2(obstacleWidth, obstacleHeight),
      color: Colors.grey.shade800,
    ));
    
    // 세 번째 장애물 (왼쪽에서 오른쪽으로)
    add(Wall(
      position: Vector2(
        worldSize.x * 0.4, 
        worldSize.y * 0.7
      ),
      size: Vector2(obstacleWidth, obstacleHeight),
      color: Colors.grey.shade800,
    ));
  }
  
  // 결승선 추가 메서드
  void _addFinishLine(Vector2 worldSize) {
    final finishLineHeight = worldSize.y * 0.02; // 화면 높이의 2%
    final finishLineY = worldSize.y * 0.7; // 바닥 바로 위
    print('Adding finish line at y: $finishLineY (world height: ${worldSize.y})'); // 로그 추가
    final finishLine = FinishLine(
      position: Vector2(worldSize.x / 2, finishLineY),
      size: Vector2(worldSize.x * 0.8, finishLineHeight),
      color: Colors.green.shade600,
      onBallCrossed: _onBallFinished,
    );
    
    add(finishLine);
    print('FinishLine added: ${finishLine.hashCode}');
  }
  
  // 음식 공 추가 메서드 (기존 코드 유지)
  void _addFoodBalls(Vector2 worldSize) {
    // 기존 코드 그대로 유지
    if (selectedMenus.isEmpty) return;
    
    final ballRadius = worldSize.x * 0.05; // 화면 너비의 5%
    final startY = ballRadius * 2; // 시작 높이
    
    // 선택된 메뉴 개수에 따라 공의 위치 조정
    final menuCount = selectedMenus.length;
    final spacing = worldSize.x / (menuCount + 1);
    
    // 각 메뉴에 대한 공 생성
    for (int i = 0; i < menuCount; i++) {
      final menu = selectedMenus[i];
      final xPos = spacing * (i + 1); // 균등하게 분배
      
      // 공 색상 랜덤 지정 (나중에 메뉴에 따라 색상 지정 가능)
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
        color: color,
      );
      
      foodBalls.add(foodBall);
      add(foodBall);
    }
  }
  
  // 공이 결승선 통과 시 호출되는 콜백
  void _onBallFinished(FoodBall ball) {
    print('Ball finished: ${ball.name}, Position: ${finishedBalls.length}'); // 로그 추가
    if (!finishedBalls.contains(ball)) {
      finishedBalls.add(ball);
      
      // 모든 공이 도착했거나 처음 3개 공이 도착하면 게임 종료
      if (finishedBalls.length >= foodBalls.length || 
          finishedBalls.length >= 3) {
        print('Game finishing with ${finishedBalls.length} balls'); // 로그 추가
        _finishGame();
      }
    }
  }
  
  // 게임 종료 처리
  void _finishGame() {
    print('Finish game called, onGameComplete is ${onGameComplete != null ? 'set' : 'null'}'); // 로그 추가
    if (onGameComplete != null) {
      onGameComplete!(finishedBalls);
    }
  }

  @override
  void render(Canvas canvas) {
    // 배경 그리기
    canvas.drawColor(Colors.lightBlue.shade100, BlendMode.src);
    super.render(canvas);
  }
  
  // 게임 시작 메서드 (수정된 코드)
  void startGame() {
    if (gameStarted) return;
    gameStarted = true;
    
    // 모든 공을 활성화
    for (final ball in foodBalls) {
      ball.activate();
    }
  }
  
  // 게임 리셋 메서드
  void resetGame() {
    gameStarted = false;
    finishedBalls.clear();
    
    // 기존 공들은 원래 위치로 돌아가고 정적 상태로 변경
    for (final ball in foodBalls) {
      // 원래 위치로 재설정하는 로직은 복잡하므로 
      // 별도로 구현 필요 (여기서는 생략)
    }
  }
  
  // 충돌 감지를 위한 메서드
  @override
  void beginContact(Object objectA, Contact contact) {
    final fixtureA = contact.fixtureA;
    final fixtureB = contact.fixtureB;
    
    final bodyA = fixtureA.body; // 코드에서는 objectA가 이미 첫 번째 파라미터로 전달되어 사용되기 때문에 bodyA를 통해 userData를 가져올 필요가 없는 상황
    final bodyB = fixtureB.body;
    
    // 각 바디의 userdata 가져오기
    final objectB = bodyB.userData;
    
    // 결승선과 공의 충돌 처리
    if (objectA is FinishLine && objectB is FoodBall) {
      objectA.beginContact(objectB);
    } else if (objectA is FoodBall && objectB is FinishLine) {
      objectB.beginContact(objectA);
    }
  }
}