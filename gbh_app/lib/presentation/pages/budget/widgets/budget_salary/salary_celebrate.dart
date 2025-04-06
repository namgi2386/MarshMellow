import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marshmellow/core/constants/icon_path.dart';

// 라우트
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/constants/storage_keys.dart';
import 'package:marshmellow/router/routes/cookie_routes.dart';

// 위젯
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/presentation/widgets/celebration/celebration.dart';

class SalaryCelebratePage extends StatefulWidget {
  const SalaryCelebratePage({super.key});

  @override
  State<SalaryCelebratePage> createState() => _SalaryCelebratePageState();
}

class _SalaryCelebratePageState extends State<SalaryCelebratePage> {
  final storage = FlutterSecureStorage();
  String userName = '';

  @override
  void initState() {
    super.initState();

    _loadSHowCelebration();
  }

  Future<void> _loadSHowCelebration() async {
    try {
      final name = await storage.read(key: StorageKeys.userName);

      if (name != null) {
        setState(() {
          userName = name;
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCelebrationPopup(
          context,
          titleText: '야호!',
          subtitleText: '${userName.isNotEmpty ? userName : '사용자'} 님의\n월급날입니다!',
        );
      });
    } catch (e) {
      // 에러 처리
      print('Error loading user name: $e');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(''),
        ],
      ),
    );
  }
}
