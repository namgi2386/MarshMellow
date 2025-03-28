import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/ledger/category/transaction_category.dart';
import 'package:marshmellow/presentation/viewmodels/ledger/transaction_list_viewmodel.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_item.dart';

class LedgerTransactionHistory extends ConsumerStatefulWidget {
  const LedgerTransactionHistory({super.key});

  @override
  ConsumerState<LedgerTransactionHistory> createState() =>
      _LedgerTransactionHistoryState();
}

class _LedgerTransactionHistoryState
    extends ConsumerState<LedgerTransactionHistory> {
  final _numberFormat = NumberFormat('#,###', 'ko_KR');

  @override
  Widget build(BuildContext context) {
    // 트랜잭션 데이터 구독
    final transactionsAsync = ref.watch(transactionsProvider);

    return transactionsAsync.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(
            child: Text('기록이 없습니다.'),
          );
        }

        // 트랜잭션을 날짜별로 그룹화
        final repository = ref.watch(transactionRepositoryProvider);
        final grouped = repository.groupTransactionsByDate(transactions);

        // 날짜 목록을 내림차순으로 정렬 (최신순)
        final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: dates.length,
          itemBuilder: (context, index) {
            final date = dates[index];
            final items = grouped[date]!;

            // 해당 날짜의 수입/지출 합계
            double dayIncome = 0;
            double dayExpense = 0;

            for (var item in items) {
              if (item.type == TransactionType.deposit) {
                dayIncome += item.amount;
              } else {
                dayExpense += item.amount;
              }
            }

            // 요일 이름 (월요일, 화요일, ...)
            final dayNames = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
            final dayName = dayNames[date.weekday - 1];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 날짜 헤더
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    children: [
                      Text(
                        '${date.month}월 ${date.day}일 $dayName',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w300,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      // 수입 합계
                      if (dayIncome > 0)
                        Text(
                          '+ ${_numberFormat.format(dayIncome)}원',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.blueDark,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      const SizedBox(width: 10),
                      // 지출 합계
                      if (dayExpense > 0)
                        Text(
                          '- ${_numberFormat.format(dayExpense)}원',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
                // 날짜 바로 아래에 Divider 추가
                const Divider(height: 1, thickness: 0.5),

                // 해당 날짜의 거래 목록
                const SizedBox(height: 10),
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TransactionListItem(
                        transaction: item,
                        // onTap: () {},
                        onDelete: (transaction) {
                          // 삭제 로직 추가
                          // ref.read(transactionRepositoryProvider).deleteTransaction(transaction.id);
                        },
                      ),
                    )),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('오류가 발생했습니다: $error'),
      ),
    );
  }
}
