import 'package:marshmellow/core/constants/icon_path.dart';

enum ExpenseCategoryType {
  alcohol,
  baby,
  bank,
  car,
  coffee,
  culture,
  event,
  food,
  health,
  house,
  living,
  onlineShopping,
  pet,
  shopping,
  study,
  transport,
  travel,
  beauty,
  nonCategory,
}

class ExpenseCategory {
  final ExpenseCategoryType type;
  final String name;
  final String iconPath;

  const ExpenseCategory({
    required this.type,
    required this.name,
    required this.iconPath,
  });

  // 모든 카테고리 목록
  static final List<ExpenseCategory> allCategories = [
    ExpenseCategory(
      type: ExpenseCategoryType.alcohol,
      name: '술/유흥',
      iconPath: IconPath.expenseAlcohol,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.baby,
      name: '자녀/육아',
      iconPath: IconPath.expenseBaby,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.bank,
      name: '금융',
      iconPath: IconPath.expenseBank,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.car,
      name: '자동차',
      iconPath: IconPath.expenseCar,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.coffee,
      name: '카페/간식',
      iconPath: IconPath.expenseCoffee,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.culture,
      name: '문화/여가',
      iconPath: IconPath.expenseCulture,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.event,
      name: '경조/선물',
      iconPath: IconPath.expenseEvent,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.food,
      name: '식비',
      iconPath: IconPath.expenseFood,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.health,
      name: '의료/건강',
      iconPath: IconPath.expenseHealth,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.house,
      name: '주거/통신',
      iconPath: IconPath.expenseHouse,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.living,
      name: '생활비',
      iconPath: IconPath.expenseLiving,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.onlineShopping,
      name: '온라인 쇼핑',
      iconPath: IconPath.expenseOnlineShopping,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.pet,
      name: '반려동물',
      iconPath: IconPath.expensePet,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.shopping,
      name: '패션/쇼핑',
      iconPath: IconPath.expenseShopping,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.study,
      name: '교육/학습',
      iconPath: IconPath.expenseStudy,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.transport,
      name: '교통',
      iconPath: IconPath.expenseTransport,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.travel,
      name: '여행/숙박',
      iconPath: IconPath.expenseTravel,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.beauty,
      name: '뷰티/미용',
      iconPath: IconPath.expenseBeauty,
    ),
    ExpenseCategory(
      type: ExpenseCategoryType.nonCategory,
      name: '미분류',
      iconPath: IconPath.nonCategory,
    ),
  ];

  // ID로 카테고리 찾기
  static ExpenseCategory getById(ExpenseCategoryType id) {
    return allCategories.firstWhere(
      (category) => category.type == id,
      orElse: () => allCategories.last, // 기본값은 '미분류'
    );
  }

  // 이름으로 카테고리 찾기
  static ExpenseCategory getByName(String name) {
    return allCategories.firstWhere(
      (category) => category.name == name,
      orElse: () => allCategories.last, // 기본값은 '미분류'
    );
  }
}
