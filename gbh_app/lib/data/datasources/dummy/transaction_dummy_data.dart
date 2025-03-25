import 'dart:math';
import 'package:uuid/uuid.dart'; // UUID 생성을 위한 패키지 추가 필요
import 'package:marshmellow/data/models/ledger/transactions.dart';
import 'package:marshmellow/data/models/ledger/expense_category.dart';
import 'package:marshmellow/data/models/ledger/income_category.dart';
import 'package:marshmellow/data/models/ledger/transaction_category.dart';

class TransactionDummyData {
  static final Random _random = Random();
  static final Uuid _uuid = Uuid();
  
  // 지출 항목 제목 샘플 데이터
  static final Map<ExpenseCategoryType, List<String>> _expenseTitles = {
    ExpenseCategoryType.food: ['맥도날드', '버거킹', '롯데리아', '김밥천국', '스타벅스', '주변식당', '배달음식', '편의점', '마트식품'],
    ExpenseCategoryType.coffee: ['스타벅스', '투썸플레이스', '이디야', '메가커피', '컴포즈', '빽다방', '폴바셋', '카페'],
    ExpenseCategoryType.transport: ['택시', '버스', '지하철', '대중교통', '카카오T', '따릉이', '교통비'],
    ExpenseCategoryType.shopping: ['유니클로', 'H&M', '자라', '무신사', '브랜디', '올리브영', '에이블리', '쿠팡'],
    ExpenseCategoryType.onlineShopping: ['쿠팡', '나이키', '배민상회', '11번가', 'G마켓', '옥션', '티몬', '위메프'], 
    ExpenseCategoryType.culture: ['CGV', '메가박스', '롯데시네마', '넷플릭스', '웨이브', '디즈니플러스', '콘서트', '뮤지컬'],
    ExpenseCategoryType.living: ['물티슈', '휴지', '쌀', '세제', '섬유유연제', '생필품', '마트', '홈플러스'],
    ExpenseCategoryType.beauty: ['올리브영', '아모레퍼시픽', '이니스프리', '네이처리퍼블릭', '어퓨', '에뛰드'],
    ExpenseCategoryType.health: ['약국', '병원비', '치과', '피부과', '운동센터', '헬스장', '비타민', '건강검진'],
    ExpenseCategoryType.house: ['월세', '관리비', '전기요금', '수도요금', '가스비', '인터넷', '휴대폰요금'],
    ExpenseCategoryType.alcohol: ['소주', '맥주', '와인', '위스키', '칵테일', '호프집', '주점', '술자리'],
    ExpenseCategoryType.pet: ['사료', '간식', '장난감', '병원비', '미용', '용품', '동물병원'],
    ExpenseCategoryType.car: ['주유', '주차비', '세차', '정비', '자동차보험', '과태료', '하이패스'],
    ExpenseCategoryType.study: ['학원비', '교재', '온라인강의', '스터디카페', '자격증', '시험비'],
    ExpenseCategoryType.travel: ['호텔', '항공권', '여행사', '숙박', '리조트', '펜션', 'KTX'],
    ExpenseCategoryType.event: ['결혼식', '생일선물', '돌잔치', '경조사', '명절선물', '화환'],
    ExpenseCategoryType.bank: ['이체수수료', '대출이자', '보험료', '적금', '연회비'],
    ExpenseCategoryType.baby: ['분유', '기저귀', '유아용품', '장난감', '의류', '아기간식'],
    ExpenseCategoryType.nonCategory: ['기타지출', '잡비', '현금인출'],
  };
  
  // 수입 항목 제목 샘플 데이터
  static final Map<IncomeCategoryType, List<String>> _incomeTitles = {
    IncomeCategoryType.salary: ['월급', '급여', '상여금', '성과급', '연봉', '보너스'],
    IncomeCategoryType.parttime: ['알바비', '아르바이트', '과외비', '강의비', '특강비'],
    IncomeCategoryType.business: ['매출', '수익', '사업소득', '프리랜서', '계약금', '용역비'],
    IncomeCategoryType.bank: ['이자수입', '배당금', '적금만기', '펀드수익', '환급금', '신용카드혜택'],
    IncomeCategoryType.realestate: ['월세수입', '전세수입', '부동산임대', '부동산매각'],
    IncomeCategoryType.insurance: ['보험금', '보험환급금', '의료비환급', '실손보험'],
    IncomeCategoryType.scholarship: ['장학금', '연구비', '지원금', '공모상금', '수상금'],
    IncomeCategoryType.sns: ['유튜브수익', '애드센스', '콘텐츠수익', '광고수익'],
    IncomeCategoryType.npay: ['더치페이', '지인송금', '정산', '환불', '송금'],
    IncomeCategoryType.recycle: ['중고거래', '당근마켓', '번개장터', '중고나라'],
    IncomeCategoryType.etc: ['기타소득', '용돈', '선물', '상금', '복권'],
  };
  
  // 결제 수단 샘플
  static final List<String> _paymentMethods = [
    '현금',
    '모바일결제',
    '신용카드',
    '체크카드',
    '계좌이체',
  ];
  
  // 계좌 및 카드 샘플
  static final List<String> _accounts = [
    '토스뱅크',
    '국민 체크카드',
    '신한카드',
    '우리카드',
    '하나카드',
    '삼성카드',
    '현대카드',
  ];
  
  // 무작위 날짜 생성 (startDate ~ endDate 사이)
  static DateTime _randomDate(DateTime startDate, DateTime endDate) {
    final difference = endDate.difference(startDate).inDays;
    return startDate.add(Duration(days: _random.nextInt(difference)));
  }
  
  // 무작위 시간 포함된 날짜 생성
  static DateTime _randomDateTime(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      _random.nextInt(24),  // 시간
      _random.nextInt(60),  // 분
    );
  }
  
  // 무작위 금액 생성 (범위 내에서)
  static double _randomAmount(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }
  
  // 특정 날짜의 무작위 지출 트랜잭션 생성
  static Transaction _generateRandomExpense(DateTime date) {
    // 무작위 지출 카테고리 선택
    final categoryTypes = ExpenseCategoryType.values;
    final categoryType = categoryTypes[_random.nextInt(categoryTypes.length)];
    
    // 카테고리에 맞는 제목 선택
    final titles = _expenseTitles[categoryType] ?? ['기타 지출'];
    final title = titles[_random.nextInt(titles.length)];
    
    // 무작위 금액 (500원 ~ 100,000원, 100원 단위로 반올림)
    double amount = _randomAmount(500, 100000);
    amount = (amount / 100).round() * 100;
    
    // 카테고리별 금액 조정 (주거/통신비는 더 크게, 카페/간식은 작게 등)
    if (categoryType == ExpenseCategoryType.house) {
      amount = _randomAmount(100000, 1000000).roundToDouble();
    } else if (categoryType == ExpenseCategoryType.coffee) {
      amount = _randomAmount(1000, 8000).roundToDouble();
    } else if (categoryType == ExpenseCategoryType.food) {
      amount = _randomAmount(5000, 30000).roundToDouble();
    } else if (categoryType == ExpenseCategoryType.shopping || 
              categoryType == ExpenseCategoryType.onlineShopping) {
      amount = _randomAmount(10000, 200000).roundToDouble();
    }
    
    // 결제 방법 및 계좌/카드 무작위 선택
    final paymentMethod = _paymentMethods[_random.nextInt(_paymentMethods.length)];
    final account = _accounts[_random.nextInt(_accounts.length)];
    
    return Transaction(
      id: _uuid.v4(),
      date: _randomDateTime(date),
      title: title,
      amount: amount,
      type: TransactionType.expense,
      categoryId: categoryType,
      paymentMethod: paymentMethod,
      accountName: account,
    );
  }
  
  // 특정 날짜의 무작위 수입 트랜잭션 생성
  static Transaction _generateRandomIncome(DateTime date) {
    // 무작위 수입 카테고리 선택
    final categoryTypes = IncomeCategoryType.values;
    final categoryType = categoryTypes[_random.nextInt(categoryTypes.length)];
    
    // 카테고리에 맞는 제목 선택
    final titles = _incomeTitles[categoryType] ?? ['기타 수입'];
    final title = titles[_random.nextInt(titles.length)];
    
    // 무작위 금액 (1,000원 ~ 500,000원, 1,000원 단위로 반올림)
    double amount = _randomAmount(1000, 500000);
    amount = (amount / 1000).round() * 1000;
    
    // 카테고리별 금액 조정 (월급은 더 크게, 더치페이는 작게 등)
    if (categoryType == IncomeCategoryType.salary) {
      amount = _randomAmount(2000000, 5000000).roundToDouble();
    } else if (categoryType == IncomeCategoryType.parttime) {
      amount = _randomAmount(200000, 1000000).roundToDouble();
    } else if (categoryType == IncomeCategoryType.business) {
      amount = _randomAmount(500000, 3000000).roundToDouble();
    } else if (categoryType == IncomeCategoryType.npay) {
      amount = _randomAmount(5000, 50000).roundToDouble();
    }
    
    // 입금 계좌 무작위 선택
    final account = _accounts[_random.nextInt(_accounts.length)];
    
    return Transaction(
      id: _uuid.v4(),
      date: _randomDateTime(date),
      title: title,
      amount: amount,
      type: TransactionType.income,
      categoryId: categoryType,
      paymentMethod: '계좌이체',
      accountName: account,
    );
  }
  
  // 특정 기간의 트랜잭션 더미 데이터 생성
  static List<Transaction> generateTransactions({
    required DateTime startDate,
    required DateTime endDate,
    int? expenseCountPerDay,
    int? incomeCountPerDay,
  }) {
    List<Transaction> transactions = [];
    final difference = endDate.difference(startDate).inDays;
    
    // 각 날짜별로 트랜잭션 생성
    for (int i = 0; i <= difference; i++) {
      final date = startDate.add(Duration(days: i));
      
      // 지출 트랜잭션 생성
      final expCount = expenseCountPerDay ?? _random.nextInt(5) + 1; // 기본 1~5개
      for (int j = 0; j < expCount; j++) {
        transactions.add(_generateRandomExpense(date));
      }
      
      // 수입 트랜잭션 생성 (지출보다 적게)
      final incCount = incomeCountPerDay ?? _random.nextInt(2); // 기본 0~1개
      for (int j = 0; j < incCount; j++) {
        transactions.add(_generateRandomIncome(date));
      }
    }
    
    // 급여는 월초(1일)와 월중(15일)에 주로 들어오도록 설정
    final months = <DateTime>[];
    
    // 기간에 포함된 월의 1일과 15일 목록 생성
    DateTime current = DateTime(startDate.year, startDate.month, 1);
    while (current.isBefore(endDate)) {
      // 1일 추가
      if (current.isAfter(startDate) || current.isAtSameMomentAs(startDate)) {
        months.add(current);
      }
      
      // 15일 추가
      final mid = DateTime(current.year, current.month, 15);
      if (mid.isAfter(startDate) && mid.isBefore(endDate)) {
        months.add(mid);
      }
      
      // 다음 달로 이동
      current = DateTime(
        current.month == 12 ? current.year + 1 : current.year, 
        current.month == 12 ? 1 : current.month + 1, 
        1
      );
    }
    
    // 월급 트랜잭션 추가
    for (final date in months) {
      // 날짜가 1일이면 높은 확률로 월급 추가
      if (date.day == 1 && _random.nextDouble() < 0.8) {
        transactions.add(Transaction(
          id: _uuid.v4(),
          date: DateTime(date.year, date.month, date.day, 9, 0), // 오전 9시 입금
          title: '월급',
          amount: _randomAmount(2000000, 5000000).roundToDouble(),
          type: TransactionType.income,
          categoryId: IncomeCategoryType.salary,
          paymentMethod: '계좌이체',
          accountName: '하나은행',
        ));
      }
      
      // 날짜가 15일이면 중간 확률로 상여금 추가
      if (date.day == 15 && _random.nextDouble() < 0.4) {
        transactions.add(Transaction(
          id: _uuid.v4(),
          date: DateTime(date.year, date.month, date.day, 9, 0), // 오전 9시 입금
          title: '상여금',
          amount: _randomAmount(300000, 1000000).roundToDouble(),
          type: TransactionType.income,
          categoryId: IncomeCategoryType.salary,
          paymentMethod: '계좌이체',
          accountName: '하나은행',
        ));
      }
    }
    
    // 월세/관리비는 매월 초에 나가도록 설정
    current = DateTime(startDate.year, startDate.month, 1);
    while (current.isBefore(endDate)) {
      if (current.isAfter(startDate) || current.isAtSameMomentAs(startDate)) {
        // 월세 추가
        transactions.add(Transaction(
          id: _uuid.v4(),
          date: DateTime(current.year, current.month, _random.nextInt(5) + 1), // 1~5일
          title: '월세',
          amount: 300000 + (_random.nextInt(10) * 10000), // 30~40만원
          type: TransactionType.expense,
          categoryId: ExpenseCategoryType.house,
          paymentMethod: '계좌이체',
          accountName: '우리은행',
        ));
        
        // 관리비 추가
        transactions.add(Transaction(
          id: _uuid.v4(),
          date: DateTime(current.year, current.month, _random.nextInt(5) + 1), // 1~5일
          title: '관리비',
          amount: 50000 + (_random.nextInt(10) * 5000), // 5~10만원
          type: TransactionType.expense,
          categoryId: ExpenseCategoryType.house,
          paymentMethod: '계좌이체',
          accountName: '우리은행',
        ));
      }
      
      // 다음 달로 이동
      current = DateTime(
        current.month == 12 ? current.year + 1 : current.year, 
        current.month == 12 ? 1 : current.month + 1, 
        1
      );
    }
    
    // 날짜순으로 정렬
    transactions.sort((a, b) => b.date.compareTo(a.date)); // 내림차순 (최신순)
    
    return transactions;
  }
  
  // 특정 달의 트랜잭션 생성 (1일부터 말일까지)
  static List<Transaction> generateMonthTransactions(int year, int month) {
    final startDate = DateTime(year, month, 1);
    final endDate = month < 12 
      ? DateTime(year, month + 1, 1).subtract(Duration(days: 1))
      : DateTime(year + 1, 1, 1).subtract(Duration(days: 1));
    
    return generateTransactions(startDate: startDate, endDate: endDate);
  }
}