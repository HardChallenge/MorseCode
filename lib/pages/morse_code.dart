import 'dart:async';

import 'package:flutter/material.dart';
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
  bool _hasTorch = false, _useTorch = false;

  late TextEditingController _messageController;
  late TextEditingController _transmittedMessageController;
  late TextEditingController dotDurationController, dashDurationController, betweenLettersDurationController, betweenWordsDurationController;

  Duration dotDuration = const Duration(milliseconds: 100);
  Duration dashDuration = const Duration(milliseconds: 500);
  Duration betweenLettersDuration = const Duration(milliseconds: 100);
  Duration betweenWordsDuration = const Duration(milliseconds: 400);
  Duration currentDuration = const Duration();

  final Color _offColor = Colors.black, _onColor = Colors.red[500]!;

  Color _circleColor = Colors.black;

  void _animateCode(){
    setState(() {
      _circleColor = _onColor;
    });
  }

  void updateUseTorch(bool value){
    _useTorch = value;
  }

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
          } else if (letters[k] == '-') {
            currentDuration = dashDuration;
          } else {
            continue;
          }
          _animateCode();
          if (_useTorch) {
            await turnOnTorch();
          }
          // Așteaptă durata curentă înainte de a trece la următoarea literă
          await Future.delayed(currentDuration);
          setState(() {
            // Resetarea culorii la negru după expirarea duratei
            _circleColor = _offColor;
          });
          // Așteaptă un scurt timp între luminare și stingere
          await Future.delayed(currentDuration);
          if (_useTorch) {
            await turnOffTorch();
          }

          // Asteeapta un timp între litere
          await Future.delayed(betweenLettersDuration);
        }
        // Așteaptă 500ms între litere
        await Future.delayed(betweenWordsDuration);
      }
      _textTransmitted += ' ';
    }
  }




  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _transmittedMessageController = TextEditingController(text: _textTransmitted);
    dotDurationController = TextEditingController(text: dotDuration.inMilliseconds.toString());
    dashDurationController = TextEditingController(text: dashDuration.inMilliseconds.toString());
    betweenLettersDurationController = TextEditingController(text: betweenLettersDuration.inMilliseconds.toString());
    betweenWordsDurationController = TextEditingController(text: betweenWordsDuration.inMilliseconds.toString());
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isTransmitting ? const SizedBox() :
          const Text("Send Morse Code",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          _isTransmitting ? const SizedBox() : const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Expanded(
            flex: 2,
            child: AnimatedContainer(
              duration: Duration(milliseconds: currentDuration.inMilliseconds),
              width: componentSize,
              height: componentSize,
              decoration: BoxDecoration(
                color: _circleColor,
                shape: BoxShape.circle,
              ),
              curve: Curves.easeOutCirc,
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
      )],
      )
    );

    Wrapper wrapper = Wrapper({"prefix": _prefix, "phoneNumber" : _phoneNumber});

    SingleChildScrollView lowerStandBy = SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 0.0, 0.0, 0.0),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context){
                            return Center(
                                child: SingleChildScrollView(
                                    child: AlertDialog(
                                        backgroundColor: Colors.amber[100],
                                        title: const Text(
                                            'Se va importa primul Morse Code din lista de mesaje SMS cu numarul de telefon selectat.',
                                            textAlign: TextAlign.center,
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
                                                  _prefix = wrapper.obj["prefix"];
                                                  _phoneNumber = wrapper.obj["phoneNumber"];
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
                  )
                  ),
                  const SizedBox(width: 20.0),
                  _messageImported!.isEmpty ? const SizedBox():
                                              TextButton(
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext context){
                                                        return AlertDialog(
                                                          backgroundColor: Colors.amber[100],
                                                          title: const Center(child: Text('Mesaj importat')),
                                                          content: SingleChildScrollView(
                                                            child: TextField(
                                                              readOnly: true,
                                                              maxLines: 5,
                                                              controller: TextEditingController(text: _messageImported),
                                                            ),
                                                          ),
                                                          actions: [Center(
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                TextButton(
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                  child: const Center(child:Text('OK')),
                                                                ),
                                                                const SizedBox(width: 20.0),
                                                                TextButton(
                                                                  onPressed: () {
                                                                    _messageImported = '';
                                                                    setState(() {});
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                  child: const Center(child:Text('Delete')),
                                                                ),
                                                              ],
                                                            )
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
              onPressed: () async {
                _hasTorch = await isTorchAvailable();
                _useTorch = _hasTorch;
                setState(() {
                  if (_messageField!.isEmpty && _messageImported!.isEmpty){
                    buildDialog(context, 'Eroare', 'Introduceți un mesaj sau importați unul din SMS-uri.');
                    return;
                  }
                  Wrapper wrapper = Wrapper({
                      "dotDuration": dotDuration,
                      "dashDuration": dashDuration,
                      "betweenLettersDuration": betweenLettersDuration,
                      "betweenWordsDuration": betweenWordsDuration,
                      "useTorch": _hasTorch,
                      "dotDurationController": dotDurationController,
                      "dashDurationController": dashDurationController,
                      "betweenLettersDurationController": betweenLettersDurationController,
                      "betweenWordsDurationController": betweenWordsDurationController
                      });

                  SingleChildScrollView dialogContent = buildMorseTransmissionContent(wrapper);

                  showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          backgroundColor: Colors.amber[100],
                          title: const Text('Configuration', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                          content: dialogContent,
                          actions: [
                            Align(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () {
                                    dotDuration = wrapper.obj["dotDuration"];
                                    dashDuration = wrapper.obj["dashDuration"];
                                    betweenLettersDuration = wrapper.obj["betweenLettersDuration"];
                                    betweenWordsDuration = wrapper.obj["betweenWordsDuration"];
                                    if (_messageImported!.isNotEmpty){
                                      // Prioritize the imported message
                                      morseCodeToBeTransmitted = _messageImported!;
                                    } else {
                                      morseCodeToBeTransmitted = fromTextToMorse(_messageField!);
                                    }
                                    componentSize *= 2;
                                    _isTransmitting = true;
                                    debugPrint("Use Torch: $_useTorch");
                                    Navigator.of(context).pop();
                                    _animateMorse(morseCodeToBeTransmitted!);
                                  },
                                  child: const Text('OK'),
                                )
                            )
                          ],
                        );
                      });
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
                  _circleColor = Colors.black;
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
      backgroundColor: Colors.amber[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
