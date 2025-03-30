import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/data/models/ledger/category/withdrawal_category.dart';

import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/transaction_fields.dart';
import 'package:marshmellow/presentation/viewmodels/ledger/transaction_list_viewmodel.dart';
import 'package:marshmellow/data/models/ledger/category/transactions.dart';

class ExpenseForm extends ConsumerStatefulWidget {
  final Transaction? initialData; // 초기 데이터 추가
  final DateTime? initialDate; // 초기 날짜
  const ExpenseForm({super.key, this.initialData, this.initialDate});

  @override
  ConsumerState<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<ExpenseForm> {
  bool _isExcludedFromBudget = false;
  DateTime _selectedDate = DateTime.now();
  WithdrawalCategory? _selectedExpenseCategory; // ExpenseCategory 타입으로 변경
  String? _merchant;
  String? _paymentMethod;
  String? _memo;

  @override
  void initState() {
    super.initState();
    // 초기 날짜 설정 (우선순위: initialData > initialDate > 현재 날짜)
    if (widget.initialData != null) {
      final transaction = widget.initialData!;
      final categoryRepository = ref.read(ledgerRepositoryProvider);

      // 트랜잭션 데이터로 폼 초기화
      _selectedDate = transaction.dateTime;
      _merchant = transaction.tradeName;
      _paymentMethod = transaction.paymentMethod;
      _memo = transaction.householdMemo;
      _isExcludedFromBudget = transaction.exceptedBudgetYn == 'Y';

      // 카테고리 설정
      _selectedExpenseCategory = categoryRepository
          .getWithdrawalCategoryByName(transaction.householdCategory);
    } else {
      // initialDate가 있으면 그 날짜를 사용, 없으면 현재 날짜 사용
      _selectedDate = widget.initialDate ?? DateTime.now();
    }
  }

  // 날짜 업데이트 함수
  void _updateDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  // 메모 업데이트 함수
  void _updateMemo(String value) {
    setState(() {
      _memo = value;
    });
  }

  // 상호명 업데이트 함수
  void _updateMerchant(String value) {
    setState(() {
      _merchant = value;
    });
  }

  // 예산에서 제외 여부 업데이트 함수
  void _updateExcludeFromBudget(bool value) {
    setState(() {
      _isExcludedFromBudget = value;
    });
  }

  // 카테고리 업데이트 함수
  void _updateExpenseCategory(WithdrawalCategory category) {
    setState(() {
      _selectedExpenseCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 카테고리 필드
        TransactionFields.expenseCategoryField(
          context: context,
          selectedCategory: _selectedExpenseCategory?.name,
          onCategorySelected: _updateExpenseCategory,
        ),
        // 상호명 필드
        TransactionFields.editableMerchantField(
          merchantName: _merchant,
          onMerchantChanged: _updateMerchant,
        ),
        // 결제수단 필드
        TransactionFields.paymentMethodField(
          method: _paymentMethod,
          onTap: () {
            // 결제수단 선택 다이얼로그 표시
          },
        ),
        // 날짜 필드
        TransactionFields.dateField(
          context: context,
          ref: ref,
          selectedDate: _selectedDate,
          onDateChanged: _updateDate,
        ),
        // 메모 필드
        TransactionFields.editableMemoField(
          memo: _memo,
          onMemoChanged: _updateMemo,
        ),
        // 예산에서 제외 필드
        TransactionFields.excludeFromBudgetField(
          value: _isExcludedFromBudget,
          onChanged: _updateExcludeFromBudget,
        ),
      ],
    );
  }
}
