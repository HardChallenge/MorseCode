import 'package:flutter/material.dart';
import 'package:morse_code_project/components/sms_dropdown.dart';

class ImportWrapper{
  String prefix, phoneNumber;

  ImportWrapper(this.prefix, this.phoneNumber);
}

SingleChildScrollView buildImportContent(ImportWrapper wrapper){
  SMSDropdown dropdown = SMSDropdown(
    initialValue: wrapper.prefix
  );

  Flexible phoneInput = Flexible(
    fit: FlexFit.loose,
    child: TextField(
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        labelText: 'Număr de telefon',
        hintText: 'Introduceți numărul de telefon',
        prefixIcon: Icon(Icons.phone),
        border: OutlineInputBorder(),
      ),
      onChanged: (String value) {
          wrapper.phoneNumber = value;
      }),
    );

  return SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dropdown,
        const SizedBox(height: 20),
        phoneInput
      ]
    )
  );
}