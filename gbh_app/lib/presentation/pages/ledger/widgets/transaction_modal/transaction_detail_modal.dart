import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/ledger/category/transactions.dart';
import 'package:marshmellow/data/models/ledger/category/transaction_category.dart';
import 'package:marshmellow/presentation/viewmodels/ledger/transaction_list_viewmodel.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/transaction_field.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/type_selector.dart';
import 'package:marshmellow/presentation/widgets/button/button.dart';

// 기존 폼들 import
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/expense_form.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/income_form.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/transfer_form.dart';

// 상세 정보 프로바이더 추가
final transactionDetailProvider =
    FutureProvider.family<Transaction, int>((ref, householdPk) async {
  final repository = ref.watch(ledgerRepositoryProvider);
  return repository.getHouseholdDetail(householdPk);
});

class TransactionDetailModal extends ConsumerStatefulWidget {
  final int householdPk;

  const TransactionDetailModal({
    Key? key,
    required this.householdPk,
  }) : super(key: key);

  @override
  ConsumerState<TransactionDetailModal> createState() =>
      _TransactionDetailModalState();
}

class _TransactionDetailModalState
    extends ConsumerState<TransactionDetailModal> {
  String _selectedType = '지출';

  @override
  Widget build(BuildContext context) {
    final transactionDetailAsync =
        ref.watch(transactionDetailProvider(widget.householdPk));
    final numberFormat = NumberFormat('#,###', 'ko_KR');

    return transactionDetailAsync.when(
      data: (transaction) {
        // 트랜잭션 타입에 따라 선택된 타입 업데이트
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String typeText = '지출';
          switch (transaction.type) {
            case TransactionType.deposit:
              typeText = '수입';
              break;
            case TransactionType.withdrawal:
              typeText = '지출';
              break;
            case TransactionType.transfer:
              typeText = '이체';
              break;
          }

          if (_selectedType != typeText) {
            setState(() {
              _selectedType = typeText;
            });
          }
        });
        return Stack(
          children: [
            // 콘텐츠 영역
            Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 금액 표시
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '${numberFormat.format(transaction.amount)}',
                            style: AppTextStyles.modalMoneyTitle.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            ' 원',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),

                    // 분류 선택기
                    TransactionField(
                      label: '분류',
                      trailing: SizedBox(
                        width: 200,
                        child: TypeSelector(
                          selectedType: _selectedType,
                          onTypeSelected: (type) {
                            setState(() {
                              _selectedType = type;
                            });
                          },
                        ),
                      ),
                    ),

                    // 선택된 타입에 따른 폼 표시 (기존 폼 사용)
                    _getFormByType(transaction),
                  ],
                ),
              ),
            ),

            // 하단 고정 버튼
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Button(
                    text: '수정',
                    width:
                        MediaQuery.of(context).size.width * 0.43, // 화면 너비의 43%

                    onPressed: () {
                      print('네 선택됨');
                    },
                  ),
                  const SizedBox(width: 10), // 버튼 사이 간격
                  Button(
                    text: '삭제',
                    width:
                        MediaQuery.of(context).size.width * 0.43, // 화면 너비의 43%
                    onPressed: () {
                      print('아니오 선택됨');
                    },
                  ),
                ],
              )),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('상세 정보를 불러오는 중 오류가 발생했습니다: $error'),
      ),
    );
  }

  Widget _getFormByType(Transaction transaction) {
    switch (_selectedType) {
      case '수입':
        return IncomeForm(initialData: transaction);
      case '지출':
        return ExpenseForm(initialData: transaction);
      case '이체':
        return TransferForm(initialData: transaction);
      default:
        return ExpenseForm(initialData: transaction);
    }
  }
}
