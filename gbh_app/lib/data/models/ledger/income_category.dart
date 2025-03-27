import 'package:marshmellow/core/constants/icon_path.dart';

enum IncomeCategoryType {
  bank,
  business,
  insurance,
  npay,
  parttime,
  realestate,
  recycle,
  salary,
  scholarship,
  sns,
  etc,
}

class IncomeCategory {
  final IncomeCategoryType type;
  final String name;
  final String iconPath;

  const IncomeCategory({
    required this.type,
    required this.name,
    required this.iconPath,
  });

  // 모든 수입 카테고리 목록
  static final List<IncomeCategory> allCategories = [
    IncomeCategory(
      type: IncomeCategoryType.bank,
      name: '금융수입',
      iconPath: IconPath.incomeBank,
    ),
    IncomeCategory(
      type: IncomeCategoryType.business,
      name: '사업수입',
      iconPath: IconPath.incomeBusiness,
    ),
    IncomeCategory(
      type: IncomeCategoryType.insurance,
      name: '보험금',
      iconPath: IconPath.incomeInsurance,
    ),
    IncomeCategory(
      type: IncomeCategoryType.npay,
      name: '더치페이',
      iconPath: IconPath.incomeNpay,
    ),
    IncomeCategory(
      type: IncomeCategoryType.parttime,
      name: '아르바이트',
      iconPath: IconPath.incomeParttime,
    ),
    IncomeCategory(
      type: IncomeCategoryType.realestate,
      name: '부동산',
      iconPath: IconPath.incomeRealestate,
    ),
    IncomeCategory(
      type: IncomeCategoryType.recycle,
      name: '중고거래',
      iconPath: IconPath.incomeRecycle,
    ),
    IncomeCategory(
      type: IncomeCategoryType.salary,
      name: '월급',
      iconPath: IconPath.incomeSalary,
    ),
    IncomeCategory(
      type: IncomeCategoryType.scholarship,
      name: '장학금',
      iconPath: IconPath.incomeScholarship,
    ),
    IncomeCategory(
      type: IncomeCategoryType.sns,
      name: 'SNS',
      iconPath: IconPath.incomeSns,
    ),
    IncomeCategory(
      type: IncomeCategoryType.etc,
      name: '기타',
      iconPath: IconPath.incomeEtc,
    ),
  ];

  // ID로 카테고리 찾기
  static IncomeCategory getById(IncomeCategoryType id) {
    return allCategories.firstWhere(
      (category) => category.type == id,
      orElse: () => allCategories.last, // 기본값은 '기타'
    );
  }

  // 이름으로 카테고리 찾기
  static IncomeCategory getByName(String name) {
    return allCategories.firstWhere(
      (category) => category.name == name,
      orElse: () => allCategories.last, // 기본값은 '기타'
    );
  }
}