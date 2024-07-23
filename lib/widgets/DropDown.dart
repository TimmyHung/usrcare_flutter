import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class CustomDropdownButton extends StatelessWidget {
  final List<String> options;
  final String? label;
  final String? selectedValue;
  final String? errorText;
  final Function(String?) onChanged;

  const CustomDropdownButton({super.key, 
    required this.options,
    this.selectedValue,
    this.label,
    this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Text(
              label!,
              style: const TextStyle(
                fontSize: 22,
                color: Colors.black,
              ),
            ),
          DropdownButton2<String>(
            isExpanded: true,
            items: options
                .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            value: selectedValue,
            style: const TextStyle(color: Colors.black, fontSize: 22),
            onChanged: onChanged,
            buttonStyleData: ButtonStyleData(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black54,
                ),
                color: Colors.white,
              ),
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
              ),
              iconSize: 35,
              iconEnabledColor: Colors.black,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 60,
              padding: EdgeInsets.only(left: 14, right: 14),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 5.0, left: 10),
              child: Text(
                errorText!,
                style: const TextStyle(color: Colors.red, fontSize: 20),
              ),
            ),
        ],
      ),
    );
  }
}
