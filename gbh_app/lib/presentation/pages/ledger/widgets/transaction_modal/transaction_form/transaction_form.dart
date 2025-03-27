import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/constants/icon_path.dart';

// 폼
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/transaction_field.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/type_selector.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/income_form.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/expense_form.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/transfer_form.dart';

// 위젯
import 'package:marshmellow/presentation/widgets/button/button.dart';
import 'package:marshmellow/presentation/widgets/keyboard/calculator_keyboard.dart';

class TransactionForm extends StatefulWidget {
  const TransactionForm({super.key});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  String _selectedType = '지출'; // 기본값을 지출로 설정
  String _amount = '0'; // 금액 상태 추가

  // 선택된 타입에 따라 다른 폼을 반환하는 메서드
  Widget _getFormByType() {
    switch (_selectedType) {
      case '수입':
        return const IncomeForm();
      case '지출':
        return const ExpenseForm();
      case '이체':
        return const TransferForm();
      default:
        return const ExpenseForm();
    }
  }

  // 금액을 포맷팅하는 메서드
  String _formatAmount(String amount) {
    // 숫자만 추출
    String numbers = amount.replaceAll(RegExp(r'[^0-9]'), '');
    if (numbers.isEmpty) return '0';

    // 3자리마다 콤마 추가
    final formatted = int.parse(numbers)
        .toString()
        .split('')
        .reversed
        .join('')
        .replaceAllMapped(
          RegExp(r'.{3}'),
          (match) => '${match.group(0)},',
        )
        .split('')
        .reversed
        .join('')
        .replaceAll(RegExp(r'^,'), '');

    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        // 콘텐츠 영역
        Padding(
          padding: const EdgeInsets.only(bottom: 70), // 하단 버튼 높이만큼 패딩 추가
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        _formatAmount(_amount),
                        style: AppTextStyles.modalMoneyTitle,
                      ),
                      Text(
                        ' 원',
                        style: AppTextStyles.bodyMedium,
                      ),
                      IconButton(
                        onPressed: () {
                          // 금액 입력 계산기 키보드 열기
                          // CalculatorKeyboard.show(
                          //   context,
                          //   initialValue: _amount,
                          //   onValueChanged: (value) {
                          //     setState(() {
                          //       _amount = value;
                          //     });
                            // },
                          // );
                        },
                        icon: SvgPicture.asset(IconPath.pencilSimple),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
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
                // 선택된 타입에 따른 폼 표시
                _getFormByType(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),

        // 하단 고정 버튼
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Button(
              height: 50,
              width: screenWidth * 0.9,
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}
