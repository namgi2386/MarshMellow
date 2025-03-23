import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/widgets/input_logic.dart';

class RoundInput extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? errorText;
  final double? height;
  final double? width;

  const RoundInput({
    super.key,
    this.onChanged,
    this.onTap,
    this.controller,
    this.focusNode,
    this.errorText,
    this.width,
    this.height,
  });

  @override
  State<RoundInput> createState() => _RoundInputState();
}

class _RoundInputState extends State<RoundInput> {
  late InputLogic _inputLogic;

  @override
  void initState() {
    super.initState();
    _inputLogic = InputLogic(
      externalFocusNode: widget.focusNode,
      externalController: widget.controller,
      onStateChanged: () => setState(() {}),
    );
  }

  @override
  void didUpdateWidget(RoundInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _inputLogic.dispose();
      _inputLogic = InputLogic(
        externalFocusNode: widget.focusNode,
        externalController: widget.controller,
        onStateChanged: () => setState(() {}),
      );
    }
    if (widget.controller != oldWidget.controller) {
      _inputLogic.updateController(widget.controller);
    }
  }

  @override
  void dispose() {
    _inputLogic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: widget.width ?? screenWidth * 0.9,
            height: widget.height ?? 50,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.textPrimary, width: 1.5),
              borderRadius: BorderRadius.circular(30),
              color: AppColors.whiteLight,
            ),
            child: TextField(
              controller: _inputLogic.controller,
              focusNode: _inputLogic.focusNode,
              onChanged: (value) {
                if (widget.onChanged != null) {
                  widget.onChanged!(value);
                }
              },
              onTap: widget.onTap,
              cursorColor: AppColors.textPrimary,
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (widget.errorText != null)
            Container(
              width: widget.width ?? screenWidth * 0.9,
              padding: const EdgeInsets.only(left: 16, top: 4),
              margin: const EdgeInsets.only(bottom: 23),
              child: Text(
                widget.errorText!,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w300,
                  color: AppColors.warnning,
                ),
              ),
            ),
          if (widget.errorText == null) const SizedBox(height: 23),
        ],
      ),
    );
  }
}


// ===================== 사용 예시 =====================
/*
// RoundInput 위젯 사용 예시

// 1. 기본 사용법
RoundInput(
  onChanged: (value) {
    print('입력값: $value');
  },
)

// 2. 컨트롤러를 사용한 방법
final TextEditingController _roundController = TextEditingController();

RoundInput(
  controller: _roundController,
  onChanged: (value) {
    print('입력된 값: $value');
    // 컨트롤러를 통해서도 접근 가능: _roundController.text
  },
)

// 3. 유효성 검증 사용 예시
String? _searchError;

void _validateSearch(String search) {
  if (search.isEmpty) {
    setState(() => _searchError = null);
  } else if (search.length < 2) {
    setState(() => _searchError = '최소 2자 이상 입력해주세요');
  } else {
    setState(() => _searchError = null);
  }
}

RoundInput(
  errorText: _searchError,
  onChanged: (value) {
    _validateSearch(value);
    print('검색어: $value');
  },
)

// 4. 높이 및 너비 조정 예시
RoundInput(
  height: 30, // 지정된 높이로 설정
  width: 250, // 지정된 너비로 설정
  onChanged: (value) {
    print('입력값: $value');
  },
)

// 5. 탭 이벤트 사용 예시
RoundInput(
  controller: _locationController,
  onTap: () {
    // 위치 선택 다이얼로그 표시
    showModalBottomSheet(
      context: context,
      builder: (context) => LocationPickerSheet(
        onLocationSelected: (location) {
          _locationController.text = location;
        },
      ),
    );
  },
)

// 6. 포커스 노드 사용 예시
final FocusNode _searchFocusNode = FocusNode();

@override
void dispose() {
  _searchFocusNode.dispose();
  super.dispose();
}

RoundInput(
  focusNode: _searchFocusNode,
  onChanged: (value) {
    print('검색어: $value');
  },
)
*/