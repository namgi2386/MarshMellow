import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/transaction_field.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/transaction_fields.dart';
import 'package:marshmellow/data/models/ledger/category/transfer_category.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/picker/transfer_direction_picker.dart';
import 'package:marshmellow/data/models/ledger/category/transactions.dart';
import 'package:marshmellow/presentation/viewmodels/ledger/transaction_list_viewmodel.dart';

class TransferForm extends ConsumerStatefulWidget {
  final Transaction? initialData; // 초기 데이터 추가
  final DateTime? initialDate; // 초기 날짜
  const TransferForm({super.key, this.initialData, this.initialDate});

  @override
  ConsumerState<TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends ConsumerState<TransferForm> {
  DateTime _selectedDate = DateTime.now();
  String? _merchant;
  String? _memo;
  TransferCategory? _selectedTransferCategory;
  TransferDirection? _transferDirection;
  String? _account;

  @override
  void initState() {
    super.initState();
    // 초기 데이터가 있으면 설정
    if (widget.initialData != null) {
      final transaction = widget.initialData!;
      final categoryRepository = ref.read(ledgerRepositoryProvider);

      // 트랜잭션 데이터로 폼 초기화
      _selectedDate = transaction.dateTime;
      _merchant = transaction.tradeName;
      _memo = transaction.householdMemo;
      _account = transaction.paymentMethod;

      // 카테고리 설정
      _selectedTransferCategory = categoryRepository
          .getTransferCategoryByName(transaction.householdCategory);

      // 트랜잭션 방향 설정 - 기본적으로 출금으로 설정하고, 필요하면 수정
      _transferDirection = TransferDirection.withdrawal;
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

  // 이체 방향 및 카테고리 업데이트 함수
  void _updateTransferInfo(
      TransferDirection direction, TransferCategory category) {
    setState(() {
      _transferDirection = direction;
      _selectedTransferCategory = category;
    });
  }

  // 계좌 업데이트 함수
  void _updateAccount(String value) {
    setState(() {
      _account = value;
    });
  }

  // 카테고리 선택 모달 표시
  void _showCategorySelectionModal() async {
    final result = await showTransferDirectionPickerModal(context);
    if (result != null) {
      _updateTransferInfo(result['direction'], result['category']);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 카테고리 표시 텍스트
    String categoryDisplayText = '';
    if (_transferDirection != null && _selectedTransferCategory != null) {
      String directionText =
          _transferDirection == TransferDirection.deposit ? '입금' : '출금';
      categoryDisplayText =
          '$directionText > ${_selectedTransferCategory!.name}';
    }

    return Column(
      children: [
        // 카테고리 필드
        TransactionField(
          label: '카테고리',
          value: categoryDisplayText,
          onTap: _showCategorySelectionModal,
        ),

        // 상호명 필드
        TransactionFields.editableMerchantField(
          merchantName: _merchant,
          onMerchantChanged: _updateMerchant,
        ),

        // 계좌 필드
        TransactionField(
          label: '계좌',
          value: _account,
          onTap: () {
            // 계좌 선택 로직 구현
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
    );
  }
}
