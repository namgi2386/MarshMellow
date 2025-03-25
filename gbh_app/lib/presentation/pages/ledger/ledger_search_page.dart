import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/constants/icon_path.dart';

import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/presentation/widgets/custom_search_bar/custom_search_bar.dart';
import 'package:marshmellow/core/services/hive_service.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/no_recent_searches.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/recent_searches.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/searched_list.dart';

class LedgerSearchPage extends StatefulWidget {
  const LedgerSearchPage({super.key});

  @override
  State<LedgerSearchPage> createState() => _LedgerSearchPageState();
}

class _LedgerSearchPageState extends State<LedgerSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  // 최근 검색어 리스트
  List<String> _recentSearches = [];

  // 검색 결과 저장
  List<dynamic> _searchResults = [];

  // 현재 검색어
  String _currentSearchTerm = '';

  // 검색 상태 (검색 여부)
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  // 검색 히스토리 불러오기
  Future<void> _loadSearchHistory() async {
    final history = await SearchHistoryService.getSearchHistory();
    setState(() {
      _recentSearches = history;
    });
  }

  // 검색어 추가 메서드
  void _addSearchTerm(String term) async {
    if (term.trim().isEmpty) return;

    await SearchHistoryService.saveSearch(term);
    await _loadSearchHistory();
  }

  // 검색어 삭제 메서드
  void _removeSearchTerm(String term) async {
    await SearchHistoryService.removeSearchTerm(term);
    await _loadSearchHistory();
  }

  // 검색 수행 메서드
  void _performSearch(String term) async {
    if (term.trim().isNotEmpty) {
      _addSearchTerm(term);

      setState(() {
        _currentSearchTerm = term;
        _hasSearched = true;
        // 로딩 상태로 변경할 수도 있음
      });

      // 실제 검색 로직 구현 (API 호출 또는 로컬 데이터 필터링)
      final results = await _fetchSearchResults(term);

      setState(() {
        _searchResults = results;
      });

      // 키보드 닫기
      FocusScope.of(context).unfocus();
    }
  }

  // 검색 결과 가져오기 (실제 구현은 데이터 소스에 따라 다름)
  Future<List<dynamic>> _fetchSearchResults(String term) async {
    // 예시: API 호출 또는 로컬 데이터 필터링
    // 실제 구현은 데이터 소스에 따라 다름
    await Future.delayed(const Duration(milliseconds: 500)); // 예시 지연

    // 테스트용 더미 데이터
    return [
      {
        'id': '1',
        'title': '점심 식사',
        'date': '2025-03-26',
        'category': '식비',
        'amount': 12000,
        'isExpense': true,
      },
      {
        'id': '2',
        'title': '교통비',
        'date': '2025-03-25',
        'category': '교통',
        'amount': 5000,
        'isExpense': true,
      },
      // 더 많은 결과 추가...
    ]
        .where((item) =>
            item['title']
                .toString()
                .toLowerCase()
                .contains(term.toLowerCase()) ||
            item['category']
                .toString()
                .toLowerCase()
                .contains(term.toLowerCase()))
        .toList();
  }

  // 전체 검색어 삭제
  void _clearAllSearchHistory() async {
    await SearchHistoryService.clearSearchHistory();
    await _loadSearchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: '검색', actions: [
        IconButton(
          icon: SvgPicture.asset(IconPath.analysis),
          onPressed: () {},
        )
      ]),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CustomSearchBar(
                controller: _searchController,
                onChanged: (value) {},
                onSearchPressed: () => _performSearch(_searchController.text),
                onSubmitted: (value) => _performSearch(value),
              ),
            ),

            // 최근 검색어 섹션
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _recentSearches.isEmpty
                    ? const NoRecentSearches()
                    : RecentSearches(
                        searches: _recentSearches,
                        onClearAll: _clearAllSearchHistory,
                        onSearchTermSelected: (term) {
                          _searchController.text = term;
                          _performSearch(term);
                        },
                        onSearchTermDeleted: _removeSearchTerm,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
