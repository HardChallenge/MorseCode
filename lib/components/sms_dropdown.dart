import 'package:flutter/material.dart';
import 'package:morse_code_project/utils/phone_prefixes.dart';

class SMSDropdown extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;

  const SMSDropdown({super.key, this.initialValue, this.onChanged});

  @override
  SMSDropdownState createState() => SMSDropdownState();
}

class SMSDropdownState extends State<SMSDropdown> {
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child:DropdownButton<String>(
              underline: Container(),
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
          )
        )
    );
  }
}
