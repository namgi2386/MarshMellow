import 'package:dio/dio.dart';
import 'package:marshmellow/data/datasources/remote/api_client.dart';

/*
  사용자 월급 정보 api
*/
class MySalaryApi {
  final ApiClient _apiClient;
  
  MySalaryApi(this._apiClient);

  // 1. 입출금계좌목록조회
  Future<Response> getAccountList() async {
    return await _apiClient.get('/api/mm/auth/account-list');
  }

  // 2. 입금내역조회
  Future<Response> getDepositList(String accountNo) async {
    return await _apiClient.post(
      '/api/mm/auth/deposit-list', 
      data: {
        'accountNo': accountNo
    });
  }

  // 3. 월급등록
  Future<Response> registerSalary(int salary, int date) async {
    return await _apiClient.post('/api/mm/auth/salary', data: {
      'salary': salary,
      'date': date
    });
  }

  // 4. 월급수정
  Future<Response> updateSalary(int salary, int date) async {
    return await _apiClient.patch('/api/mm/auth/salary', data: {
      'salary': salary,
      'date': date
    });
  }  
}