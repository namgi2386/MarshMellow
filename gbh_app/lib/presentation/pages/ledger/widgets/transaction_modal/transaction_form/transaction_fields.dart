import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/ledger/category/withdrawal_category.dart';
import 'package:marshmellow/data/models/ledger/category/deposit_category.dart';

import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/transaction_field.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/editable_memo_filed.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/picker/date_time_wheel_picker.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/picker/expense_category_picker.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/picker/income_category_picker.dart';

// 지출 카테고리 선택 모달 함수
Future<void> showExpenseCategoryPickerModal(
  BuildContext context, {
  required Function(WithdrawalCategory) onCategorySelected,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ExpenseCategoryPicker(
      onCategorySelected: onCategorySelected,
    ),
  );
}

// 수입 카테고리 선택 모달 함수
Future<void> showIncomeCategoryPickerModal(
  BuildContext context, {
  required Function(DepositCategory) onCategorySelected,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => IncomeCategoryPicker(
      onCategorySelected: onCategorySelected,
    ),
  );
}

// TransactionFields 클래스
class TransactionFields {
  // 날짜 필드
  static TransactionField dateField({
    required DateTime selectedDate,
    required BuildContext context,
    required WidgetRef ref,
    required Function(DateTime) onDateChanged,
    bool includeTime = true, // 시간 포함 여부 옵션
  }) {
    // 날짜 포맷
    String formattedDate =
        '${selectedDate.year}년 ${selectedDate.month.toString().padLeft(2, '0')}월 ${selectedDate.day.toString().padLeft(2, '0')}일';

    // 시간 포함 시 포맷 변경
    if (includeTime) {
      formattedDate +=
          ' ${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}';
    }

    return TransactionField(
      label: includeTime ? '날짜 및 시간' : '날짜',
      trailing: Text(
        formattedDate,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
      onTap: () {
        // 기존 showDateTimePickerModal 대신 새로운 함수 사용
        showDateTimePickerBottomSheet(
          context: context,
          ref: ref,
          initialDateTime: selectedDate,
          onDateTimeChanged: onDateChanged,
          initialMode: CupertinoDatePickerMode.date,
          confirmButtonText: includeTime ? '확인' : '선택',
          nextButtonText: '다음',
        );
      },
    );
  }

  // 지출 카테고리 필드
  static TransactionField expenseCategoryField({
    required BuildContext context,
    String? selectedCategory,
    required Function(WithdrawalCategory) onCategorySelected,
  }) {
    return TransactionField(
      label: '카테고리',
      value: selectedCategory,
      onTap: () {
        showExpenseCategoryPickerModal(
          context,
          onCategorySelected: onCategorySelected,
        );
      },
    );
  }

  // 수입 카테고리 필드
  static TransactionField incomeCategoryField({
    required BuildContext context,
    String? selectedCategory,
    required Function(DepositCategory) onCategorySelected,
  }) {
    return TransactionField(
      label: '카테고리',
      value: selectedCategory,
      onTap: () {
        showIncomeCategoryPickerModal(
          context,
          onCategorySelected: onCategorySelected,
        );
      },
    );
  }

  // 상호명 필드 (일반)
  static TransactionField merchantField({
    String? merchantName,
    VoidCallback? onTap,
  }) {
    return TransactionField(
      label: '상호명',
      value: merchantName,
      onTap: onTap,
    );
  }

  // 상호명 필드 (편집 가능)
  static Widget editableMerchantField({
    String? merchantName,
    required Function(String) onMerchantChanged,
  }) {
    return EditableMemoField(
      label: '상호명',
      initialValue: merchantName,
      onChanged: onMerchantChanged,
    );
  }

  // 메모/키워드 필드 (편집 가능)
  static Widget editableMemoField({
    String? memo,
    required Function(String) onMemoChanged,
  }) {
    return EditableMemoField(
      label: '메모/키워드',
      initialValue: memo,
      onChanged: onMemoChanged,
    );
  }

  // 결제수단 필드
  static TransactionField paymentMethodField({
    String? method,
    VoidCallback? onTap,
  }) {
    return TransactionField(
      label: '결제수단',
      value: method,
      onTap: onTap,
    );
  }

  // 입금계좌 필드
  static TransactionField depositAccountField({
    String? account,
    VoidCallback? onTap,
  }) {
    return TransactionField(
      label: '입금계좌',
      value: account,
      onTap: onTap,
    );
  }

  // 출금계좌 필드
  static TransactionField withdrawalAccountField({
    String? account,
    VoidCallback? onTap,
  }) {
    return TransactionField(
      label: '출금계좌',
      value: account,
      onTap: onTap,
    );
  }

  // 예산에서 제외 필드
  static TransactionField excludeFromBudgetField({
    required bool value,
    required Function(bool) onChanged,
  }) {
    return TransactionField(
      label: '예산에서 제외',
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        thumbColor: AppColors.whiteLight,
        activeColor: AppColors.textPrimary,
      ),
    );
  }

  // 분류 선택기 필드
  static TransactionField typeSelectorField({
    required Widget selector,
  }) {
    return TransactionField(
      label: '분류',
      trailing: SizedBox(
        width: 200,
        child: selector,
      ),
    );
  }
}
