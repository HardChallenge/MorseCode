import 'package:flutter/material.dart';
import 'package:morse_code_project/components/sms_dropdown.dart';

class Wrapper{
  Map<dynamic, dynamic> obj = {};

  Wrapper(this.obj);
}

SingleChildScrollView buildImportContent(Wrapper wrapper){
  SMSDropdown dropdown = SMSDropdown(
    initialValue: wrapper.obj["prefix"]
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
          wrapper.obj["phoneNumber"] = value;
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

SingleChildScrollView buildMorseTransmissionContent(Wrapper wrapper){
  return SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: wrapper.obj["dotDurationController"],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Dot duration (ms)',
            prefixIcon: Icon(Icons.timer),
            border: OutlineInputBorder(),
          ),
          onChanged: (String value) {
            if (value.isEmpty) {
              return;
            }
            try {
              wrapper.obj["dotDuration"] = Duration(milliseconds: int.parse(value));
            } catch (e) {
              print(e);
            }
          }),
        const SizedBox(height: 20),
        TextField(
          controller: wrapper.obj["dashDurationController"],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Dash duration (ms)',
            prefixIcon: Icon(Icons.timer),
            border: OutlineInputBorder(),
          ),
          onChanged: (String value) {
            if (value.isEmpty) {
              return;
            }
            try {
              wrapper.obj["dashDuration"] = Duration(milliseconds: int.parse(value));
            } catch (e) {
              print(e);
            }
          }),
        const SizedBox(height: 20),
        TextField(
          controller: wrapper.obj["betweenMorseDurationController"],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Between morse (ms)',
            prefixIcon: Icon(Icons.timer),
            border: OutlineInputBorder(),
          ),
          onChanged: (String value) {
            if (value.isEmpty) {
              return;
            }
            try {
              wrapper.obj["betweenMorseDuration"] = Duration(milliseconds: int.parse(value));
            } catch (e) {
              print(e);
            }
          }
        ),
        const SizedBox(height: 20),
        TextField(
          controller: wrapper.obj["betweenLettersDurationController"],
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Between letters (ms)',
            prefixIcon: Icon(Icons.timer),
            border: OutlineInputBorder(),
          ),
          onChanged: (String value) {
            if (value.isEmpty) {
              return;
            }
            try {
              wrapper.obj["betweenLettersDuration"] = Duration(milliseconds: int.parse(value));
            } catch (e) {
              print(e);
            }
          }),
        const SizedBox(height: 20),
        TextField(
            controller: wrapper.obj["betweenWordsDurationController"],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Between words (ms)',
              prefixIcon: Icon(Icons.timer),
              border: OutlineInputBorder(),
            ),
            onChanged: (String value) {
              if (value.isEmpty) {
                return;
              }
              try {
                wrapper.obj["betweenWordsDuration"] = Duration(milliseconds: int.parse(value));
              } catch (e) {
                print(e);
              }
            })
      ],
    )
  );
}