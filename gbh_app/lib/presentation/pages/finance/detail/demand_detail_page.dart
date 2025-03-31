// lib/presentation/pages/finance/demand_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/finance/detail/demand_detail_model.dart';
import 'package:marshmellow/presentation/pages/finance/services/transfer_service.dart';
import 'package:marshmellow/presentation/viewmodels/finance/demand_detail_viewmodel.dart';
import 'package:marshmellow/presentation/widgets/button/button.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/presentation/widgets/finance/bank_icon.dart';

class DemandDetailPage extends ConsumerStatefulWidget {
  final String accountNo;
  final String bankName;
  final String accountName;
  final int balance;
  final bool noMoneyMan;

  const DemandDetailPage({
    Key? key,
    required this.accountNo,
    required this.bankName,
    required this.accountName,
    required this.balance,
    required this.noMoneyMan,
  }) : super(key: key);

  @override
  ConsumerState<DemandDetailPage> createState() => _DemandDetailPageState();
}

class _DemandDetailPageState extends ConsumerState<DemandDetailPage> {
  late String startDate;
  late String endDate;
  late DemandDetailParams params;
  
  @override
  void initState() {
    super.initState();
    // 기본 조회 기간: 최근 1개월
    final now = DateTime.now();
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
    
    startDate = DateFormat('yyyyMMdd').format(oneMonthAgo);
    endDate = DateFormat('yyyyMMdd').format(now);

    _updateParams();
  }
  // 파라미터 갱신 메서드
  void _updateParams() {
    params = DemandDetailParams(
      accountNo: widget.accountNo,
      startDate: startDate,
      endDate: endDate,
      transactionType: ref.read(transactionFilterProvider),
      orderByType: ref.read(orderByTypeProvider),
    );
  }
  // 상태 변경시 파라미터 갱신
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentTransactionType = ref.watch(transactionFilterProvider);
    final currentOrderByType = ref.watch(orderByTypeProvider);
    
    if (currentTransactionType != params.transactionType || 
        currentOrderByType != params.orderByType) {
      setState(() {
        _updateParams();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionType = ref.watch(transactionFilterProvider);
    final orderByType = ref.watch(orderByTypeProvider);
    
    final params = DemandDetailParams(
      accountNo: widget.accountNo,
      startDate: startDate,
      endDate: endDate,
      transactionType: transactionType,
      orderByType: orderByType,
    );
    
    final transactionsAsync = ref.watch(demandTransactionsProvider(params));
    
    return Scaffold(
      appBar: CustomAppbar(
        title: 'my little 자산',
      ),
      body: Column(
        children: [
          _buildAccountHeader(),
          _buildFilterButtons(),
          _buildDateSelector(),
          Expanded(
            child: transactionsAsync.when(
              data: (response) => _buildTransactionList(response.data.transactionList),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('오류가 발생했습니다: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.accountName,
            style: AppTextStyles.appBar
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 은행아이콘
              BankIcon(bankName: widget.bankName, size: 30),
              // 은행명 
              Text(
                widget.bankName,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(width: 4,),
              //계좌번호 
              Text(
                widget.accountNo,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              //복사버튼 
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: widget.accountNo));
                },
                borderRadius: BorderRadius.circular(4), // 원하는 모서리 둥글기
                child: Padding(
                  padding: const EdgeInsets.all(4), // 필요한 만큼만 패딩 추가
                  child: SvgPicture.asset(
                    'assets/icons/body/CopySimple.svg',
                    height: 16,
                    color: AppColors.disabled,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${NumberFormat('#,###').format(widget.balance)}원',
                style: AppTextStyles.bodyExtraLarge
              ),
              Button(
                text: '송금',
                width: 60,
                height: 40,
                onPressed: () {
                  TransferService.handleTransfer(context, ref, widget.accountNo);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }


Widget _buildFilterButtons() {
  final transactionType = ref.watch(transactionFilterProvider);
  final viewModel = ref.read(demandDetailViewModelProvider);
  
  // 드롭다운 옵션 매핑
  final Map<String, String> filterOptions = {
    'A': '전체', 
    'M': '입금',
    'D': '출금'
  };
  
  // 현재 선택된 필터 텍스트
  final String currentFilterText = filterOptions[transactionType] ?? '전체';
  
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // PopupMenuButton을 Material로 감싸서 너비 설정
        Text('이용내역' , style: AppTextStyles.bodyMediumLight,),
        Material(
          color: Colors.transparent,
          child: PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            offset: const Offset(0, 20),
            constraints: const BoxConstraints(
              minWidth: 60, // 최소 너비
              maxWidth: 60, // 최대 너비
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currentFilterText),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
            itemBuilder: (context) => filterOptions.entries.map((entry) {
              return PopupMenuItem<String>(
                value: entry.key,
                height: 36, // 작은 높이값
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), // 작은 패딩
                child: Text(entry.value),
              );
            }).toList(),
            onSelected: (String value) {
              viewModel.changeTransactionFilter(value);
            },
          ),
        ),
      ],
    ),
  );
}

  Widget _buildDateSelector() {
    // 기간 선택 UI 구현 (간단한 버튼 형태로 구현)
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context, true),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Text(
                  _formatDateForDisplay(startDate),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('~'),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context, false),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Text(
                  _formatDateForDisplay(endDate),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = _parseDate(isStartDate ? startDate : endDate);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        final formattedDate = DateFormat('yyyyMMdd').format(picked);
        if (isStartDate) {
          startDate = formattedDate;
        } else {
          endDate = formattedDate;
        }
        _updateParams(); // 날짜 변경 후 파라미터 갱신
      });
    }
  }

  DateTime _parseDate(String dateStr) {
    final year = int.parse(dateStr.substring(0, 4));
    final month = int.parse(dateStr.substring(4, 6));
    final day = int.parse(dateStr.substring(6, 8));
    return DateTime(year, month, day);
  }

  String _formatDateForDisplay(String dateStr) {
    final year = dateStr.substring(0, 4);
    final month = dateStr.substring(4, 6);
    final day = dateStr.substring(6, 8);
    return '$year.$month.$day';
  }

  Widget _buildTransactionList(List<TransactionItem> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('거래 내역이 없습니다.'),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = transactions[index];
        final isDeposit = item.transactionType == '1';
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _formatTransactionDate(item.transactionDate),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Text(_formatTransactionTime(item.transactionTime)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.transactionSummary,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${isDeposit ? '+' : '-'}${NumberFormat('#,###').format(int.parse(item.transactionBalance))}원',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDeposit ? Colors.blue : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('잔액: ', style: TextStyle(color: Colors.grey)),
                  Text(
                    '${NumberFormat('#,###').format(int.parse(item.transactionAfterBalance))}원',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTransactionDate(String dateStr) {
    final year = dateStr.substring(0, 4);
    final month = dateStr.substring(4, 6);
    final day = dateStr.substring(6, 8);
    return '$year.$month.$day';
  }

  String _formatTransactionTime(String timeStr) {
    final hour = timeStr.substring(0, 2);
    final minute = timeStr.substring(2, 4);
    return '$hour:$minute';
  }
}