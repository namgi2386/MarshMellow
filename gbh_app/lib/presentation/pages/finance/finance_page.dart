// presentation/pages/finance/finance_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/utils/lifecycle/app_lifecycle_manager.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/router/routes/finance_routes.dart';
import 'package:marshmellow/presentation/viewmodels/finance/finance_viewmodel.dart';

// 분리한 위젯들 import
import 'package:marshmellow/presentation/pages/finance/widgets/account_item_widget.dart';
import 'package:marshmellow/presentation/pages/finance/widgets/card_item_widget.dart';
import 'package:marshmellow/presentation/pages/finance/widgets/financial_section_widget.dart';
import 'package:marshmellow/presentation/pages/finance/widgets/total_assets_widget.dart';

// appbar 간편버튼
import 'package:marshmellow/presentation/pages/finance/widgets/simple_toggle_button_widget.dart';


class FinancePage extends ConsumerWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 라이프사이클 상태 구독
    final lifecycleState = ref.watch(lifecycleStateProvider);

    // 뷰모델에서 데이터 가져오기
    final assetData = ref.watch(assetDataProvider);

    return Scaffold(
      backgroundColor: Colors.tealAccent,
      appBar: CustomAppbar(
        title: 'my little 자산',
        actions: [
          const SimpleToggleButton(), // 분리한 커스텀 토글 버튼 위젯
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // 테스트 페이지로 이동
            ElevatedButton(
              onPressed: () {
                context.push(FinanceRoutes.getTestPath()); 
              },
              child: const Text('테스트 페이지로 이동'),
            ),
            // 간편 모드 상태 확인 텍스트
            Consumer(
              builder: (context, ref, child) {
                final isSimpleMode = ref.watch(simpleViewModeProvider);
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  color: isSimpleMode ? Colors.black12 : Colors.white70,
                  child: Center(
                    child: Text(
                      '현재 모드: ${isSimpleMode ? "간편 모드" : "일반 모드"}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSimpleMode ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
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
                        TotalAssetsWidget(totalAssets: totalAssets),
                        
                        const SizedBox(height: 16),
                        
                        // 입출금 계좌 정보
                        FinancialSectionWidget(
                          title: '입출금',
                          totalAmount: data.data.demandDepositData.totalAmount,
                          isEmpty: data.data.demandDepositData.demandDepositList.isEmpty,
                          emptyMessage: '등록된 입출금 계좌가 없습니다.',
                          itemList: data.data.demandDepositData.demandDepositList
                              .map((account) => AccountItemWidget(
                                    bankName: account.bankName,
                                    accountName: account.accountName,
                                    accountNo: account.accountNo,
                                    balance: account.accountBalance,
                                  ))
                              .toList(),
                        ),
                        
                        // 카드 정보
                        FinancialSectionWidget(
                          title: '카드',
                          totalAmount: data.data.cardData.totalAmount,
                          isEmpty: data.data.cardData.cardList.isEmpty,
                          emptyMessage: '등록된 카드가 없습니다.',
                          itemList: data.data.cardData.cardList
                              .map((card) => CardItemWidget(card: card))
                              .toList(),
                        ),
                        
                        // 예금 정보
                        FinancialSectionWidget(
                          title: '예금',
                          totalAmount: data.data.depositData.totalAmount,
                          isEmpty: data.data.depositData.depositList.isEmpty,
                          emptyMessage: '등록된 예금이 없습니다.',
                          itemList: data.data.depositData.depositList
                              .map((account) => AccountItemWidget(
                                    bankName: account.bankName,
                                    accountName: account.accountName,
                                    accountNo: account.accountNo,
                                    balance: account.depositBalance,
                                  ))
                              .toList(),
                        ),
                        
                        // 적금 정보
                        FinancialSectionWidget(
                          title: '적금',
                          totalAmount: data.data.savingsData.totalAmount,
                          isEmpty: data.data.savingsData.savingsList.isEmpty,
                          emptyMessage: '등록된 적금이 없습니다.',
                          itemList: data.data.savingsData.savingsList
                              .map((account) => AccountItemWidget(
                                    bankName: account.bankName,
                                    accountName: account.accountName,
                                    accountNo: account.accountNo,
                                    balance: account.totalBalance,
                                  ))
                              .toList(),
                        ),
                        
                        // 대출 정보
                        FinancialSectionWidget(
                          title: '대출',
                          totalAmount: data.data.loanData.totalAmount,
                          isEmpty: data.data.loanData.loanList.isEmpty,
                          emptyMessage: '등록된 대출이 없습니다.',
                          itemList: data.data.loanData.loanList
                              .map((loan) => AccountItemWidget(
                                    bankName: '-', // 은행명 정보 없음
                                    accountName: loan.accountName,
                                    accountNo: loan.accountNo,
                                    balance: loan.loanBalance,
                                    isLoan: true,
                                  ))
                              .toList(),
                        ),
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
}