import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morse_code_project/utils/helper_functions.dart';
import 'package:morse_code_project/utils/morse_coding.dart';

import '../builders/alert_builder.dart';
import '../builders/morse_builder.dart';
import '../utils/torch_handler.dart';
import '../validators/configuration.dart';

class MorseCode extends StatefulWidget {
  const MorseCode({super.key});

  @override
  MorseCodeState createState() => MorseCodeState();
}

class MorseCodeState extends State<MorseCode> with SingleTickerProviderStateMixin {
  static bool isTransmitting = false;
  static String currentLetter = '-';
  String? _messageField = '', _messageImported = '', morseCodeToBeTransmitted = '';
  static double componentSize = 120.0;
  String _textTransmitted = '';
  String _prefix = "Romania (+40)", _phoneNumber = "723 523 103";
  bool _hasTorch = false, _useTorch = false;

  late TextEditingController _messageController;
  late TextEditingController _transmittedMessageController;
  late TextEditingController dotDurationController, dashDurationController;
  late TextEditingController betweenLettersDurationController, betweenWordsDurationController, betweenMorseDurationController;

  Duration dotDuration = const Duration(milliseconds: 100);
  Duration dashDuration = const Duration(milliseconds: 500);
  Duration betweenLettersDuration = const Duration(milliseconds: 200);
  Duration betweenWordsDuration = const Duration(milliseconds: 400);
  Duration betweenMorseDuration = const Duration(milliseconds: 100);
  static Duration currentDuration = const Duration();

  final Color _offColor = Colors.black, _onColor = Colors.red[500]!;

  static Color circleColor = Colors.black;

  void _animateCode(){
    setState(() {
      circleColor = _onColor;
    });
  }

  void _animateMorse(String morseCode) async {
    List<String> phrases = morseCode.trim().split('\n');

    for (int i = 0; i < phrases.length && isTransmitting; i++) {
      String phrase = phrases[i];

      List<String> words = phrase.trim().split(RegExp(r"\s+"));
      for (int j = 0; j < words.length && isTransmitting; j++) {
        String word = words[j];
        String? letter = morseToLetter[word];
        if (letter == null) {
          continue;
        }
        currentLetter = letter;
        _textTransmitted += letter;
        setState(() {
          _transmittedMessageController.text = _textTransmitted;
        });
        List<String> letters = word.trim().split('');

        for (int k = 0; k < letters.length && isTransmitting; k++) {
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
          // Wait for circle to lighten up
          await Future.delayed(currentDuration);
          // Wait for morse code duration (set in configuration)
          await Future.delayed(currentDuration);
          setState(() {
            // Resetting the circle color
            circleColor = _offColor;
          });
          if (_useTorch) {
            await turnOffTorch();
          }

          // Wait between Morse codes
          await Future.delayed(betweenMorseDuration);
        }
        // Wait for the duration between letters
        await Future.delayed(betweenLettersDuration);
      }
      // Wait for the duration between words
      await Future.delayed(betweenWordsDuration);
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
    betweenMorseDurationController = TextEditingController(text: betweenMorseDuration.inMilliseconds.toString());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _transmittedMessageController.dispose();
    dotDurationController.dispose();
    dashDurationController.dispose();
    betweenLettersDurationController.dispose();
    betweenWordsDurationController.dispose();
    betweenMorseDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SingleChildScrollView upper = buildUpperMorse();

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
                    child: const Text("Importa mesaj din SMS"),
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
                    buildErrorDialog(context, 'Eroare', 'Introduceți un mesaj sau importați unul din SMS-uri.');
                    return;
                  }
                  Wrapper wrapper = Wrapper({
                      "dotDuration": dotDuration,
                      "dashDuration": dashDuration,
                      "betweenLettersDuration": betweenLettersDuration,
                      "betweenWordsDuration": betweenWordsDuration,
                      "betweenMorseDuration": betweenMorseDuration,
                      "useTorch": _hasTorch,
                      "dotDurationController": dotDurationController,
                      "dashDurationController": dashDurationController,
                      "betweenLettersDurationController": betweenLettersDurationController,
                      "betweenWordsDurationController": betweenWordsDurationController,
                      "betweenMorseDurationController": betweenMorseDurationController
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
                                    String validation = validateConfiguration(wrapper);
                                    if (validation != ''){
                                      buildErrorDialog(context, 'Eroare', validation);
                                      return;
                                    }
                                    dotDuration = wrapper.obj["dotDuration"];
                                    dashDuration = wrapper.obj["dashDuration"];
                                    betweenLettersDuration = wrapper.obj["betweenLettersDuration"];
                                    betweenWordsDuration = wrapper.obj["betweenWordsDuration"];
                                    betweenMorseDuration = wrapper.obj["betweenMorseDuration"];
                                    if (_messageImported!.isNotEmpty){
                                      // Prioritize the imported message
                                      morseCodeToBeTransmitted = _messageImported!;
                                    } else {
                                      morseCodeToBeTransmitted = fromTextToMorse(_messageField!);
                                    }
                                    componentSize *= 2;
                                    isTransmitting = true;
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
              child: const Text("Transmite mesaj"),
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
                  currentLetter = '-';
                  circleColor = Colors.black;
                  _textTransmitted = '';
                  setState(() {
                    _transmittedMessageController.text = _textTransmitted;
                  });
                  componentSize /= 2;
                  isTransmitting = false;
                });
              },
              child: const Text("STOP"),
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
              isTransmitting ? lowerTransmitting : lowerStandBy
            ],
          ),
        ),
      ),
      );
  }
}
