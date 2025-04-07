// lib/presentation/pages/budget/budget_type/budget_type_selection_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/data/models/budget/budget_type_model.dart';
import 'package:marshmellow/presentation/viewmodels/budget/budget_type_viewmodel.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/presentation/widgets/button/button.dart';
import 'package:marshmellow/presentation/widgets/loading/custom_loading_indicator.dart';

class BudgetTypeSelectionPage extends ConsumerWidget {
  const BudgetTypeSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetTypeProvider);
    final viewModel = ref.read(budgetTypeProvider.notifier);
    
    // 로딩 중이거나 분석 결과가 없는 경우 로딩 표시
    if (state.isLoading || state.analysisResult == null) {
      return Scaffold(
        appBar: CustomAppbar(title: '예산 유형 선택'),
        body: const Center(
          child: CustomLoadingIndicator(),
        ),
      );
    }

    // 모든 유형 정보 가져오기
    final allTypeInfos = BudgetTypeInfo.getAllTypeInfos();

    return Scaffold(
      appBar: CustomAppbar(
        title: '예산 유형 선택',
        actions: [
          // 도움말 아이콘
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    '이달의 소비 유형을 선택하시면\n자동 예산 분배 해드릴게요!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  // 유형 선택 그리드
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: allTypeInfos.length,
                      itemBuilder: (context, index) {
                        final typeInfo = allTypeInfos[index];
                        final isSelected = state.selectedType == typeInfo.type;
                        
                        return _buildTypeCard(
                          context,
                          typeInfo,
                          isSelected,
                          () => viewModel.selectBudgetType(typeInfo.type),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 하단 버튼
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Button(
              text: '선택 완료',
              isLoading: state.isSavingSelection,
              onPressed: state.selectedType == null
                  ? null // 선택이 없으면 비활성화
                  : () async {
                      final success = await viewModel.saveSelectedType();
                      if (success && context.mounted) {
                        // 성공 시 이전 화면으로 돌아가기
                        context.pop();
                        
                        // 선택 완료 메시지
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('예산 유형이 설정되었습니다'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }

  // 유형 카드 위젯
  Widget _buildTypeCard(
    BuildContext context,
    BudgetTypeInfo typeInfo,
    bool isSelected,
    VoidCallback onSelect,
  ) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? typeInfo.color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: typeInfo.color.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 선택 표시
            if (isSelected)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: typeInfo.color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            
            // 아이콘 이미지 (실제 앱에서는 적절한 이미지 경로로 변경 필요)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: typeInfo.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconForType(typeInfo.type),
                color: typeInfo.color,
                size: 32,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 유형 이름
            Text(
              typeInfo.selectionName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // 간단한 설명 (맛보기)
            Text(
              _getShortDescription(typeInfo.type),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // 유형별 아이콘 반환
  IconData _getIconForType(String type) {
    switch (type) {
      case '식비/외식':
        return Icons.restaurant;
      case '교통/자동차':
        return Icons.directions_car;
      case '편의점/마트':
        return Icons.shopping_basket;
      case '금융':
        return Icons.account_balance;
      case '여가비':
        return Icons.movie;
      case '커피/디저트':
        return Icons.local_cafe;
      case '쇼핑':
        return Icons.shopping_bag;
      case '비상금':
        return Icons.savings;
      case '평균':
        return Icons.balance;
      default:
        return Icons.category;
    }
  }

  // 유형별 짧은 설명
  String _getShortDescription(String type) {
    switch (type) {
      case '식비/외식':
        return '맛있는 음식에 투자하는 미식가';
      case '교통/자동차':
        return '효율적인 이동이 중요한 바쁜 일상';
      case '편의점/마트':
        return '생활에 필요한 것은 다 있다';
      case '금융':
        return '미래를 준비하는 투자자';
      case '여가비':
        return '문화생활로 삶의 질을 높이는 방법';
      case '커피/디저트':
        return '달콤한 휴식과 함께하는 여유';
      case '쇼핑':
        return '나를 위한 투자와 보상';
      case '비상금':
        return '언제 어디서나 준비되어 있는 여유';
      case '평균':
        return '균형 잡힌 지출로 합리적인 소비';
      default:
        return '나만의 소비 스타일';
    }
  }

  // 도움말 다이얼로그
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예산 유형이란?'),
        content: const SingleChildScrollView(
          child: Text(
            '예산 유형은 당신의 소비 패턴을 분석하여 가장 잘 맞는 예산 배분 방식을 추천해드립니다.\n\n'
            '각 유형별로 카테고리 간 예산 비율이 다르게 설정되어, 당신의 생활 패턴에 맞는 예산 계획을 자동으로 생성해 드립니다.\n\n'
            '선택한 유형은 언제든지 변경 가능합니다.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}