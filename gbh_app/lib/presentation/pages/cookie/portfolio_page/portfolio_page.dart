import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_category_model.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_model.dart';
import 'package:marshmellow/di/providers/portfolio_providers.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/category_item.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/portfolio_form.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/presentation/widgets/custom_search_bar/custom_search_bar.dart';
import 'package:marshmellow/presentation/widgets/modal/modal.dart';
import 'package:marshmellow/presentation/viewmodels/portfolio/portfolio_viewmodel.dart';

class PortfolioPage extends ConsumerStatefulWidget {
  const PortfolioPage({super.key});

  @override
  ConsumerState<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends ConsumerState<PortfolioPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(portfolioViewModelProvider.notifier).loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final portfolioState = ref.watch(portfolioViewModelProvider);
    final categories = portfolioState.categories;
    final isLoading = portfolioState.isLoading;
    final errorMessage = portfolioState.errorMessage;

    return Scaffold(
      appBar: CustomAppbar(
        title: '포트폴리오',
        actions: [
          IconButton(
            onPressed: () {
              showCustomModal(
                context: context,
                backgroundColor: AppColors.background,
                child: const PortfolioForm(),
              );
            },
            icon: SvgPicture.asset(IconPath.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: CustomSearchBar(
                  controller: TextEditingController(),
                  onChanged: (value) {},
                  onSubmitted: (value) {},
                ),
              ),
              if (categories.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 300 / 260,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index]; // 인덱스 조정 로직 제거
                    return CategoryItem(
                      category: category,
                      onTap: () {},
                    );
                  },
                )
              else if (!isLoading && errorMessage == null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/characters/char_melong.png',
                          width: 120,
                          height: 120,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '아직 카테고리가 없습니다.\n우측 상단의 + 버튼을 눌러 카테고리를 추가해보세요.',
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return IconPath.filePdf;
      case 'doc':
      case 'docx':
        return IconPath.fileDoc;
      case 'xls':
      case 'xlsx':
        return IconPath.fileXls;
      case 'ppt':
      case 'pptx':
        return IconPath.filePpt;
      case 'jpg':
      case 'jpeg':
        return IconPath.fileJpg;
      case 'png':
        return IconPath.filePng;
      case 'svg':
        return IconPath.fileSvg;
      case 'txt':
        return IconPath.fileTxt;
      case 'zip':
      case 'rar':
        return IconPath.fileZip;
      case 'csv':
        return IconPath.fileCsv;
      default:
        return IconPath.fileText;
    }
  }
}
