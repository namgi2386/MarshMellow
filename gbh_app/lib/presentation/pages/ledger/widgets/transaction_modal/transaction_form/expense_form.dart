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
  final Function(int? amount, String? memo, String? exceptedBudgetYn)?
      onDataChanged; // 콜백 함수 추가
  final bool readOnly; // 읽기 전용 모드

  const ExpenseForm({
    super.key,
    this.initialData,
    this.initialDate,
    this.onDataChanged,
    this.readOnly = false,
  });

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
  int? _amount;

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
      _amount = transaction.householdAmount;

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
    _notifyDataChanged();
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
    _notifyDataChanged();
  }

  // 카테고리 업데이트 함수
  void _updateExpenseCategory(WithdrawalCategory category) {
    setState(() {
      _selectedExpenseCategory = category;
    });
  }

  // 데이터 변경을 알리는 함수 추가
  void _notifyDataChanged() {
    if (widget.onDataChanged != null) {
      widget.onDataChanged!(_amount, _memo, _isExcludedFromBudget ? 'Y' : 'N');
    }
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
          enabled: !widget.readOnly, // 비활성화 여부
        ),
        // 상호명 필드
        TransactionFields.editableMerchantField(
          merchantName: _merchant,
          onMerchantChanged: _updateMerchant,
          enabled: !widget.readOnly, // 비활성화 여부
        ),
        // 결제수단 필드
        TransactionFields.paymentMethodField(
          method: _paymentMethod,
          onTap: () {
            // 결제수단 선택 다이얼로그 표시
          },
          enabled: !widget.readOnly, // 비활성화 여부
        ),
        // 날짜 필드
        TransactionFields.dateField(
          context: context,
          ref: ref,
          selectedDate: _selectedDate,
          onDateChanged: _updateDate,
          enabled: !widget.readOnly, // 비활성화 여부
        ),
        // 메모 필드
        TransactionFields.editableMemoField(
          memo: _memo,
          onMemoChanged: _updateMemo,
          enabled: true, // 메모는 항상 수정 가능
        ),
        // 예산에서 제외 필드
        TransactionFields.excludeFromBudgetField(
          value: _isExcludedFromBudget,
          onChanged: _updateExcludeFromBudget,
          enabled: true, // 예산 제외는 항상 수정 가능
        ),
      ],
    );
  }
}
