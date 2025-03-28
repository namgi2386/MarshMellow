import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/di/providers/auth/mydata_provider.dart';
import 'package:marshmellow/presentation/pages/auth/widgets/etc/certification_select_content.dart';
import 'package:marshmellow/presentation/widgets/button/button.dart';

/*
  마이데이터 연동 동의서 페이지
*/
class AuthMydataAgreementPage extends ConsumerStatefulWidget{
  const AuthMydataAgreementPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthMydataAgreementPage> createState() => _AuthMydataAgreementPageState();
}

class _AuthMydataAgreementPageState extends ConsumerState<AuthMydataAgreementPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // 사용자가 스크롤하여 문서의 맨 아래에 도달하면 && 스크롤이 유효한 범위안에 있는지(물리적 관성으로 일시적으로 유효 범위를 초과할수도 있으므로..?)
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
    !_scrollController.position.outOfRange) {
      ref.read(agreementStateProvider.notifier).setAtBottom(true);
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent, 
      duration: const Duration(milliseconds: 300), 
      curve: Curves.easeOut,
    );
  }

  void _handleAgreementSubmit() {
   showCertificateModal(
      context: context, 
      ref: ref, 
      userName: '손효자', 
      expiryDate: '2028.03.14.', 
      onConfirm: () {
        // TODO: 여기서 인증서 확인 작업 필요
        // 서버에 개인키해싱값 전달 응답 받기
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agreementStateProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, ),
          child : Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        '내 자산 목록을 가져옵니다.\n아래를 읽고 동의해 주세요.',
                        style: AppTextStyles.mainTitle,
                      ),
                      const SizedBox(height: 30),

                      Text(
                        '개인신용정보 전송요구 및 수집, 이용',
                        style: AppTextStyles.bodyMediumLight.copyWith(color: AppColors.disabled),
                      ),
                      const SizedBox(height: 30),

                      Text(
                        '정보제공자',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.disabled),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '한국은행, 산업은행, 기업은행, 국민은행, 농협은행, 우리은행, sc제일은행, 시티은행, 대구은행, 광주은행, 제주은행, 전북은행, 경남은행, 새마울금고, KEB하나은행, 신한은행, 카카오뱅크, 싸피은행, KB국민카드, 삼성카드, 롯데카드, 우리카드, 신한카드, 현대카드, BC바로카드, NH농협카드, 하나카드, IBK기업은행',
                        style: AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.disabled),
                      ),
                      const SizedBox(height: 30),

                      Text(
                        '정보수신자',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.disabled),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'MM(MarshMellow)',
                        style: AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.disabled),
                      ),
                      const SizedBox(height: 30),

                      Text(
                        '전송 정보',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.disabled),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.whiteLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.disabled)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                _bulletPoint('카드 : 카드 목록 및 선불 카드 목록'),
                                _bulletPoint('보험 : 보험증권 목록, 대출계좌 목록, 피보험자 보험 목록, 개인형 IRP 계좌 목록 및 DC 형 퇴직연금 목록'),
                                _bulletPoint('페이머니 : 선불전자지급수단 목록 및 계정 목록'),
                                _bulletPoint('증권 : 계좌 목록, 개인형 IRP 계좌 목록 및  DC형 퇴직연금 목록'),
                                _bulletPoint('전자서명, 접근토큰, 인증서, 전송요구서'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '수집, 이용 항목 상세 보기 >',
                              style: AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.whiteDark)
                            ),
                          ]
                        )
                      ),
                      const SizedBox(height: 30),

                      Text(
                        '전송 목적',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.disabled),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '상세정보 전송요구를 위한 가입상품목록 조회',
                        style: AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.disabled),
                      ),
                      const SizedBox(height: 30),

                      Text(
                        '정보 보유, 이용기간 및 전송 요구 종료 시점',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.disabled),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '상세 정보 전송 요구 시까지\n또는 7일 중 짧은 기간',
                        style: AppTextStyles.bodyLargeLight,
                      ),
                      const SizedBox(height: 30),

                      Text(
                        '가입상품목록 조회의 경우 정기전송을 하지 않습니다. MM이 위 정보를 수집, 이용하는 것을 거부할 수 있으나, 그러한 경우 본인신용정보 통합조회, 데이터 분석 서비스 이용이 제한됩니다.',
                        style: AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.disabled)
                      ),
                      const SizedBox(height: 30),

                      Text(
                        '데이터 자동 업데이트 여부',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.disabled),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '아니요',
                        style: AppTextStyles.bodyLargeLight,
                      ),
                      const SizedBox(height: 30),

                      Text(
                        '개인신용정보 제공',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.disabled),
                      ),
                      const SizedBox(height: 8),
                      _comparisonTable(),
                      const SizedBox(height: 30),
                      _agreementCheckBox(
                        isChecked: state.firstAgreement,
                        onTap: () => ref.read(agreementStateProvider.notifier).toggleFirstAgreement(),
                        text: '위 개인신용정보 수집, 이용에 동의합니다'
                      ),
                      const SizedBox(height: 12),
                      _agreementCheckBox(
                        isChecked: state.secondAgreement,
                        onTap: () => ref.read(agreementStateProvider.notifier).toggleSecondAgreement(),
                        text: '위 개인신용정보 제공에 동의합니다'
                      )
                    ],
                  ),
                ),
              )
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Button(
                text: state.isAtBottom ? '모두 동의하고 가져오기' : '아래로 내리기',
                width: screenWidth * 0.9,
                height: 60,
                onPressed: state.isButtonEnabled
                    ? _handleAgreementSubmit
                    : state.isAtBottom
                        ? null
                        : _scrollToBottom,
                isDisabled: state.isAtBottom && !state.isButtonEnabled,
              )
            )
          ],
        ))
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.disabled)),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.disabled),
            )
          )
        ],
      )
    );
  }

  Widget _agreementCheckBox({
    required bool isChecked,
    required VoidCallback onTap,
    required String text,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isChecked ? AppColors.backgroundBlack : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isChecked ? AppColors.backgroundBlack : AppColors.disabled,
              ),
            ),
            child: Icon(
              Icons.check,
              color: isChecked ? AppColors.whiteLight : Colors.transparent,
              size: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.bodyMediumLight.copyWith(fontWeight:FontWeight.w300)),
        ],
      ),
    );
  }

  Widget _comparisonTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: [
            _tableCell('제공 받는 자', isHeader: true),
            _tableCell('한국신용정보원', isHeader: true),
            _tableCell('내 정보제공자', isHeader: true),
          ],
        ),
        TableRow(
          decoration: BoxDecoration(color: AppColors.whiteLight),
          children: [
            _tableCell('제공 목적'),
            _tableCell('마이데이터 서비스 개인정보 및 연결요구 내역 조회'),
            _tableCell('원천 정보 및 개인신용정보 조회'),
          ],
        ),
        TableRow(
          decoration: BoxDecoration(color: AppColors.whiteLight),
          children: [
            _tableCell('보유 및 이용 기간'),
            _tableCell('제공 목적 달성시까지'),
            _tableCell('제공 목적 달성시까지'),
          ],
        ),
        TableRow(
          decoration: BoxDecoration(color: AppColors.whiteLight),
          children: [
            _tableCell('제공 항목'),
            _tableCell('본인확인정보, 서비스코드, 서비스이름, 인증제휴사정보, 클라이언트정보, 마이데이터사업자, 인터페이스정보, API정보, 전송요구동의정보'),
            _tableCell('본인확인 CI, 이름, 생년월일, 성별 등'),
          ],
        ),
      ],
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: isHeader 
            ? AppTextStyles.bodyExtraSmall
            : AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.disabled),
        textAlign: isHeader ? TextAlign.center : TextAlign.left,
      ),
    );
  }
}