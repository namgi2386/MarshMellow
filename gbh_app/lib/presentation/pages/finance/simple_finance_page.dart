// presentation/pages/finance/finance_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/config/app_config.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/presentation/pages/finance/widgets/simple/real_wallet_widget.dart';
// import 'package:marshmellow/core/utils/lifecycle/app_lifecycle_manager.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/presentation/widgets/loading/loading_manager.dart';
import 'package:marshmellow/router/routes/finance_routes.dart';
import 'package:marshmellow/presentation/viewmodels/finance/finance_viewmodel.dart';

// 분리한 위젯들 import
import 'package:marshmellow/presentation/pages/finance/widgets/account_item_widget.dart';
import 'package:marshmellow/presentation/pages/finance/widgets/card_item_widget.dart';
import 'package:marshmellow/presentation/pages/finance/widgets/financial_section_widget.dart';
import 'package:marshmellow/presentation/pages/finance/widgets/total_assets_widget.dart';

// appbar 간편버튼
import 'package:marshmellow/presentation/pages/finance/widgets/simple_toggle_button_widget.dart';


class SimpleFinancePage extends ConsumerWidget {
  const SimpleFinancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 라이프사이클 상태 구독
    // final lifecycleState = ref.watch(lifecycleStateProvider);

    // 뷰모델에서 데이터 가져오기
    final assetData = ref.watch(assetDataProvider);

    // AsyncValue 상태에 따라 LoadingManager 처리
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (assetData is AsyncLoading) {
        LoadingManager.show(context, text: '자산 정보를 불러오는 중...');
      } else {
        LoadingManager.hide();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppbar(
        title: 'my little 자산',
        actions: [
          if (AppConfig.isDevelopment())
            IconButton(
              icon: const Icon(Icons.bug_report),  // 또는 다른 적절한 아이콘
              onPressed: () {
                context.push(FinanceRoutes.getTestPath());
              },
              tooltip: '테스트 페이지로 이동',
            ),
          const SimpleToggleButton(isSimplePage: true),  // 분리한 커스텀 토글 버튼 위젯
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

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
                        
                        const SizedBox(height: 24),
                        
                        GridView.count(
                          crossAxisCount: 2,  // 가로 방향 위젯 개수
                          mainAxisSpacing: 24,  // 세로 방향 간격
                          crossAxisSpacing: 18,  // 가로 방향 간격
                          shrinkWrap: true,  // GridView의 크기를 자식 위젯에 맞춤
                          physics: NeverScrollableScrollPhysics(),  // 스크롤 비활성화 (필요한 경우)
                          children: [
                            RealWallet(
                              demandDepositList: data.data.demandDepositData.demandDepositList.map((item) => 
                                DemandDepositItem(
                                  bankName: item.bankName,
                                  accountName: item.accountName,
                                  accountNo: item.accountNo,
                                  accountBalance: item.accountBalance,
                                )
                              ).toList(),
                              totalAmount: data.data.demandDepositData.totalAmount,
                              type: '입출금',
                            ),
                            
                            RealWallet(
                              demandDepositList: data.data.cardData.cardList.map((item) => 
                                DemandDepositItem(
                                  bankName: item.cardName,
                                  accountName: item.cardIssuerName,
                                  accountNo: item.cardNo,
                                  accountBalance: item.cardBalance,
                                )
                              ).toList(),
                              totalAmount: data.data.cardData.totalAmount,
                              type: '카드',
                            ),
                            
                            RealWallet(
                              demandDepositList: data.data.depositData.depositList.map((item) => 
                                DemandDepositItem(
                                  bankName: item.bankName,
                                  accountName: item.accountName,
                                  accountNo: item.accountNo,
                                  accountBalance: item.depositBalance,
                                )
                              ).toList(),
                              totalAmount: data.data.depositData.totalAmount,
                              type: '예금',
                            ),
                            
                            RealWallet(
                              demandDepositList: data.data.savingsData.savingsList.map((item) => 
                                DemandDepositItem(
                                  bankName: item.bankName,
                                  accountName: item.accountName,
                                  accountNo: item.accountNo,
                                  accountBalance: item.totalBalance,
                                )
                              ).toList(),
                              totalAmount: data.data.savingsData.totalAmount,
                              type: '적금',
                            ),
                            
                            RealWallet(
                              demandDepositList: data.data.loanData.loanList.map((item) => 
                                DemandDepositItem(
                                  bankName: item.accountName,
                                  accountName: item.accountName,
                                  accountNo: item.accountNo,
                                  accountBalance: item.loanBalance,
                                )
                              ).toList(),
                              totalAmount: data.data.loanData.totalAmount,
                              type: '대출',
                            ),
                            
                            RealWallet(
                              demandDepositList: [],
                              totalAmount: -1,
                              type: '자산 추가하기',
                            ),
                          ],
                        ),

                      ],
                    ),
                  );
                },
                loading: () {
                  // 로딩 중일 때는 빈 컨테이너 반환 (LoadingManager가 오버레이로 표시됨)
                  return Container();
                },
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