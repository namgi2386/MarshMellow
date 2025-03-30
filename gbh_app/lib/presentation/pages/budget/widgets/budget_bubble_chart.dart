import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/data/models/budget/budget_model.dart';

class BudgetBubblechart extends ConsumerStatefulWidget {
  final List<BudgetCategory> categories;
  final double maxRadius;
  final double padding;

  const BudgetBubblechart({
    Key? key,
    required this.categories,
    this.maxRadius = 120.0,
    this.padding = 10.0,
  }) : super(key: key);

  @override
  ConsumerState<BudgetBubblechart> createState() => _BudgetBubblechartState();
}

class _BudgetBubblechartState extends ConsumerState<BudgetBubblechart> {
  // Accelerometer data
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  
  // Maximum tilt angles (in radians)
  final double _maxTiltAngle = 0.5;
  
  @override
  void initState() {
    super.initState();
    // Listen to accelerometer events
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (mounted) {
        setState(() {
          // X축은 좌우 기울기 Y축은 앞뒤 기울기
          _tiltX = (event.x / 9.8).clamp(-_maxTiltAngle, _maxTiltAngle);
          _tiltY = (event.y / 9.8).clamp(-_maxTiltAngle, _maxTiltAngle);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) {
      return const Center(
        child: Text(
          '등록된 예산 카테고리가 없습니다',
          style: TextStyle(fontSize: 16, color: AppColors.greyPrimary),
        ),
      );
    }

    // 전체 예산 합계 계산
    int totalBudget = widget.categories.fold(
        0, (sum, category) => sum + category.budgetCategoryPrice);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: RepaintBoundary(
            child: CustomPaint(
              painter: BubblesPainter(
                budgetCategories: widget.categories,
                totalBudget: totalBudget,
                maxRadius: widget.maxRadius,
                padding: widget.padding,
                containerSize: math.min(constraints.maxWidth, constraints.maxHeight),
                tiltX: _tiltX,
                tiltY: _tiltY,
              ),
            ),
          ),
        );
      },
    );
  }
}

class BubblesPainter extends CustomPainter {
  final List<BudgetCategory> budgetCategories;
  final int totalBudget;
  final double maxRadius;
  final double padding;
  final double containerSize;
  final double tiltX;
  final double tiltY;

  BubblesPainter({
    required this.budgetCategories,
    required this.totalBudget,
    required this.maxRadius,
    required this.padding,
    required this.containerSize,
    required this.tiltX,
    required this.tiltY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 정렬된 예산 항목 (큰 금액부터 작은 금액 순으로)
    final sortedCategories = List<BudgetCategory>.from(budgetCategories)
      ..sort((a, b) => b.budgetCategoryPrice.compareTo(a.budgetCategoryPrice));

    // 상위 6개 카테고리만 사용
    final topCategories = sortedCategories.take(6).toList();

    // 원의 위치와 크기를 저장하는 리스트
    final List<Bubble> bubbles = [];
    
    // 총 예산이 0일 경우 그리지 않음
    if (totalBudget <= 0) return;

    // 화면 중앙점
    final center = Offset(size.width / 2, size.height / 2);

    for (final category in topCategories) {
      // 예산 비율에 따른 반지름 계산
      final ratio = category.budgetCategoryPrice / totalBudget;
      final radius = math.min(maxRadius * math.sqrt(ratio) * 1.38, maxRadius);
      
      // 원의 크기가 너무 작으면 스킵
      if (radius < 10) continue;

      // 새 버블 생성
      final bubble = Bubble(
        category: category,
        radius: radius,
        position: Offset.zero, // 임시 위치
      );
      
      // 버블 배치
      placeBubble(bubble, bubbles, center, size);
      
      // 위치한 버블 저장
      bubbles.add(bubble);
    }

    // 버블 위치 최적화
    optimizeBubblePositions(bubbles, size);

    // 모든 버블 그리기
    for (final bubble in bubbles) {
      drawBubble(canvas, bubble);
    }
  }

  // 버블 위치 최적화 
  void optimizeBubblePositions(List<Bubble> bubbles, Size size) {
    // 반복 횟수
    int iterations = 12;
    
    // 버블 간 힘과 중앙 힘 조정
    double repulsionForce = 5.8;
    double centerForce = 0.00001;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // 초기 위치를 원형으로 배치
    if (bubbles.length > 1) {
      double angleStep = (math.pi * 2) / bubbles.length;
      double radius = size.width * 0.3;
      
      for (int i = 0; i < bubbles.length; i++) {
        double angle = i * angleStep;
        bubbles[i].position = Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius
        );
      }
    } else if (bubbles.length == 1) {
      // 하나만 있으면 중앙에 배치
      bubbles[0].position = center;
    }
    
    // 간단한 최적화 수행
    for (int i = 0; i < iterations; i++) {
      for (int j = 0; j < bubbles.length; j++) {
        Bubble bubble = bubbles[j];
        Offset force = Offset.zero;
        
        // 다른 버블과 충돌 검사
        for (int k = 0; k < bubbles.length; k++) {
          if (j == k) continue;
          
          Bubble other = bubbles[k];
          Offset direction = bubble.position - other.position;
          double distance = direction.distance;
          
          double minDist = bubble.radius + other.radius + padding;
          
          // 충돌시 밀어내기
          if (distance < minDist) {
            Offset norm = direction / (distance == 0 ? 1 : distance);
            force += norm * repulsionForce;
          }
        }
        
        // 중앙으로 끌어당기기
        Offset toCenter = center - bubble.position;
        double centerDistance = toCenter.distance;
        if (centerDistance > 0) {
          force += toCenter / centerDistance * centerForce * centerDistance;
        }
        
        // 화면 밖으로 나가지 않도록
        if (bubble.position.dx - bubble.radius < 0) {
          force += Offset(repulsionForce, 0);
        }
        if (bubble.position.dx + bubble.radius > size.width) {
          force -= Offset(repulsionForce, 0);
        }
        if (bubble.position.dy - bubble.radius < 0) {
          force += Offset(0, repulsionForce);
        }
        if (bubble.position.dy + bubble.radius > size.height) {
          force -= Offset(0, repulsionForce);
        }
        
        // 버블 위치 업데이트
        bubble.position += force;
      }
    }
    
    // 최종적으로 모든 버블이 화면 안에 있도록 보정
    for (Bubble bubble in bubbles) {
      bubble.position = Offset(
        bubble.position.dx.clamp(bubble.radius, size.width - bubble.radius),
        bubble.position.dy.clamp(bubble.radius, size.height - bubble.radius)
      );
    }
  }

  // 버블 그리기
  void drawBubble(Canvas canvas, Bubble bubble) {
    final category = bubble.category;
    final position = bubble.position;
    final radius = bubble.radius;
    
    // 카테고리 색상으로 원 그리기
    final categoryPaint = Paint()
      ..color = category.color
      ..style = PaintingStyle.fill;
    
    // 전체 원 그리기 (베이스 색상)
    canvas.drawCircle(position, radius, categoryPaint);
    
    // 사용 비율 및 초과 여부
    final spentPercent = category.usageRatio;
    final isOverBudget = category.isOverBudget;
    
    // 지출 비율이 있는 경우
    if (spentPercent > 0) {
      // 검정색 영역 그리기
      final fillPaint = Paint()
        ..color = AppColors.backgroundBlack
        ..style = PaintingStyle.fill;
      
      if (isOverBudget) {
        // 초과 지출은 전체 원을 검정색으로
        canvas.drawCircle(position, radius, fillPaint);
      } else {
        // 기울기에 따른 "액체 표면" 계산
        // 기본 높이 계산 (원의 바닥에서부터 비율만큼 채워짐)
        final filledHeight = 2 * radius * spentPercent;
        final baseHeight = position.dy + radius - filledHeight;
        
        // 기울기를 액체 표면 기울기로 변환
        final surfaceTiltX = tiltX * 2.0;  // 기울기 효과 증폭
        // final surfaceTiltY = tiltY * 1.5;
        
        // 기울어진 액체 표면의 경로
        final clipPath = Path()..addOval(Rect.fromCircle(center: position, radius: radius));
        
        // 액체 표면 그리기
        canvas.save();
        canvas.clipPath(clipPath);
        
        // 액체 표면의 4개 꼭지점 계산
        final leftOffset = surfaceTiltX * radius;
        final rightOffset = -surfaceTiltX * radius;
        
        // 기울어진 액체 표면의 경로
        final liquidPath = Path()
          ..moveTo(position.dx - radius, position.dy + radius)  // 좌하단
          ..lineTo(position.dx - radius, baseHeight + leftOffset)  // 좌상단
          ..lineTo(position.dx + radius, baseHeight + rightOffset)  // 우상단
          ..lineTo(position.dx + radius, position.dy + radius)  // 우하단
          ..close();
        
        canvas.drawPath(liquidPath, fillPaint);
        canvas.restore();
      }
    }
    
    // 카테고리 텍스트 그리기
    final fontSize = math.max(radius * 0.3, 12.0);
    
    final textStyle = AppTextStyles.bodyMediumLight.copyWith(
      color: isOverBudget ? AppColors.buttonDelete : AppColors.whiteLight,
      fontSize: fontSize,
    );
    
    final textSpan = TextSpan(
      text: category.budgetCategoryName,
      style: textStyle,
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    
    // 원 중앙에 텍스트 배치
    final textX = position.dx - textPainter.width / 2;
    final textY = position.dy - textPainter.height / 2;
    
    textPainter.paint(canvas, Offset(textX, textY));
  }

  // 버블 배치
  void placeBubble(Bubble bubble, List<Bubble> placedBubbles, Offset center, Size size) {
    if (placedBubbles.isEmpty) {
      // 첫 번째 버블은 화면 중앙에 배치
      bubble.position = center;
      return;
    }

    // 나선형으로 다른 버블들을 피해 배치
    double angle = 0;
    double distance = bubble.radius + placedBubbles.first.radius + padding;
    double step = 0.2;
    int maxAttempts = 100; // 줄임

    while (maxAttempts > 0) {
      double x = center.dx + math.cos(angle) * distance;
      double y = center.dy + math.sin(angle) * distance;
      
      Offset newPosition = Offset(x, y);
      
      // 화면 밖으로 나가는지 확인
      if (x - bubble.radius < 0 || x + bubble.radius > size.width ||
          y - bubble.radius < 0 || y + bubble.radius > size.height) {
        angle += step;
        if (angle > math.pi * 2) {
          angle = 0;
          distance += bubble.radius * 0.5;
        }
        maxAttempts--;
        continue;
      }
      
      // 다른 버블과 겹치는지 확인
      bool overlaps = false;
      for (final placed in placedBubbles) {
        double minDistance = bubble.radius + placed.radius + padding;
        double actualDistance = (newPosition - placed.position).distance;
        
        if (actualDistance < minDistance) {
          overlaps = true;
          break;
        }
      }
      
      if (!overlaps) {
        bubble.position = newPosition;
        return;
      }
      
      angle += step;
      if (angle > math.pi * 2) {
        angle = 0;
        distance += bubble.radius * 0.3;
      }
      
      maxAttempts--;
    }
    
    // 위치를 찾지 못한 경우 랜덤 위치 설정
    final random = math.Random();
    double x = bubble.radius + random.nextDouble() * (size.width - 2 * bubble.radius);
    double y = bubble.radius + random.nextDouble() * (size.height - 2 * bubble.radius);
    
    bubble.position = Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is BubblesPainter) {
      return oldDelegate.tiltX != tiltX || 
             oldDelegate.tiltY != tiltY ||
             oldDelegate.budgetCategories != budgetCategories;
    }
    return true;
  }
}

// 버블 클래스
class Bubble {
  final BudgetCategory category;
  final double radius;
  Offset position;

  Bubble({
    required this.category,
    required this.radius,
    required this.position,
  });
}