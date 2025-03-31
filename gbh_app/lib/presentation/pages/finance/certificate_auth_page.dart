import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/presentation/widgets/keyboard/index.dart';
import 'package:marshmellow/presentation/widgets/loading/loading_manager.dart';
import 'package:marshmellow/router/routes/finance_routes.dart';

class CertificateAuthPage extends ConsumerStatefulWidget {
  final String accountNo;
  final int withdrawalAccountId;

  const CertificateAuthPage({
    Key? key,
    required this.accountNo,
    required this.withdrawalAccountId, // 생성자 매개변수 추가
  }) : super(key: key);

  @override
  ConsumerState<CertificateAuthPage> createState() => _CertificateAuthPageState();
}

class _CertificateAuthPageState extends ConsumerState<CertificateAuthPage> {
  final TextEditingController _pinController = TextEditingController();
  String _pinValue = '';
  int _wrongAttempts = 0;
  bool _isLoading = false;

  // 임시 비밀번호 (실제로는 서버에서 검증)
  static const String _tempCorrectPin = '123456';

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  // PIN 입력 및 검증
  void _verifyPin() async {
    setState(() {
      _isLoading = true;
    });

    // 실제 앱에서는 API 호출로 대체
    await Future.delayed(const Duration(seconds: 1));

    if (_pinValue == _tempCorrectPin) {
      // 인증 성공
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        // 송금 페이지로 이동
        context.push(
          FinanceRoutes.getTransferPath(), 
          extra: {'accountNo': widget.accountNo, 'withdrawalAccountId': widget.withdrawalAccountId,}
        );
      }
    } else {
      // 인증 실패
      setState(() {
        _isLoading = false;
        _wrongAttempts++;
        _pinValue = '';
        _pinController.text = '';
      });

      if (_wrongAttempts >= 5) {
        // 5회 실패 시 뒤로 가기
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('인증 시도 횟수를 초과했습니다.')),
          );
          context.pop();
        }
      } else {
        // 오류 메시지 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('인증번호가 일치하지 않습니다. (${_wrongAttempts}/5)')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('인증서 비밀번호 입력'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '인증서 비밀번호 6자리를 입력해주세요',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  '송금 승인을 위해 인증서 비밀번호가 필요합니다.',
                  style: TextStyle(fontSize: 14, color: AppColors.blackLight),
                ),
                const SizedBox(height: 40),
                
                // PIN 입력 필드
                TextField(
                  controller: _pinController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: '6자리 PIN 번호',
                    errorText: _wrongAttempts > 0 ? '인증번호가 일치하지 않습니다. (${_wrongAttempts}/5)' : null,
                  ),
                  textAlign: TextAlign.center,
                  onTap: () async {
                    setState(() {
                      _pinValue = '';
                      _pinController.text = '';
                    });
                    
                    await KeyboardModal.showSecureNumericKeyboard(
                      context: context,
                      onValueChanged: (value) {
                        setState(() {
                          _pinValue = value;
                          _pinController.text = '•' * value.length;
                        });
                      },
                      initialValue: '',
                      maxLength: 6, // 6자리 핀번호
                      obscureText: true,
                    );
                    
                    // PIN 입력 완료 후 자동 검증
                    if (_pinValue.length == 6) {
                      _verifyPin();
                    }
                  },
                ),
                
                const SizedBox(height: 40),
                
                ElevatedButton(
                  onPressed: _pinValue.length == 6 ? _verifyPin : null,
                  child: const Text('확인'),
                ),
              ],
            ),
          ),
    );
  }
}