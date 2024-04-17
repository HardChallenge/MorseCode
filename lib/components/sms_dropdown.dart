import 'package:flutter/material.dart';
import 'package:morse_code_project/utils/phone_prefixes.dart';

class SMSDropdown extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;

  const SMSDropdown({super.key, this.initialValue, this.onChanged});

  @override
  _SMSDropdownState createState() => _SMSDropdownState();
}

class _SMSDropdownState extends State<SMSDropdown> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedValue,
      onChanged: (String? value) {
        setState(() {
          _selectedValue = value;
        });
        if (widget.onChanged != null) {
          setState(() {
            widget.onChanged!(value!);
          });
        }
      },
      items: prefixes.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Center(
            child: Text(value, textAlign: TextAlign.center),
          ),
        );
      }).toList(),
    );
  }
}
