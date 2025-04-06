class AverageSpendingResponse {
  final int code;
  final String message;
  final AverageSpendingData data;

  AverageSpendingResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory AverageSpendingResponse.fromJson(Map<String, dynamic> json) {
    return AverageSpendingResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: AverageSpendingData.fromJson(json['data']),
    );
  }
}

class AverageSpendingData {
  final Map<String, int> monthlySpendingMap;
  final int averageMonthlySpending;

  AverageSpendingData({
    required this.monthlySpendingMap,
    required this.averageMonthlySpending,
  });

  factory AverageSpendingData.fromJson(Map<String, dynamic> json) {
    final Map<String, int> monthlyMap = {};
    final dynamic rawMap = json['monthlySpendingMap'];
    
    if (rawMap is Map) {
      rawMap.forEach((key, value) {
        monthlyMap[key.toString()] = value is int ? value : int.parse(value.toString());
      });
    }

    return AverageSpendingData(
      monthlySpendingMap: monthlyMap,
      averageMonthlySpending: json['averageMonthlySpending'] as int,
    );
  }
}