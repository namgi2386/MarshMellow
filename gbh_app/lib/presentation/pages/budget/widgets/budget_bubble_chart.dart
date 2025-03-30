import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'dart:math' as math;
import 'package:marshmellow/data/models/budget/budget_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BudgetBubblechart extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    if (categories.isEmpty) {
      return const Center(
        child: Text(
          '등록된 예산 카테고리가 없습니다',
          style: TextStyle(fontSize: 16, color: AppColors.greyPrimary),
        ),
      );
    }

    // 전체 예산 합계 계산
    int totalBudget = categories.fold(0, (sum, category) => sum + category.budgetCategoryPrice);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: CustomPaint(
            painter: BubblesPainter(
              budgetCategories: categories,
              totalBudget: totalBudget,
              maxRadius: maxRadius,
              padding: padding,
              containerSize: math.min(constraints.maxWidth, constraints.maxHeight),
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

  BubblesPainter({
    required this.budgetCategories,
    required this.totalBudget,
    required this.maxRadius,
    required this.padding,
    required this.containerSize,
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

  // 버블 위치 최적화 *이곳을 수정합니다!
  void optimizeBubblePositions(List<Bubble> bubbles, Size size) {
    // 반복 횟수
    int iterations = 200;
    
    // 반발력 및 중력 상수
    double repulsionForce = 3.2;
    double centerForce = 0.00004;
    
    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < iterations; i++) {
      // 각 버블에 대해 반복
      for (int j = 0; j < bubbles.length; j++) {
        Bubble bubble = bubbles[j];
        Offset force = Offset.zero;
        
        // 다른 모든 버블과의 상호작용을 계산
        for (int k = 0; k < bubbles.length; k++) {
          if (j == k) continue;  // 자기 자신은 건너뛰기
          
          Bubble other = bubbles[k];
          Offset direction = bubble.position - other.position;
          double distance = direction.distance;
          
          // 최소 거리 (두 원의 반지름 합)
          double minDist = bubble.radius + other.radius + padding;
          
          // 충돌 방지 (너무 가까우면 밀어내기)
          if (distance < minDist) {
            // 방향 단위 벡터 계산
            Offset norm = direction / (distance == 0 ? 1 : distance);
            
            // 밀어내는 힘 계산
            double pushForce = repulsionForce * (minDist - distance) / minDist;
            force += norm * pushForce;
          }
        }
        
        // 화면 중앙으로 끌어당기는 힘
        Offset centerDirection = center - bubble.position;
        double centerDistance = centerDirection.distance;
        if (centerDistance > 0) {
          force += centerDirection / centerDistance * centerForce * centerDistance;
        }
        
        // 화면 경계 체크
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
        ..color = Colors.black.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      
      if (isOverBudget) {
        // 초과 지출은 전체 원을 검정색으로
        canvas.drawCircle(position, radius, fillPaint);
      } else {
        // 사용 비율에 맞게 원의 아래쪽부터 채우기
        // 원의 바닥에서부터 사용 비율만큼 채워짐
        final filledHeight = 2 * radius * spentPercent;
        
        // 채울 영역 계산 (원의 바닥부터 시작)
        final startY = position.dy + radius - filledHeight;
        
        // 채울 직사각형 영역
        final rect = Rect.fromLTRB(
          position.dx - radius,
          startY,
          position.dx + radius,
          position.dy + radius
        );
        
        // 원 모양 클리핑
        canvas.save();
        canvas.clipPath(Path()..addOval(Rect.fromCircle(center: position, radius: radius)));
        canvas.drawRect(rect, fillPaint);
        canvas.restore();
      }
    }
    
    // 지출 금액 표시
    final amount = formatNumber(category.budgetExpendAmount ?? 0);
    final fontSize = math.max(radius * 0.3, 12.0);
    
    final textStyle = AppTextStyles.bodyMediumLight.copyWith(
      color: isOverBudget ? AppColors.buttonDelete : AppColors.whiteLight,
      fontSize: fontSize,
    );
    
    // final textSpan = TextSpan(
    //   text: amount,
    //   style: textStyle,
    // );

    // 카테고리 텍스트 그리기
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
    int maxAttempts = 500;

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

  // 숫자 포맷팅 (천 단위 쉼표)
  String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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