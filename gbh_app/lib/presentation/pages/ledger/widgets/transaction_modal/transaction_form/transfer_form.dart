import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/transaction_fields.dart';
import 'package:marshmellow/data/models/ledger/income_category.dart';

class TransferForm extends ConsumerStatefulWidget {
  const TransferForm({super.key});

  @override
  ConsumerState<TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends ConsumerState<TransferForm> {
  DateTime _selectedDate = DateTime.now();
  String? _merchant;
  String? _memo;
  IncomeCategory? _selectedIncomeCategory;
  String? _depositAccount;
  String? _withdrawalAccount; // 출금계좌 변수 추가

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

  // 카테고리 업데이트 함수
  void _updateIncomeCategory(IncomeCategory category) {
    setState(() {
      _selectedIncomeCategory = category;
    });
  }

  // 출금 계좌 업데이트 함수
  void _updateWithdrawalAccount(String value) {
    setState(() {
      _withdrawalAccount = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          // 카테고리 필드
          TransactionFields.incomeCategoryField(
            context: context,
            selectedCategory: _selectedIncomeCategory?.name,
            onCategorySelected: _updateIncomeCategory,
          ),
          // 상호명 필드
          TransactionFields.editableMerchantField(
            merchantName: _merchant,
            onMerchantChanged: _updateMerchant,
          ),
          // 출금 계좌 필드
          TransactionFields.withdrawalAccountField(
            account: _withdrawalAccount,
            onTap: () {
              // 출금 계좌 선택 로직 구현
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
        ],
      ),
    );
  }
}
