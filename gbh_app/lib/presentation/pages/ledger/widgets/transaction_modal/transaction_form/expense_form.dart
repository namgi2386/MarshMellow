import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/data/models/ledger/expense_category.dart';

import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/transaction_fields.dart';

class ExpenseForm extends ConsumerStatefulWidget {
  const ExpenseForm({super.key});

  @override
  ConsumerState<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<ExpenseForm> {
  bool _isExcludedFromBudget = false;
  DateTime _selectedDate = DateTime.now();
  ExpenseCategory? _selectedExpenseCategory; // ExpenseCategory 타입으로 변경
  String? _merchant;
  String? _paymentMethod;
  String? _memo;

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
  void _updateExpenseCategory(ExpenseCategory category) {
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
