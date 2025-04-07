import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_model.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/portfolio_delete_confirm.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/portfolio_fields.dart';
import 'package:marshmellow/presentation/viewmodels/portfolio/portfolio_viewmodel.dart';
import 'package:marshmellow/presentation/widgets/button/button.dart';
import 'package:marshmellow/presentation/widgets/completion_message/completion_message.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/portfolio_field.dart';
import 'dart:io';

class PortfolioDetailModal extends ConsumerStatefulWidget {
  final Portfolio portfolio;

  const PortfolioDetailModal({
    Key? key,
    required this.portfolio,
  }) : super(key: key);

  @override
  ConsumerState<PortfolioDetailModal> createState() =>
      _PortfolioDetailModalState();
}

class _PortfolioDetailModalState extends ConsumerState<PortfolioDetailModal> {
  late Portfolio _portfolio;
  bool _isEditing = false;
  bool _isLoading = false;

  // 편집 관련 변수
  String _fileName = "";
  String _memo = "";
  String _category = "";
  int? _categoryPk;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _portfolio = widget.portfolio;
    _initializeValues();
  }

  void _initializeValues() {
    _fileName = _portfolio.fileName;
    _memo = _portfolio.portfolioMemo;
    _category = _portfolio.portfolioCategory?.portfolioCategoryName ?? "미분류";
    _categoryPk = _portfolio.portfolioCategory?.portfolioCategoryPk ?? -1;

    // 날짜 및 시간 파싱
    if (_portfolio.createDate != null && _portfolio.createTime != null) {
      try {
        final dateStr = _portfolio.createDate!;
        final timeStr = _portfolio.createTime!;

        if (dateStr.length >= 8 && timeStr.length >= 4) {
          final year = int.parse(dateStr.substring(0, 4));
          final month = int.parse(dateStr.substring(4, 6));
          final day = int.parse(dateStr.substring(6, 8));

          final hour = int.parse(timeStr.substring(0, 2));
          final minute = int.parse(timeStr.substring(2, 4));
          final second =
              timeStr.length >= 6 ? int.parse(timeStr.substring(4, 6)) : 0;

          _selectedDate = DateTime(year, month, day, hour, minute, second);
        } else {
          _selectedDate = DateTime.now();
          print('날짜/시간 형식 오류: 길이가 충분하지 않음');
        }
      } catch (e) {
        // 날짜 파싱 오류 시 현재 시간 사용
        _selectedDate = DateTime.now();
        print('날짜 파싱 오류: $e');
      }
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // 편집 모드 취소 시 원래 값으로 복원
        _initializeValues();
      }
    });
  }

  // 파일명 업데이트
  void _updateFileName(String fileName) {
    setState(() {
      _fileName = fileName;
    });
  }

  // 메모 업데이트
  void _updateMemo(String memo) {
    setState(() {
      _memo = memo;
    });
  }

  // 카테고리 업데이트
  void _updateCategory(String categoryName, int categoryPk) {
    setState(() {
      _category = categoryName;
      _categoryPk = categoryPk;
    });
  }

  // 날짜 업데이트
  void _updateDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  // 파일 열기
  Future<void> _openFile() async {
    if (_portfolio.fileUrl == null) {
      CompletionMessage.show(context, message: '파일 오류');
      return;
    }

    final uri = Uri.parse(_portfolio.fileUrl!);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          CompletionMessage.show(context, message: '파일 오류');
        }
      }
    } catch (e) {
      if (context.mounted) {
        CompletionMessage.show(context, message: '오류 발생: $e');
      }
    }
  }

  // 포트폴리오 업데이트
  Future<void> _updatePortfolio() async {
    if (_fileName.isEmpty) {
      CompletionMessage.show(context, message: '파일명을 입력하세요');
      return;
    }

    // 키보드 닫기
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedPortfolio =
          await ref.read(portfolioViewModelProvider.notifier).updatePortfolio(
                portfolioPk: _portfolio.portfolioPk ?? 0,
                portfolioCategoryPk: _categoryPk ?? -1,
                fileName: _fileName,
                portfolioMemo: _memo,
              );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (updatedPortfolio != null) {
        // 성공 메시지 표시
        CompletionMessage.show(context, message: '수정 완료');

        // 모달 닫기 및 데이터 새로고침은 약간의 지연 후 실행
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop();
            ref.read(portfolioViewModelProvider.notifier).loadData();
          }
        });
      } else {
        final errorMessage = ref.read(portfolioViewModelProvider).errorMessage;
        CompletionMessage.show(context, message: errorMessage ?? '수정 실패');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      CompletionMessage.show(context, message: '오류 발생: $e');
    }
  }

  // 포트폴리오 삭제
  Future<void> _deletePortfolio() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref
          .read(portfolioViewModelProvider.notifier)
          .deletePortfolio(_portfolio.portfolioPk ?? 0);

      if (success) {
        if (context.mounted) {
          CompletionMessage.show(context, message: '삭제 완료');
          Navigator.of(context).pop(true); // 삭제 성공 시 true 반환하며 닫기
        }
      } else {
        setState(() {
          _isLoading = false;
        });

        if (context.mounted) {
          final errorMessage =
              ref.read(portfolioViewModelProvider).errorMessage;
          CompletionMessage.show(context, message: errorMessage ?? '삭제 실패');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (context.mounted) {
        CompletionMessage.show(context, message: '오류 발생: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 파일 정보 헤더
              _buildFileHeader(),

              const Divider(
                  height: 1, thickness: 1, color: AppColors.greyLight),

              // 폼 필드들
              _buildFormFields(context),
            ],
          ),
        ),

        // 하단 버튼 영역
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomButtons(),
        ),
      ],
    );
  }

  // 파일 정보 헤더 위젯
  Widget _buildFileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 원본 파일명 텍스트
              Expanded(
                child: Text(
                  _portfolio.originFileName,
                  style: AppTextStyles.modalTitle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              // 파일 열기 아이콘
              GestureDetector(
                onTap: _openFile,
                child: SvgPicture.asset(
                  IconPath.paperclip,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    AppColors.textPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }

  // 폼 필드들 위젯
  Widget _buildFormFields(BuildContext context) {
    // 포트폴리오 상태 가져오기
    final portfolioState = ref.watch(portfolioViewModelProvider);

    return Container(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          // 카테고리 필드
          PortfolioFields.categoryField(
            context: context,
            ref: ref,
            selectedCategory: _category,
            onCategorySelected: _updateCategory,
            enabled: true,
          ),

          // 파일명 필드
          PortfolioFields.editableFileNameField(
            fileName: _fileName,
            onFileNameChanged: _updateFileName,
            enabled: true,
          ),

          // 메모/키워드 필드
          PortfolioFields.editableMemoField(
            memo: _memo,
            onMemoChanged: _updateMemo,
            enabled: true,
          ),

          // 날짜 필드 (읽기 전용)
          PortfolioField(
            label: '등록일',
            value: _formatDate(),
          ),
        ],
      ),
    );
  }

  // 날짜 안전하게 표시
  String _formatDate() {
    final dateStr = _portfolio.createDate;
    final timeStr = _portfolio.createTime;

    if (dateStr == null || dateStr.length < 8) {
      return '날짜 정보 없음';
    }

    final year = dateStr.substring(0, 4);
    final month = dateStr.substring(4, 6);
    final day = dateStr.substring(6, 8);

    String time = '';
    if (timeStr != null && timeStr.length >= 4) {
      final hour = timeStr.substring(0, 2);
      final minute = timeStr.substring(2, 4);
      time = '$hour:$minute';
    }

    return '$year년 $month월 $day일 $time';
  }

  // 하단 버튼 위젯
  Widget _buildBottomButtons() {
    return Container(
      child: Row(
        children: [
          // 삭제 버튼
          Expanded(
            child: Button(
              text: "삭제",
              onPressed: _isLoading ? null : _deletePortfolio,
              isDisabled: _isLoading,
              textStyle: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
                fontSize: 14,
              ),
              width: double.infinity,
              height: 50,
            ),
          ),
          const SizedBox(width: 10),
          // 저장 버튼
          Expanded(
            child: Button(
              text: "수정",
              onPressed: _isLoading ? null : _updatePortfolio,
              isDisabled: _isLoading,
              width: double.infinity,
              height: 50,
            ),
          ),
        ],
      ),
    );
  }
}
