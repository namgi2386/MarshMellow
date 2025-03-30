import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/ledger/category/transactions.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_item.dart';
import 'package:marshmellow/presentation/widgets/modal/modal.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/transaction_form.dart';

class DailyTransactionsContent extends ConsumerWidget {
  final DateTime date;
  final List<Transaction> transactions;

  const DailyTransactionsContent({
    Key? key,
    required this.date,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 요일 이름 배열 및 날짜 포맷
    final dayNames = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    final dayName = dayNames[date.weekday - 1];
    final dateString = '${date.month}월 ${date.day}일 $dayName';

    // 숫자 포맷터
    final numberFormat = NumberFormat('#,###', 'ko_KR');

    // 수입/지출 합계 계산
    int income = 0;
    int expense = 0;

    for (var transaction in transactions) {
      if (transaction.classification == TransactionClassification.DEPOSIT) {
        income += transaction.householdAmount;
      } else if (transaction.classification ==
          TransactionClassification.WITHDRAWAL) {
        expense += transaction.householdAmount;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜 정보
        Text(
          dateString,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),

        // 총 건수 및 수입/지출 정보
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '총 ${transactions.length}건',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            if (income > 0)
              Text(
                '+ ${numberFormat.format(income)}원',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.blueDark,
                ),
              ),
            const SizedBox(width: 12),
            if (expense > 0)
              Text(
                '- ${numberFormat.format(expense)}원',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
          ],
        ),

        // 구분선
        const SizedBox(height: 12),
        const Divider(height: 1, thickness: 0.5, color: AppColors.textLight),

        // 트랜잭션 목록 또는 빈 상태
        Flexible(
          child: transactions.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/characters/char_melong.png',
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '기록이 없습니다.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  // 트랜잭션 목록 + 내역 추가 항목
                  itemCount: transactions.length + 1,
                  itemBuilder: (context, index) {
                    // 마지막 항목은 "내역 추가" 버튼
                    if (index == transactions.length) {
                      return GestureDetector(
                        onTap: () {
                          // 내역 추가 화면으로 이동 또는 추가 모달 표시
                          Navigator.of(context).pop(); // 현재 모달 닫기
                          // 트랜잭션 추가 모달 표시
                          showCustomModal(
                            context: context,
                            ref: ref,
                            backgroundColor: AppColors.background,
                            child: TransactionForm(
                              initialDate: date, // 선택한 날짜를 전달
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.whiteLight,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.textLight.withOpacity(0.3),
                                  ),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '내역 추가',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final transaction = transactions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TransactionListItem(
                        transaction: transaction,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// 트랜잭션 모달을 표시하는 함수
void showDailyTransactionsModal({
  required BuildContext context,
  required WidgetRef ref,
  required DateTime date,
  required List<Transaction> transactions,
}) {
  showCustomModal(
    context: context,
    ref: ref,
    backgroundColor: AppColors.background,
    padding: const EdgeInsets.all(20),
    maxHeight: MediaQuery.of(context).size.height * 0.7,
    child: DailyTransactionsContent(
      date: date,
      transactions: transactions,
    ),
  );
}
