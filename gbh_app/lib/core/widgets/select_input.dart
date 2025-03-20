import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/widgets/modal.dart';

typedef ItemBuilder<T> = Widget Function(
    BuildContext context, T item, bool isSelected);

class SelectInput<T> extends StatefulWidget {
  final String label;
  final bool readOnly;
  final ValueChanged<T>? onItemSelected;
  final TextEditingController controller;
  final double? width;
  final List<T> items;
  final ItemBuilder<T> itemBuilder;
  final String Function(T)? displayStringForItem;

  const SelectInput({
    super.key,
    required this.label,
    required this.controller,
    required this.items,
    required this.itemBuilder,
    this.onItemSelected,
    this.readOnly = true,
    this.width,
    this.displayStringForItem,
  });

  @override
  State<SelectInput<T>> createState() => _SelectInputState<T>();
}

class _SelectInputState<T> extends State<SelectInput<T>> {
  bool _isFocused = false;
  T? _selectedItem;
  final FocusNode _focusNode = FocusNode(); 

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Modal(
          backgroundColor: AppColors.whiteLight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = _selectedItem == item;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedItem = item;
                          if (widget.displayStringForItem != null) {
                            widget.controller.text =
                                widget.displayStringForItem!(item);
                          } else {
                            widget.controller.text = item.toString();
                          }
                        });

                        if (widget.onItemSelected != null) {
                          widget.onItemSelected!(item);
                        }

                        Navigator.pop(context);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          widget.displayStringForItem != null
                              ? widget.displayStringForItem!(item)
                              : item.toString(),
                          style: AppTextStyles.bodyLargeLight.copyWith(
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        _isFocused ? AppColors.textPrimary : AppColors.textSecondary;
    final Color textColor =
        _isFocused ? AppColors.textPrimary : AppColors.textSecondary;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(_focusNode);
              _showBottomSheet();
            },
            child: Container(
              width: widget.width ?? screenWidth * 0.9,
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(5),
                color: AppColors.whiteLight,
              ),
              child: Stack(
                children: [
                  TextField(
                    focusNode: _focusNode,
                    controller: widget.controller,
                    readOnly: true,
                    onTap: _showBottomSheet,
                    cursorColor: textColor,
                    decoration: InputDecoration(
                      labelText: widget.label,
                      labelStyle: AppTextStyles.bodySmall.copyWith(
                        color: textColor,
                      ),
                      // 텍스트 필드 위젯이 container 안에 있기 때문에 기존에 정의된 테두리 없애기
                      // 자체적으로 정의한 테두리를 사용하기 위함함
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.only(
                        top: 16,
                        right: 40,
                      ),
                    ),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: textColor,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 10,
                    child: Icon(Icons.expand_circle_down_outlined,
                        size: 15, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ===================== 사용 예시 =====================
/*
// SelectInput 위젯 사용 예시

!!!!! 이것만 봐도 되는 간단한 사용법!!!! 

SelectInput<String>(
  label: "국가 선택",
  controller: _countryController,
  items: ["미국", "캐나다", "영국", "호주", "일본", "한국"],
  itemBuilder: (context, item, isSelected) => ListTile(
    title: Text(item),
  ),
  onItemSelected: (value) {
    print("선택된 국가: $value");
  },
),

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


// 1. 기본 사용법 (문자열 리스트)
final TextEditingController _countryController = TextEditingController();

SelectInput<String>(
  label: '국가 선택',
  controller: _countryController,
  items: ['미국', '캐나다', '영국', '호주', '일본', '한국'],
  itemBuilder: (context, item, isSelected) => ListTile(
    title: Text(item),
    trailing: isSelected ? Icon(Icons.check, color: Colors.green) : null,
  ),
  onItemSelected: (value) {
    print('선택된 국가: $value');
  },
)

// 2. 객체 리스트 사용
class Country {
  final String code;
  final String name;
  
  Country(this.code, this.name);
  
  @override
  String toString() => name;
}

final List<Country> countries = [
  Country('US', '미국'),
  Country('CA', '캐나다'),
  Country('UK', '영국'),
  Country('AU', '호주'),
  Country('JP', '일본'),
  Country('KR', '한국'),
];

final TextEditingController _countryObjectController = TextEditingController();

SelectInput<Country>(
  label: '국가 선택',
  controller: _countryObjectController,
  items: countries,
  itemBuilder: (context, country, isSelected) => ListTile(
    title: Text(country.name),
    subtitle: Text(country.code),
    trailing: isSelected ? Icon(Icons.check, color: Colors.green) : null,
  ),
  displayStringForItem: (country) => country.name, // 표시될 텍스트 지정
  onItemSelected: (selectedCountry) {
    print('선택된 국가 코드: ${selectedCountry.code}');
    print('선택된 국가 이름: ${selectedCountry.name}');
  },
)

*/