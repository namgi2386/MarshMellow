import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/ledger/transactions.dart';
import 'package:marshmellow/data/models/ledger/transaction_category.dart';
import 'package:marshmellow/data/models/ledger/expense_category.dart';
import 'package:marshmellow/data/models/ledger/income_category.dart';
import 'package:marshmellow/presentation/viewmodels/ledger/transaction_list_viewmodel.dart';

class TransactionListItem extends ConsumerWidget {
  final Transaction transaction;
  final Function(Transaction)? onDelete;
  final SlidableController? controller;

  const TransactionListItem(
      {Key? key, required this.transaction, this.onDelete, this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryRepository = ref.watch(transactionCategoryRepositoryProvider);
    final numberFormat = NumberFormat('#,###', 'ko_KR');

    String iconPath = '';
    if (transaction.type == TransactionType.expense) {
      final category = categoryRepository.getExpenseCategoryById(
          transaction.categoryId as ExpenseCategoryType);
      iconPath = category?.iconPath ?? '';
    } else {
      final category = categoryRepository
          .getIncomeCategoryById(transaction.categoryId as IncomeCategoryType);
      iconPath = category?.iconPath ?? '';
    }

    // Slidable 위젯으로 감싸기
    return Slidable(
      key: ValueKey(transaction.id),
      // 컨트롤러 연결
      controller: controller,

      // 왼쪽에서 오른쪽으로만 스와이프 가능하도록 설정
      endActionPane: ActionPane(
        // 첫 번째 스와이프에서는 부분적으로 열리고, 두 번째 스와이프에서 완전히 열리도록 설정
        motion: const ScrollMotion(),
        extentRatio: 0.2,
        dismissible: DismissiblePane(
          key: ValueKey('dismiss-${transaction.id}'), // 고유한 키 추가
          // 완전히 스와이프 했을 때 (두 번째 단계)
          onDismissed: () {
            if (onDelete != null) {
              onDelete!(transaction);
            }
          },
          // 부분 스와이프에서 완전 스와이프로 넘어가는 기준 (0.5는 50%)
          closeOnCancel: true,
          confirmDismiss: () async {
            // 확인 없이 삭제
            return true;
          },
        ),
        // 부분 스와이프에서 표시할 액션 버튼들
        children: [
          CustomSlidableAction(
            onPressed: (context) {
              if (onDelete != null) {
                onDelete!(transaction);
              }
            },
            backgroundColor: AppColors.warnning,
            flex: 1,
            child: Icon(
              Icons.delete,
              color: AppColors.background, // 직접 아이콘 색상 지정
            ),
          ),
        ],
      ),

      // 원래 컨텐츠 (변경 없음)
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            // 카테고리 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.whiteLight,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.textLight.withOpacity(0.2)),
              ),
              child: iconPath.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        iconPath,
                        width: 40,
                        height: 40,
                      ),
                    )
                  : const Icon(Icons.help_outline, size: 24),
            ),
            const SizedBox(width: 12),

            // 거래 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${transaction.accountName ?? ''} | ${transaction.paymentMethod ?? ''}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),

            // 금액
            Text(
              transaction.type == TransactionType.expense
                  ? '- ${numberFormat.format(transaction.amount)}원'
                  : '+ ${numberFormat.format(transaction.amount)}원',
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 16,
                color: transaction.type == TransactionType.expense
                    ? AppColors.textPrimary
                    : AppColors.blueDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
