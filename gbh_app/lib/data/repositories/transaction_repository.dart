import 'package:marshmellow/data/datasources/dummy/transaction_dummy_data.dart';
import 'package:marshmellow/data/models/ledger/category/transactions.dart';
import 'package:marshmellow/data/models/ledger/category/transaction_category.dart';

class TransactionRepository {
  // 특정 기간의 트랜잭션 가져오기
  Future<List<Transaction>> getTransactions({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 실제 API 연결 구현 전까지는 더미 데이터 사용
    return TransactionDummyData.generateTransactions(
      startDate: startDate, 
      endDate: endDate
    );
  }
  
  // 특정 달의 트랜잭션 가져오기
  Future<List<Transaction>> getMonthTransactions(int year, int month) async {
    // 실제 API 연결 구현 전까지는 더미 데이터 사용
    return TransactionDummyData.generateMonthTransactions(year, month);
  }
  
  // 날짜별 트랜잭션 그룹화
  Map<DateTime, List<Transaction>> groupTransactionsByDate(List<Transaction> transactions) {
    Map<DateTime, List<Transaction>> grouped = {};
    
    for (var transaction in transactions) {
      // 시간 정보 제거한 날짜만 키로 사용
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      
      grouped[date]!.add(transaction);
    }
    
    return grouped;
  }
  
  // 월별 지출/수입 합계 계산
  Map<String, double> calculateMonthSummary(List<Transaction> transactions) {
    double totalIncome = 0;
    double totalExpense = 0;
    
    for (var transaction in transactions) {
      if (transaction.type == TransactionType.deposit) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }
    
    return {
      'income': totalIncome,
      'expense': totalExpense,
    };
  }
}