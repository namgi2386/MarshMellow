import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/theme/app_colors.dart';

// 라우트
import 'package:go_router/go_router.dart';
import 'package:marshmellow/router/routes/cookie_routes.dart';

// 위젯
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/presentation/widgets/celebration/celebration.dart';
import 'package:marshmellow/presentation/widgets/loading/custom_loading_indicator.dart';

// ViewModel
import 'package:marshmellow/presentation/viewmodels/quit/quit_viewmodel.dart';

class QuitPage extends ConsumerStatefulWidget {
  const QuitPage({super.key});

  @override
  ConsumerState<QuitPage> createState() => _QuitPageState();
}

class _QuitPageState extends ConsumerState<QuitPage> {
  final _numberFormat = NumberFormat('#,###', 'ko_KR');

  @override
  void initState() {
    super.initState();

    //화면이 완전히 빌드된 후 컨페티 효과 표시 및 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // showRetirementCelebration(context);
      ref.read(quitViewModelProvider.notifier).loadAverageSpending();
    });
  }

  @override
  Widget build(BuildContext context) {
    final quitState = ref.watch(quitViewModelProvider);

    return Scaffold(
      appBar: CustomAppbar(
        title: '퇴사 망상',
        actions: [
          IconButton(
            onPressed: () => context.push(CookieRoutes.getQuitInfoPath()),
            icon: SvgPicture.asset(IconPath.question),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text('한달 평균 지출', style: AppTextStyles.bodyMedium),

                // averageSpending이 null이 아닐 때만 표시
                if (quitState.averageSpending != null)
                  Row(
                    children: [
                      Text(
                        _numberFormat.format(
                            quitState.averageSpending!.averageMonthlySpending),
                        style: AppTextStyles.modalMoneyTitle,
                      ),
                      const SizedBox(width: 5),
                      Text('원', style: AppTextStyles.bodyMedium),
                    ],
                  )

                // 여기에 추가 UI 요소를 넣을 수 있습니다
              ],
            ),
          ),

          // 로딩 인디케이터
          if (quitState.isLoading) const CustomLoadingIndicator(),
        ],
      ),
    );
  }
}
