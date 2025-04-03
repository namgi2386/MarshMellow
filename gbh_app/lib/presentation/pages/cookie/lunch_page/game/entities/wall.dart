import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'base_body.dart';

class Wall extends BaseBody {
  final Vector2 size;

  Wall({
    required Vector2 position,
    required this.size,
    Color color = Colors.brown,
  }) : super(position: position, color: color);

  @override
  Body createBody() {
    // 벽은 움직이지 않는 정적 바디로 생성
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

    // 픽스처 속성 설정
    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.1 // 낮은 반발력
      ..friction = 0.5;   // 높은 마찰력

    // 바디에 픽스처 추가
    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    // 벽 시각적으로 그리기
    final rect = Rect.fromCenter(
      center: Offset(0, 0),
      width: size.x,
      height: size.y,
    );

    canvas.drawRect(
      rect,
      Paint()..color = color,
    );
  }
}