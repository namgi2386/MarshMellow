import 'package:marshmellow/data/models/ledger/category/withdrawal_category.dart';
import 'package:marshmellow/data/models/ledger/category/deposit_category.dart';
import 'package:marshmellow/data/models/ledger/category/transfer_category.dart';
import 'package:marshmellow/data/models/ledger/category/transaction_category.dart';

class TransactionCategoryRepository {
  // 모든 지출 카테고리 가져오기
  List<WithdrawalCategory> getWithdrawalCategories() {
    return WithdrawalCategory.allCategories;
  }
  
  // 모든 수입 카테고리 가져오기
  List<DepositCategory> getDepositCategories() {
    return DepositCategory.allCategories;
  }
  // 모든 이체 카테고리 가져오기
  List<TransferCategory> getTransferCategories() {
    return TransferCategory.allCategories;
  }
  
  // 지출 카테고리 ID로 카테고리 정보 가져오기
  WithdrawalCategory? getWithdrawalCategoryById(WithdrawalCategoryType typeId) {
    try {
      return WithdrawalCategory.getById(typeId);
    } catch (_) {
      return null;
    }
  }

  // 지출 카테고리 이름으로 카테고리 정보 가져오기
  WithdrawalCategory? getWithdrawalCategoryByName(String name) {
    try {
      return WithdrawalCategory.getByName(name);
    } catch (_) {
      return null;
    }
  }

  
  // 수입 카테고리 ID로 카테고리 정보 가져오기
  DepositCategory? getDepositCategoryById(DepositCategoryType typeId) {
    try {
      return DepositCategory.getById(typeId);
    } catch (_) {
      return null;
    }
  }

  // 수입 카테고리 이름으로 카테고리 정보 가져오기
  DepositCategory? getDepositCategoryByName(String name) {
    try {
      return DepositCategory.getByName(name);
    } catch (_) {
      return null;
    }
  }

  // 이체 카테고리 ID로 카테고리 정보 가져오기
  TransferCategory? getTransferCategoryById(TransferCategoryType typeId) {
    try {
      return TransferCategory.getById(typeId);
    } catch (_) {
      return null;
    }
  }

  // 이체 카테고리 이름으로 카테고리 정보 가져오기
  TransferCategory? getTransferCategoryByName(String name) {
    try {
      return TransferCategory.getByName(name);
    } catch (_) {
      return null;
    }
  }
  
  // 트랜잭션 타입에 따라 모든 트랜잭션 카테고리 가져오기
  List<TransactionCategory> getTransactionCategories(TransactionType type) {
    switch (type) {
      case TransactionType.withdrawal:
        return TransactionCategory.getAllWithdrawalCategories();
      case TransactionType.deposit:
        return TransactionCategory.getAllDepositCategories();
      case TransactionType.transfer:
        return TransactionCategory.getAllTransferCategories();
    }
  }
  
  // 카테고리 이름으로 검색
  List<TransactionCategory> searchCategoriesByName(String query) {
    final allCategories = [
      ...getTransactionCategories(TransactionType.withdrawal),
      ...getTransactionCategories(TransactionType.deposit),
      ...getTransactionCategories(TransactionType.transfer),
    ];
    
    if (query.isEmpty) return allCategories;
    
    return allCategories
        .where((cat) => cat.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}