import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/utils/format_utils.dart';
import 'package:marshmellow/data/models/finance/transfer_model.dart';
import 'package:marshmellow/presentation/viewmodels/finance/transfer_viewmodel.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/presentation/widgets/keyboard/index.dart';
import 'package:marshmellow/presentation/widgets/loading/loading_manager.dart';
import 'package:marshmellow/router/routes/finance_routes.dart';

class TransferPage extends ConsumerStatefulWidget {
  final String accountNo;
  final int withdrawalAccountId; // 추가된 필드
  
  const TransferPage({
    Key? key,
    required this.accountNo,
    required this.withdrawalAccountId, // 생성자 매개변수 추가
  }) : super(key: key);

  @override
  ConsumerState<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends ConsumerState<TransferPage> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 출금계좌 설정 (임시로 ID는 1로 고정)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transferProvider.notifier).setWithdrawalAccount(widget.withdrawalAccountId, widget.accountNo);
    });
  }

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  // 은행 선택 모달
  void _showBankSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '은행 선택',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: bankList.length,
                  itemBuilder: (context, index) {
                    final bank = bankList[index];
                    return ListTile(
                      leading: SvgPicture.asset(
                        bank.iconPath,
                        width: 30,
                        height: 30,
                      ),
                      title: Text(bank.name),
                      onTap: () {
                        ref.read(transferProvider.notifier).selectBank(
                          bank.code,
                          bank.name,
                        );
                        _bankController.text = bank.name;
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transferProvider);
    final viewModel = ref.read(transferProvider.notifier);

    // 에러 메시지 표시
    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!)),
        );
      });
    }

    return WillPopScope(
      onWillPop: () async {
        viewModel.reset();
        return true;
      },
      child: Scaffold(
        appBar: CustomAppbar(
          title: 'my little 자산',
          backgroundColor: AppColors.background,
        ),
        body: _buildBody(context, state, viewModel),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TransferState state, TransferViewModel viewModel) {
    switch (state.step) {
      case TransferStep.accountInput:
        return _buildAccountInputStep(context, state, viewModel);
      case TransferStep.amountInput:
        return _buildAmountInputStep(context, state, viewModel);
      case TransferStep.loading:
        return const Center(child: CircularProgressIndicator());
      case TransferStep.complete:
        return _buildCompleteStep(context, state, viewModel);
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }

  // 계좌 정보 입력 단계
  Widget _buildAccountInputStep(BuildContext context, TransferState state, TransferViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '입금 계좌 정보 입력',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // 출금계좌 정보 (변경 불가)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '출금계좌',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.accountNo,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // 은행 선택
          TextField(
            controller: _bankController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: '은행 선택',
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
            onTap: () => _showBankSelectionModal(context),
          ),
          const SizedBox(height: 16),
          
          // 계좌번호 입력
          TextField(
            controller: _accountController,
            decoration: const InputDecoration(
              labelText: '계좌번호',
              hintText: '- 없이 입력',
            ),
            keyboardType: TextInputType.number,
            onChanged: viewModel.setDepositAccountNo,
          ),
          
          const Spacer(),
          
          // 다음 버튼
          ElevatedButton(
            onPressed: state.isAccountInputComplete 
              ? viewModel.moveToAmountInput 
              : null,
            child: const Text('다음'),
          ),
        ],
      ),
    );
  }

  // 금액 입력 단계
  Widget _buildAmountInputStep(BuildContext context, TransferState state, TransferViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '보낼 금액 입력',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // 계좌 정보 요약
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('보내는 계좌: ', style: TextStyle(color: Colors.grey)),
                    Text(widget.accountNo),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('받는 계좌: ', style: TextStyle(color: Colors.grey)),
                    Text('${state.selectedBankName} ${state.depositAccountNo}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // 금액 입력 필드
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: '보낼 금액',
              suffixText: '원',
            ),
            readOnly: true,
            onTap: () async {
              await KeyboardModal.showNumericKeyboard(
                context: context,
                onValueChanged: (value) {
                  setState(() {
                    _amountController.text = value;
                    viewModel.setAmount(int.parse(value.replaceAll(',', '')));
                  });
                },
                initialValue: _amountController.text.isEmpty ? '' : _amountController.text,
              );
            },
          ),
          
          const Spacer(),
          
          // 송금 버튼
          ElevatedButton(
            onPressed: state.isAmountValid ? viewModel.executeTransfer : null,
            child: const Text('송금하기'),
          ),
        ],
      ),
    );
  }

  // 송금 완료 단계
  Widget _buildCompleteStep(BuildContext context, TransferState state, TransferViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green,
          ),
          const SizedBox(height: 20),
          const Text(
            '송금이 완료되었습니다',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // 송금 정보 요약
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('송금 정보', style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                const SizedBox(height: 10),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('보낸 계좌'),
                    Text(state.withdrawalAccountNo),
                  ],
                ),
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('받는 계좌'),
                    Text('${state.selectedBankName} ${state.depositAccountNo}'),
                  ],
                ),
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('금액'),
                    Text('${NumberFormat.formatWithComma(state.amount.toString())}원'),
                  ],
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // 확인 버튼
          ElevatedButton(
            onPressed: () {
              viewModel.reset();
              // 계좌 상세 페이지로 이동
              context.go(FinanceRoutes.getDemandDetailPath(state.withdrawalAccountNo));
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}