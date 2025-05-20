import 'package:flutter/material.dart';

class SortOptionsWidget extends StatefulWidget {
  final String selectPrice;
  final Function(String) onSortChanged;

  const SortOptionsWidget({
    Key? key,
    required this.selectPrice,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  _SortOptionsWidgetState createState() => _SortOptionsWidgetState();
}

class _SortOptionsWidgetState extends State<SortOptionsWidget> {
  bool isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {
              setState(() {
                isCollapsed = !isCollapsed;
              });
            },
            child: _buildSortDropDown(),
          ),
        ),
      ),
    );
  }

  Widget _buildSortDropDown() {
    return DropdownButton<String>(
      value: widget.selectPrice,
      dropdownColor: Colors.white,
      underline: const SizedBox.shrink(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          widget.onSortChanged(newValue);
        }
      },
      items:
          <String>[
            "Sắp xếp",
            "Giá thấp - cao",
            "Giá cao - thấp",
            "A - Z",
            "Z - A",
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        (widget.selectPrice == "Sắp xếp")
                            ? Colors.grey
                            : (widget.selectPrice == value
                                ? Colors.blue
                                : Colors.grey),
                    fontWeight:
                        widget.selectPrice == value
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
      alignment: Alignment.center,
      iconSize: 24,
      isExpanded: false,
    );
  }
}
