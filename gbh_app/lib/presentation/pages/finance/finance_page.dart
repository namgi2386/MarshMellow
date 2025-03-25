import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/core/utils/lifecycle/app_lifecycle_manager.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/router/routes/finance_routes.dart';

// 뷰모델 import
import 'package:marshmellow/presentation/viewmodels/finance/finance_viewmodel.dart';
import 'package:marshmellow/data/models/finance/asset_response_model.dart';
import 'package:marshmellow/data/models/finance/card_model.dart';
import 'package:marshmellow/data/models/finance/account_models.dart';
import 'package:intl/intl.dart'; // 숫자 포맷팅용 패키지 (추가 필요)

class FinancePage extends ConsumerWidget {
  const FinancePage({super.key});

  // 숫자 포맷팅 함수 (천 단위 구분)
  String formatAmount(int amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 라이프사이클 상태 구독
    final lifecycleState = ref.watch(lifecycleStateProvider);

    // 뷰모델에서 데이터 가져오기
    final assetData = ref.watch(assetDataProvider);

    return Scaffold(
      appBar: CustomAppbar(
        title: '자산',
        actions: [
          IconButton(
            icon: const Icon(Icons.stacked_bar_chart_rounded),
            onPressed: () {
              // 추가할 기능
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 테스트 페이지로 이동
                context.push(FinanceRoutes.getTestPath());
              },
              child: const Text('테스트 페이지로 이동'),
            ),
            
            Expanded(
              child: assetData.when(
                data: (data) {
                  // 성공적으로 데이터를 받았을 때
                  final financeViewModel = ref.read(financeViewModelProvider);
                  final totalAssets = financeViewModel.calculateTotalAssets(data.data);
                  
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 총 자산 정보
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '총 자산',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${formatAmount(totalAssets)}원',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        // 입출금 계좌 정보
                        _buildSectionTitle('입출금'),
                        _buildDemandDepositList(data.data.demandDepositData),
                        
                        const SizedBox(height: 16),
                        // 카드 정보
                        _buildSectionTitle('카드'),
                        _buildCardList(data.data.cardData),
                        
                        const SizedBox(height: 16),
                        // 예금 정보
                        _buildSectionTitle('예금'),
                        _buildDepositList(data.data.depositData),
                        
                        const SizedBox(height: 16),
                        // 적금 정보
                        _buildSectionTitle('적금'),
                        _buildSavingsList(data.data.savingsData),
                        
                        const SizedBox(height: 24),
                        // 대출 정보
                        _buildSectionTitle('대출'),
                        _buildLoanList(data.data.loanData),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) {
                  // 에러 발생 시
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 10),
                      Text('에러 발생: $error'),
                      ElevatedButton(
                        onPressed: () => ref.refresh(assetDataProvider),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 섹션 제목 위젯
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 카드 목록 위젯
  Widget _buildCardList(CardData cardData) {
    if (cardData.cardList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16.0),
        child: Text('등록된 카드가 없습니다.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('총액: ${formatAmount(cardData.totalAmount)}원'),
        const SizedBox(height: 8),
        ...cardData.cardList.map((card) => _buildCardItem(card)),
      ],
    );
  }

  // 카드 아이템 위젯
  Widget _buildCardItem(CardItem card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.cardName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('카드번호: ${_maskCardNumber(card.cardNo)}'),
          Text('발급사: ${card.cardIssuerName}'),
          Text('잔액: ${formatAmount(card.cardBalance)}원'),
        ],
      ),
    );
  }

  // 입출금 계좌 목록 위젯
  Widget _buildDemandDepositList(DemandDepositData data) {
    if (data.demandDepositList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16.0),
        child: Text('등록된 입출금 계좌가 없습니다.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('총액: ${formatAmount(data.totalAmount)}원'),
        const SizedBox(height: 8),
        ...data.demandDepositList.map((account) => _buildAccountItem(
          account.bankName,
          account.accountName,
          account.accountNo,
          account.accountBalance,
        )),
      ],
    );
  }

  // 적금 목록 위젯
  Widget _buildSavingsList(SavingsData data) {
    if (data.savingsList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16.0),
        child: Text('등록된 적금이 없습니다.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('총액: ${formatAmount(data.totalAmount)}원'),
        const SizedBox(height: 8),
        ...data.savingsList.map((account) => _buildAccountItem(
          account.bankName,
          account.accountName,
          account.accountNo,
          account.totalBalance,
        )),
      ],
    );
  }

  // 예금 목록 위젯
  Widget _buildDepositList(DepositData data) {
    if (data.depositList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16.0),
        child: Text('등록된 예금이 없습니다.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('총액: ${formatAmount(data.totalAmount)}원'),
        const SizedBox(height: 8),
        ...data.depositList.map((account) => _buildAccountItem(
          account.bankName,
          account.accountName,
          account.accountNo,
          account.depositBalance,
        )),
      ],
    );
  }

  // 대출 목록 위젯
  Widget _buildLoanList(LoanData data) {
    if (data.loanList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16.0),
        child: Text('등록된 대출이 없습니다.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('총액: ${formatAmount(data.totalAmount)}원'),
        const SizedBox(height: 8),
        ...data.loanList.map((loan) => _buildAccountItem(
          '-', // 은행명 정보 없음
          loan.accountName,
          loan.accountNo,
          loan.loanBalance,
          isLoan: true,
        )),
      ],
    );
  }

  // 계좌 아이템 위젯 (입출금, 적금, 예금, 대출에서 공통으로 사용)
  Widget _buildAccountItem(String bankName, String accountName, String accountNo, int balance, {bool isLoan = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            accountName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (bankName != '-') Text('은행: $bankName'),
          Text('계좌번호: ${_maskAccountNumber(accountNo)}'),
          Text(
            '${isLoan ? '대출금액' : '잔액'}: ${formatAmount(balance)}원',
            style: TextStyle(
              color: isLoan ? Colors.red : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 카드번호 마스킹 함수
  String _maskCardNumber(String cardNo) {
    if (cardNo.length < 8) return cardNo;
    return '${cardNo.substring(0, 4)} **** **** ${cardNo.substring(cardNo.length - 4)}';
  }

  // 계좌번호 마스킹 함수
  String _maskAccountNumber(String accountNo) {
    if (accountNo.length < 6) return accountNo;
    return '${accountNo.substring(0, 3)}****${accountNo.substring(accountNo.length - 4)}';
  }
}