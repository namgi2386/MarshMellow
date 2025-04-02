import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'base_body.dart';
import 'food_ball.dart';

class FinishLine extends BaseBody {
  final Vector2 size;
  final Function(FoodBall ball) onBallCrossed;
  final List<FoodBall> _crossedBalls = [];
  
  FinishLine({
    required Vector2 position,
    required this.size,
    required this.onBallCrossed,
    Color color = Colors.green,
  }) : super(position: position, color: color);

  @override
  Body createBody() {
    // 결승선은 움직이지 않는 정적 바디로 생성
    final bodyDef = BodyDef(
      position: position,
      type: BodyType.static,
    );

    // 바디 생성
    final body = world.createBody(bodyDef);

    // 사각형 모양의 픽스처 생성
    final shape = PolygonShape()
      ..setAsBox(
        size.x / 2, // 너비의 절반
        size.y / 2, // 높이의 절반
        Vector2(0, 0), // 중심점
        0, // 회전각도
      );

    // 픽스처 속성 설정 - 센서로 설정하여 물리적 충돌 없이 통과 감지만
    final fixtureDef = FixtureDef(shape)
      ..isSensor = true; // 센서로 설정하여 통과 가능하게

    // 바디에 픽스처 추가
    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    // 결승선 시각적으로 그리기
    final rect = Rect.fromCenter(
      center: Offset(0, 0),
      width: size.x,
      height: size.y,
    );

    // 체크무늬 패턴 그리기
    final paint = Paint()..color = color;
    canvas.drawRect(rect, paint);
    
    // 체크무늬 효과
    final squareSize = size.y / 4;
    final checkPaint = Paint()..color = Colors.black;
    
    for (int i = 0; i < size.x / squareSize; i++) {
      for (int j = 0; j < 2; j++) {
        if ((i + j) % 2 == 0) continue;
        
        canvas.drawRect(
          Rect.fromLTWH(
            -size.x / 2 + i * squareSize,
            -size.y / 2 + j * squareSize * 2,
            squareSize,
            squareSize
          ),
          checkPaint
        );
      }
    }
    
    super.render(canvas);
  }
  
  // 충돌 감지 시 호출되는 메서드
  void beginContact(Object other) {
    if (other is FoodBall && !_crossedBalls.contains(other)) {
      _crossedBalls.add(other);
      onBallCrossed(other);
    }
  }
}