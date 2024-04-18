import 'package:flutter/material.dart';
import 'package:morse_code_project/components/sms_dropdown.dart';
import 'package:morse_code_project/utils/helper_functions.dart';
import 'dart:developer' as developer;

class SendSMS extends StatefulWidget {
  const SendSMS({super.key});

  @override
  _SendSMSState createState() => _SendSMSState();
}

class _SendSMSState extends State<SendSMS> {
  String _prefix = "Romania (+40)",
      _phoneNumber = '',
      _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Convert text to Morse Code and send it via SMS",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              SMSDropdown(
                initialValue: _prefix,
                onChanged: (String value) {
                    _prefix = value;
                },
              ),
              const SizedBox(height: 20),
              Flexible(
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
                    setState(() {
                      _phoneNumber = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                fit: FlexFit.loose,
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Mesaj',
                    hintText: 'Introduceți mesajul',
                    prefixIcon: Icon(Icons.message),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _message = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                  onPressed: () {
                    if (_message.isEmpty) {
                      buildErrorDialog(context, "Eroare", "Mesjaul transmis nu poate fi gol.");
                      return;
                    }
                    if (_phoneNumber.isEmpty) {
                      buildErrorDialog(context, "Eroare", "Numărul de telefon nu poate fi gol.");
                      return;
                    }
                    String recipient = _prefix.substring(_prefix.indexOf("(") + 1, _prefix.indexOf(")")) + _phoneNumber.trim().replaceAll(" ", "");
                    sendMorseCode(_message, recipient);
                  },
                  child: const Text('Send'),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
