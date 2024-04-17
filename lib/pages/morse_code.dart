import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morse_code_project/components/sms_dropdown.dart';
import 'package:morse_code_project/utils/helper_functions.dart';
import 'package:morse_code_project/utils/morse_coding.dart';

import '../utils/alert_builder.dart';

class MorseCode extends StatefulWidget {
  const MorseCode({super.key});

  @override
  MorseCodeState createState() => MorseCodeState();
}

class MorseCodeState extends State<MorseCode> with SingleTickerProviderStateMixin {
  bool _isTransmitting = false;
  String _currentLetter = '-';
  String? _messageField = '', _messageImported = '', morseCodeToBeTransmitted = '';
  double componentSize = 120.0;
  String _textTransmitted = '';
  String _prefix = "Romania (+40)", _phoneNumber = "723 523 103";

  late TextEditingController _messageController;
  late TextEditingController _transmittedMessageController;

  Duration dotDuration = const Duration(milliseconds: 200);
  Duration dashDuration = const Duration(milliseconds: 500);
  Duration currentDuration = const Duration();

  Color _lightColor = Colors.black;

  void _animateCode(){
    setState(() {
      _lightColor = Colors.red;
    });
  }

  // Funcție pentru a anima codul Morse
  void _animateMorse(String morseCode) async {
    List<String> phrases = morseCode.trim().split('\n');
    for (int i = 0; i < phrases.length && _isTransmitting; i++) {
      String phrase = phrases[i];
      List<String> words = phrase.trim().split(RegExp(r"\s+"));
      for (int j = 0; j < words.length && _isTransmitting; j++) {
        String word = words[j];
        String? letter = morseToLetter[word];
        if (letter == null) {
          continue;
        }
        _currentLetter = letter;
        _textTransmitted += letter;
        setState(() {
          _transmittedMessageController.text = _textTransmitted;
        });
        List<String> letters = word.trim().split('');
        for (int k = 0; k < letters.length && _isTransmitting; k++) {
          if (letters[k] == '.') {
            currentDuration = dotDuration;
            _animateCode();
            debugPrint("Dot");
          } else if (letters[k] == '-') {
            currentDuration = dashDuration;
            _animateCode();
            debugPrint("Dash");
          }
          // Așteaptă durata curentă înainte de a trece la următoarea literă
          await Future.delayed(currentDuration);
          setState(() {
            // Resetarea culorii la negru după expirarea duratei
            _lightColor = Colors.black;
          });
          // Așteaptă un scurt timp între luminare și stingere
          await Future.delayed(currentDuration);
        }
        // Așteaptă 500ms între litere
        await Future.delayed(Duration(milliseconds: 500));
      }
    }
  }




  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _transmittedMessageController = TextEditingController(text: _textTransmitted);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _transmittedMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SingleChildScrollView upper = SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: AnimatedContainer(
              duration: Duration(milliseconds: currentDuration.inMilliseconds),
              width: componentSize,
              height: componentSize,
              decoration: BoxDecoration(
                color: _lightColor,
                shape: BoxShape.circle,
              ),
              curve: Curves.easeInOut,
            ),
          ),
          SizedBox(width: componentSize / 5.0),
          Expanded(
            flex: 1,
            child: Text(
              _currentLetter,
              style: TextStyle(fontSize: componentSize / 2.0, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );

    ImportWrapper wrapper = ImportWrapper(_prefix, _phoneNumber);

    SingleChildScrollView lowerStandBy = SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _messageController,
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
                  _messageField = value;
                });
              },
            ),
            const SizedBox(height: 20.0),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context){
                            return Center(
                                child: SingleChildScrollView(
                                    child: AlertDialog(
                                        title: const Text(
                                            'Se va importa primul Morse Code din lista de mesaje SMS cu numarul de telefon selectat.',
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            )
                                        ),
                                        content: buildImportContent(wrapper),
                                        actions: [
                                          Align(
                                              alignment: Alignment.center,
                                              child: TextButton(
                                                // align it on center
                                                onPressed: () async {
                                                  _prefix = wrapper.prefix;
                                                  _phoneNumber = wrapper.phoneNumber;
                                                  String phoneNumber = _prefix.substring(_prefix.indexOf("(") + 1, _prefix.indexOf(")")) + _phoneNumber.trim().replaceAll(" ", "");
                                                  String response = (await getFirstMorseMessageWith(phoneNumber))!;
                                                  if (response != ''){
                                                    _messageImported = response;
                                                  }
                                                  debugPrint("Message imported: $_messageImported");
                                                  setState(() {});
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text('Importă'),
                                              )
                                          )
                                        ]
                                    )
                                )
                            );
                          }
                      );
                    },
                    child: Text("Importa mesaj din SMS"),
                  ),
                  const SizedBox(width: 20.0),
                  _messageImported!.isEmpty ? const SizedBox(width: 0, height: 0) :
                                              TextButton(
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext context){
                                                        return AlertDialog(
                                                          title: const Center(child: Text('Mesaj importat')),
                                                          content: SingleChildScrollView(
                                                            child: TextField(
                                                              readOnly: true,
                                                              maxLines: 5,
                                                              controller: TextEditingController(text: _messageImported),
                                                            ),
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                              },
                                                              child: const Center(child:Text('OK')),
                                                            )
                                                          ],
                                                        );
                                                      }
                                                  );
                                                },
                                                child: const Icon(Icons.check, color: Colors.green, size: 40.0),
                                              )
                ],
                )
              ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_messageField!.isEmpty && _messageImported!.isEmpty){
                    buildDialog(context, 'Eroare', 'Introduceți un mesaj sau importați unul din SMS-uri.');
                    return;
                  }
                  if (_messageImported!.isNotEmpty){
                    // Prioritize the imported message
                    morseCodeToBeTransmitted = _messageImported!;
                  } else {
                    morseCodeToBeTransmitted = fromTextToMorse(_messageField!);
                  }
                  componentSize *= 2;
                  _isTransmitting = true;
                  _animateMorse(morseCodeToBeTransmitted!);
                });
              },
              child: Text("Transmite mesaj"),
            ),
          ],
        )
    );

    SingleChildScrollView lowerTransmitting = SingleChildScrollView(
        child: Column(
          children: [
            TextField(
                controller: _transmittedMessageController,
                readOnly: true,
                maxLines: 5,
                decoration: const InputDecoration(
                    labelText: 'Mesaj transmis'
                )
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentLetter = '-';
                  _lightColor = Colors.red;
                  _textTransmitted = '';
                  setState(() {
                    _transmittedMessageController.text = _textTransmitted;
                  });
                  componentSize /= 2;
                  _isTransmitting = false;
                });
              },
              child: Text("STOP"),
            ),
          ],
        )
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              upper,
              const SizedBox(height: 20.0),
              _isTransmitting ? lowerTransmitting : lowerStandBy
            ],
          ),
        ),
      ),
    );
  }
}
