// presentation/pages/finance/finance_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; 
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/utils/lifecycle/app_lifecycle_manager.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/presentation/widgets/loading/loading_manager.dart';
import 'package:marshmellow/router/routes/finance_routes.dart';
import 'package:marshmellow/presentation/viewmodels/finance/finance_viewmodel.dart';

// 분리한 위젯들 import
import 'package:marshmellow/presentation/pages/finance/widgets/finance_section_tabs_widget.dart';
import 'package:marshmellow/presentation/pages/finance/widgets/account_item_widget.dart';
import 'package:marshmellow/presentation/pages/finance/widgets/card_item_widget.dart';
import 'package:marshmellow/presentation/pages/finance/widgets/financial_section_widget.dart';
import 'package:marshmellow/presentation/pages/finance/widgets/total_assets_widget.dart';

// appbar 간편버튼
import 'package:marshmellow/presentation/pages/finance/widgets/simple_toggle_button_widget.dart';


// ConsumerStatefulWidget으로 변경
class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});

  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends ConsumerState<FinancePage> {
  // 스크롤 컨트롤러를 state에서 관리
  late ScrollController scrollController;
  
  // 각 섹션의 위치를 참조하기 위한 GlobalKey 맵
  late Map<String, GlobalKey> sectionKeys;

  @override
  void initState() {
    super.initState();
    
    // 스크롤 컨트롤러 초기화
    scrollController = ScrollController();
    
    // 섹션 키 초기화
    sectionKeys = {
      '입출금': GlobalKey(),
      '카드': GlobalKey(),
      '예적금': GlobalKey(),
      '대출': GlobalKey(),
    };
  }

  @override
  void dispose() {
    // 스크롤 컨트롤러 해제
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 라이프사이클 상태 구독
    final lifecycleState = ref.watch(lifecycleStateProvider);

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
          const SimpleToggleButton(), // 분리한 커스텀 토글 버튼 위젯
        ],
      ),
      body: Center(
        child: Column(
          children: [
            // 데이터 로딩 중이 아닐 때만 탭 표시
            // if (assetData.value != null && !assetData.isLoading)
            FinanceSectionTabs(
              scrollController: scrollController,
              sectionKeys: sectionKeys,
            ),
            
            Expanded(
              child: assetData.when(
                data: (data) {
                  // 성공적으로 데이터를 받았을 때
                  final financeViewModel = ref.read(financeViewModelProvider);
                  final totalAssets = financeViewModel.calculateTotalAssets(data.data);
                  
                  return SingleChildScrollView(
                    controller: scrollController, // 스크롤 컨트롤러 연결
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const SizedBox(height: 12),
                        // 총 자산 정보
                        TotalAssetsWidget(totalAssets: totalAssets),
                        const SizedBox(height: 12),

                        // 입출금 계좌 정보
                        FinancialSectionWidget(
                          key: sectionKeys['입출금'], // 섹션 위치 추적용 키
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
                          key: sectionKeys['카드'], // 섹션 위치 추적용 키
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
                          key: sectionKeys['예적금'], // 섹션 위치 추적용 키
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
                          key: sectionKeys['대출'], // 섹션 위치 추적용 키
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