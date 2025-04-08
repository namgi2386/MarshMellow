import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/constants/storage_keys.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/di/providers/auth/pin_provider.dart';
import 'package:marshmellow/di/providers/auth/user_provider.dart';
import 'package:marshmellow/di/providers/core_providers.dart';
import 'package:marshmellow/presentation/widgets/loading/custom_loading_indicator.dart';
import 'package:marshmellow/router/routes/auth_routes.dart';

/*
  앱 시작시 로그인 회원가입 여부 확인 페이지
*/
class AuthCheckPage extends ConsumerStatefulWidget {
  const AuthCheckPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends ConsumerState<AuthCheckPage> {
  @override
  void initState() {
    super.initState();
    print('===== AuthCheckPage initState 실행 =====');
    _checkAuthStatus();
  }

  // 인증 상태 확인
  Future<void> _checkAuthStatus() async {;
  
    // 개발용 자동 로그인 코드 (출시 전 제거)
    // TODO: 출시 전 이 부분 삭제
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.write(
        key: StorageKeys.phoneNumber, value: '01056297169');
    await secureStorage.write(key: StorageKeys.userName, value: '윤잰큰');
    // <<<<<<<<<<<< [ 어세스 토큰을 이 아래에 넣으세요 ] <<<<<<<<<<<<<<<<<<<<<<<<
    await secureStorage.write(key: StorageKeys.accessToken, value: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJ0b2tlblR5cGUiOiJBQ0NFU1MiLCJ1c2VyUGsiOjMsInN1YiI6ImFjY2Vzcy10b2tlbiIsImlhdCI6MTc0NDA5NTgzNiwiZXhwIjoxNzQ0MTEzODM2fQ.5szMIAl1eeZJxEdafalkU5lpc9BoHIXzRPIgs5VX5tRxjRK4EJRBCzT_0VNxd4Sc5Z6rYUaeTjhC22L5VbRNsw'); 
    await secureStorage.write(key: StorageKeys.refreshToken, value: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJ0b2tlblR5cGUiOiJSRUZSRVNIIiwidXNlclBrIjozLCJzdWIiOiJyZWZyZXNoLXRva2VuIiwiaWF0IjoxNzQ0MDk1ODM2LCJleHAiOjE3NzAwMTU4MzZ9.2tTtcfN4dkBZuxjxJsCd8kr4_2RcGruZENQijCt62vJlR8CyjDvEL0YtjbAzfIdzGsfZqd4Jh2eTiv0wMaebaQ'); 
    await secureStorage.write(key: StorageKeys.certificatePem, value: '-----BEGIN CERTIFICATE-----MIIC4DCCAcigAwIBAgIGAZYOtqPzMA0GCSqGSIb3DQEBDQUAMCwxDjAMBgNVBAMMBU1NIENBMQ0wCwYDVQQKDARNeUNBMQswCQYDVQQGEwJLUjAeFw0yNTA0MDcwNTI2MTJaFw0yNjA0MDcwNTI2MTJaMDYxCzAJBgNVBAYTAktSMQwwCgYDVQQKEwNHQkgxGTAXBgNVBAMTEGhhcHB5MUBnbWFpbC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCBhA73b93l5Ymt4eDYuklKDCmU8C38vba/GUNT4E0M5B99jQZASCc/9wghPqEXdy/8REREl1n3hKxOR/1/u9MMFJ8aLuUfCtZzEtyQqIKsoChQ6ZwxrzoyLvEUG5QyCLy9rFWsM/cvW3cxGA/N3li3Z2XeBrON+YZvtXwsyzVlazXMOsTz1CSrcPVnDA0zQtqmHFvvgMpzWOhIoiYwq9hsJq+tyya0/eBbHEQG59DI8K5AeXKG4Pg1jO4kKBX8zRrL+Wwk98lLO2OUeDgFr6sIyT32MwfGETiuBuBclTbjYx3AXk+/ktlTBGApMSC56pNVypq5e7uMwWQIZ53TeHWDAgMBAAEwDQYJKoZIhvcNAQENBQADggEBAAPqdfZ5/9pJWKkOyr3EOUoSCaUIDpSP4Gx32ptcGiB8cRLrmAzX8ZPQ1nVOZvO8X8gxvyskxW4AH7gH0rrAdhXXyp6o0eT/nrv/ONYEDFNixy5P/ws7lBykZJkaTmzQtZL2ow4PVX9KfzWSMNF4geljBi7xPNxCLOGOORl7PyI49FjURMH1pZV3BxV4439YzPLlPCcs/+cTzaO/KECAPt2Tgj4HtEu1P4OaKjVvIeAH/WcNgnN377V1UTKfd1RJQo4zT/gbyLX5r3vXqk5IikXh05U8VN9Ht60UzYDtvOof1RgXNnnc7Uv/yaufdtjG16Ty0r3BxdXIWuTprZQQWl8=-----END CERTIFICATE-----'); 
    await secureStorage.write(key: StorageKeys.userkey, value: '2c2fd595-4118-4b6c-9fd7-fc811910bb75');
                                                                                                                                                                                                                                            
    // secure storage에서 필요한 정보 불러오기
    // final secureStorage = ref.read(secureStorageProvider);
    final phoneNumber = await secureStorage.read(key: StorageKeys.phoneNumber);
    final accessToken = await secureStorage.read(key: StorageKeys.accessToken);
    final refreshToken =
        await secureStorage.read(key: StorageKeys.refreshToken);

    print('디버그 - 저장된 정보:');
    print('phoneNumber: $phoneNumber');
    print('accessToken: ${accessToken != null ? '있음' : '없음'}');
    print('refreshToken: ${refreshToken != null ? '있음' : '없음'}');

    // 지연 효과
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      if (phoneNumber != null && accessToken != null && refreshToken != null) {
        print('케이스 1: 전화번호와 토큰 모두 있음');
        // 전화번호와 토큰 저장되 있으면 사용자 정보 갱신
        final userNotifier = ref.read(userStateProvider.notifier);

        // 기존 정보 가져와서 함께 설정
        final userName =
            await secureStorage.read(key: StorageKeys.userName) ?? '';
        final userCode =
            await secureStorage.read(key: StorageKeys.userCode) ?? '';
        final carrier =
            await secureStorage.read(key: StorageKeys.carrier) ?? '';

        print('사용자 정보 설정:');
        print('userName: $userName');
        print('userCode: $userCode');
        print('carrier: $carrier');

        await userNotifier.setVerificationData(
            userName: userName,
            phoneNumber: phoneNumber,
            userCode: userCode,
            carrier: carrier);

        print('사용자 정보 설정 완료');

        // 토큰 유효성 검사
        print('토큰 유효성 검사 시작');
        _validateToken();
        // 검사하여 메인 페이지 또는 로그인 페이지로 이동
      } else if (phoneNumber != null) {
        print('케이스 2: 전화번호만 있음');
        // 전화번호만 저장되어 있으면 로그인 페이지로 이동
        final userNotifier = ref.read(userStateProvider.notifier);

        // 기존 정보 가져와서 함께 설정
        final userName =
            await secureStorage.read(key: StorageKeys.userName) ?? '';
        final userCode =
            await secureStorage.read(key: StorageKeys.userCode) ?? '';
        final carrier =
            await secureStorage.read(key: StorageKeys.carrier) ?? '';

        await userNotifier.setVerificationData(
            userName: userName,
            phoneNumber: phoneNumber,
            userCode: userCode,
            carrier: carrier);

        print('PIN 번호 생성 페이지로 이동: ${SignupRoutes.getPinSetupPath()}');
        context.go(SignupRoutes.getPinSetupPath());
      } else {
        print('케이스 3: 정보 없음');
        // 아무 정보도 없으면 회원가입 페이지로 이동
        print('회원가입 페이지로 이동: ${SignupRoutes.root}');
        context.go(SignupRoutes.root);
      }
    }
  }

  Future<void> _validateToken() async {
    final authRepository = ref.read(authRepositoryProvider);
    final secureStorage = ref.read(secureStorageProvider);

    try {
      // 토큰 재발급 시도
      print('토큰 재발급 시도');

      // <<<<<<<<<<<< [ 잰큰 사용할 때 여기도 수정! ] <<<<<<<<<<<<<<<<<<<<<<<<
      // 개발용 자동 로그인 코드 (출시 전 제거)
      // final isValid = await authRepository.reissueToken();
      final isValid = true;
      print('토큰 재발급 결과: $isValid');

      if (mounted) {
        if (isValid) {
          // 토큰이 유효하면 인증서와 userkey 확인
          final certificatePem =
              await secureStorage.read(key: StorageKeys.certificatePem);
          final userkey = await secureStorage.read(key: StorageKeys.userkey);

          print('🪪🪪인증서 확인: ${certificatePem != null ? '있음' : '없음'}');
          print('🪪🪪유저키 확인: ${userkey != null ? '있음' : '없음'}');

          if (certificatePem != null && userkey != null) {
            print('인증서와 유저키 모두 있음: budget 페이지로 이동');
            context.go('/budget');
          } else {
            // 토큰 유효하고
            // 인증서나 유저키가 없으면 인증서 만들러 가기
            // : splash page 에서 한 번 더 조건 필터링 합니다
            print('토큰 유효: 인증서 만들러 가기');
            context.go(SignupRoutes.getMyDataSplashPath());
          }
        } else {
          // 유효하지 않으면 로그인 페이지로 이동
          print('토큰 유효하지 않음: PIN 로그인 페이지로 이동');
          context.go(SignupRoutes.getPinLoginPath());
        }
      }
    } catch (e) {
      print('토큰 재발급 오류 발생: $e');
      if (mounted) {
        // 오류 발생시 로그인 페이지로 이동
        print('오류로 인해 PIN 로그인 페이지로 이동');
        context.go(SignupRoutes.getPinLoginPath());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('===== AuthCheckPage build 메서드 실행 =====');
    return Scaffold(
        body: CustomLoadingIndicator(
      text: '안녕하세요?',
      backgroundColor: AppColors.whiteLight,
    ));
  }
}
