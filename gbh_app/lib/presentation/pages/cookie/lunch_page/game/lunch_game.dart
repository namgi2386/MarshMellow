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
  final List selectedMenus;
  bool gameStarted = false;
  final List<FoodBall> foodBalls = [];
  final List<FoodBall> finishedBalls = [];
  Function(List<FoodBall>)? onGameComplete;

  LunchGame({required this.selectedMenus}) : super(gravity: Vector2(0, 10.0)) {
    print('World initialized: ${world != null}');
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 실제 디바이스 화면 크기에 맞게 설정
    final screenSize = size; // 게임 위젯의 실제 크기 (디바이스 해상도 반영)
    camera.viewport = FixedResolutionViewport(resolution: screenSize);
    final worldSize = screenSize; // 월드 크기를 화면 크기에 맞춤

    // 디버깅 로그 추가
    print('Screen size: $screenSize, World size: $worldSize');

    // 카메라 위치와 줌 설정 (최신 API 사용)
    camera.viewfinder.position = worldSize / 2; // 화면 중앙으로 이동
    camera.viewfinder.zoom = 1.0; // 기본 줌 (필요하면 조정)

    // 경계(벽과 바닥) 추가
    _addBoundaries(worldSize);
    
    // 장애물 추가
    _addObstacles(worldSize);
    
    // 결승선 추가\
    _addFinishLine(worldSize);
    
    // 공 추가 (아직 떨어지지 않게 대기)
    _addFoodBalls(worldSize);
    
  }

  // 충돌 감지를 위한 메서드
  @override
  void beginContact(Object objectA, Contact contact) {
    print('beginContact called'); // 최소한 호출 여부 확인
    final bodyA = contact.fixtureA.body;
    final bodyB = contact.fixtureB.body;

    final userDataA = bodyA.userData;
    final userDataB = bodyB.userData;
    print('just text');
    print('Collision detected: A=$userDataA, B=$userDataB'); // 타입뿐만 아니라 객체 자체 출력
    // print('BodyA type: ${bodyA.type}, BodyB type: ${bodyB.type}'); // 바디 타입 확인

    if (userDataA is FinishLine && userDataB is FoodBall) {
      print('FinishLine detected with FoodBall: ${userDataB.name}');
      userDataA.beginContact(userDataB);
    } else if (userDataA is FoodBall && userDataB is FinishLine) {
      print('FoodBall detected with FinishLine: ${userDataA.name}');
      userDataB.beginContact(userDataA);
    }
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
        worldSize.x * 0.3 , 
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
    final finishLineHeight = worldSize.y * 0.05; // 높이 5%로 증가
    final finishLineY = worldSize.y * 0.9; // 바닥에 더 가까이 (90%)
    print('Adding finish line at y: $finishLineY, height: $finishLineHeight');
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
  


}