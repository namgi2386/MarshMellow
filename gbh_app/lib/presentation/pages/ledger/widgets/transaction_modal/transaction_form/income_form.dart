import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/transaction_fields.dart';
import 'package:marshmellow/data/models/ledger/category/deposit_category.dart';
import 'package:marshmellow/data/models/ledger/category/transactions.dart';
import 'package:marshmellow/presentation/viewmodels/ledger/transaction_list_viewmodel.dart';

class IncomeForm extends ConsumerStatefulWidget {
  final Transaction? initialData; // 초기 데이터 추가
  final DateTime? initialDate; // 초기 날짜
  final Function(int? amount, String? memo)? onDataChanged; // 콜백 함수 추가
  final bool readOnly; // 읽기 전용 모드

  const IncomeForm({
    super.key,
    this.initialData,
    this.initialDate,
    this.onDataChanged,
    this.readOnly = false,
  });

  @override
  ConsumerState<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends ConsumerState<IncomeForm> {
  DateTime _selectedDate = DateTime.now();
  String? _merchant;
  String? _memo;
  DepositCategory? _selectedIncomeCategory;
  String? _depositAccount;
  int? _amount;

  @override
  void initState() {
    super.initState();
    // 초기 데이터가 있으면 설정 (우선순위: initialData > initialDate > 현재 날짜)
    if (widget.initialData != null) {
      final transaction = widget.initialData!;
      final categoryRepository = ref.read(ledgerRepositoryProvider);

      // 트랜잭션 데이터로 폼 초기화
      _selectedDate = transaction.dateTime;
      _merchant = transaction.tradeName;
      _depositAccount =
          transaction.paymentMethod; // paymentMethod를 depositAccount로 사용
      _memo = transaction.householdMemo;
      _amount = transaction.householdAmount;

      // 카테고리 설정
      _selectedIncomeCategory = categoryRepository.getDepositCategoryByName(
          transaction.householdCategory); // 수입 카테고리로 변경
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

  // 카테고리 업데이트 함수
  void _updateIncomeCategory(DepositCategory category) {
    setState(() {
      _selectedIncomeCategory = category;
    });
  }

  // 입금 계좌 업데이트 함수
  void _updateDepositAccount(String value) {
    setState(() {
      _depositAccount = value;
    });
  }

  // 데이터 변경을 알리는 함수 추가
  void _notifyDataChanged() {
    if (widget.onDataChanged != null) {
      widget.onDataChanged!(_amount, _memo);
    }
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
            enabled: !widget.readOnly,
          ),
          // 상호명 필드
          TransactionFields.editableMerchantField(
            merchantName: _merchant,
            onMerchantChanged: _updateMerchant,
            enabled: !widget.readOnly,
          ),
          // 입금 계좌 필드
          TransactionFields.depositAccountField(
            account: _depositAccount,
            onTap: () {
              // 입금 계좌 선택 로직 구현
            },
            enabled: !widget.readOnly,
          ),
          // 날짜 필드
          TransactionFields.dateField(
            context: context,
            ref: ref,
            selectedDate: _selectedDate,
            onDateChanged: _updateDate,
            enabled: !widget.readOnly,
          ),
          // 메모 필드
          TransactionFields.editableMemoField(
            memo: _memo,
            onMemoChanged: _updateMemo,
            enabled: true, // 메모는 항상 수정 가능
          ),
        ],
      ),
    );
  }
}
