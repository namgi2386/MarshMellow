import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:marshmellow/presentation/widgets/bottom_navbar.dart';
import 'package:marshmellow/presentation/pages/ledger/ledger_page.dart';
import 'package:marshmellow/presentation/pages/finance/finance_page.dart';
import 'package:marshmellow/presentation/pages/budget/budget_page.dart';
import 'package:marshmellow/presentation/pages/cookie/cookie_page.dart';
import 'package:marshmellow/presentation/pages/my/my_page.dart';

/*
  하단 네비게이션바 로직
*/
class MainNavigator extends StatefulWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  _MainNavigatorState createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  // 아이콘 경로
  final List<String> _iconPaths = const [
    'assets/icons/nav/ledger_bk.svg',
    'assets/icons/nav/finance_bk.svg',
    'assets/icons/nav/budget_bk.svg',
    'assets/icons/nav/cookie_bk.svg',
    'assets/icons/nav/user_bk.svg',
  ];

  // 탭 이름
  final List<String> _labels = const [
    '가계',
    '자산',
    '예산',
    '쿠키',
    '마이',
  ];

  // 각 탭 페이지들
  final List<Widget> _pages = const [
    LedgerPage(),
    FinancePage(),
    BudgetPage(),
    CookiePage(),
    MyPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
        iconPaths: _iconPaths,
        labels: _labels,
      ),
    );
  }
}