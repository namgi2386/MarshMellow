// lib/presentation/pages/finance/demand_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
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

//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 아이콘 하드코딩 <<<<<<<<<<<<<<<<<<<<<<<

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 아이콘 하드코딩 >>>>>>>>>>>>>>>>>>>>>

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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BankIcon(bankName: widget.bankName , size: 30),
              Text(
                widget.bankName,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(width: 4,),
              Text(
                widget.accountNo,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              IconButton(
                icon: SvgPicture.asset('assets/icons/body/CopySimple.svg',
                height: 16,
              ),
                onPressed: () {
                  // _onAccountItemTap(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${NumberFormat('#,###').format(widget.balance)}원',
                style: AppTextStyles.appBar
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
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _filterButton('전체', 'A', transactionType, viewModel),
          const SizedBox(width: 8),
          _filterButton('입금', 'M', transactionType, viewModel),
          const SizedBox(width: 8),
          _filterButton('출금', 'D', transactionType, viewModel),
        ],
      ),
    );
  }

  Widget _filterButton(String label, String value, String currentValue, DemandDetailViewModel viewModel) {
    final isSelected = value == currentValue;
    
    return ElevatedButton(
      onPressed: () => viewModel.changeTransactionFilter(value),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(label),
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
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
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
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
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