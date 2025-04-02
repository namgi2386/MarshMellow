import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'base_body.dart';

class FoodBall extends BaseBody {
  final double radius;
  final String name;
  final String imagePath;
  bool _activated = false;

  FoodBall({
    required Vector2 position,
    required this.radius,
    required this.name,
    required this.imagePath,
    Color color = Colors.red,
  }) : super(position: position, color: color);
  // 공 활성화 메서드
  void activate() {
    if (!_activated) {
      _activated = true;
      // 바디 타입을 동적으로 변경하여 중력 영향을 받도록 함
      body.setType(BodyType.dynamic);
    }
  }
  @override
  Body createBody() {
    // 동적(움직이는) 바디 정의
    final bodyDef = BodyDef(
      position: position, 
      type: BodyType.static, // 중력과 힘의 영향을 받음
      userData: this, // 이 객체 참조 저장 (충돌 감지에 사용)
    );

    // 바디 생성
    final body = world.createBody(bodyDef);

    // 원형 모양 정의
    final shape = CircleShape()..radius = radius;

    // 픽스처 속성 설정
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.8 // 높은 반발력
      ..density = 1.0     // 밀도
      ..friction = 0.2;   // 약간의 마찰력

    // 바디에 픽스처 추가
    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    // 공 시각적으로 그리기
    canvas.drawCircle(
      Offset.zero, // 중심은 항상 (0,0)
      radius,      // 반지름
      Paint()..color = color,
    );
    
    // 나중에 여기에 이미지 그리기 추가 가능
    
    super.render(canvas);
  }
  // FoodBall 클래스에 update 메서드 추가
  // @override
  // void update(double dt) {
  //   super.update(dt);
  //   if (_activated && body.position.y > 70) {
  //     // 공이 특정 위치 아래로 내려갔을 때 로그
  //     print('Ball ${name} passed y=70, position: ${body.position.y}');
  //   }
  // }
}