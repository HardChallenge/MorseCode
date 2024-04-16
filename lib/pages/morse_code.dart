import 'package:flutter/material.dart';
import 'package:morse_code_project/components/sms_dropdown.dart';
import 'package:morse_code_project/utils/helper_functions.dart';

class MorseCode extends StatefulWidget {
  const MorseCode({super.key});

  @override
  MorseCodeState createState() => MorseCodeState();
}

class MorseCodeState extends State<MorseCode> {
  bool _isTransmitting = false;
  String _currentLetter = '-';
  String? _messageField = '', _messageImported = '';
  double _dotDuration = 0.5, _dashDuration = 1.5, _spaceDuration = 0.5;
  double componentSize = 120.0;
  String _textTransmitted = 'tu esti nebun\ntu esti nebun\ntu esti nebun\ntu esti nebun\ntu esti nebun\ntu esti nebun\ntu esti nebun\n';
  String _prefix = "Romania (+40)", _phoneNumber = "723 523 103";

  late TextEditingController _messageController;
  late TextEditingController _transmittedMessageController;

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
            child: Container(
              width: componentSize,
              height: componentSize,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: componentSize / 2.0),
          Expanded(
            child: Text(
              _currentLetter,
              style: TextStyle(fontSize: componentSize),
            ),
          ),
        ],
      ),
    );


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
                                        content: SingleChildScrollView(
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SMSDropdown(
                                                    initialValue: _prefix,
                                                    onChanged: (String value) {
                                                      setState(() {
                                                        _prefix = value;
                                                      });
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
                                                  )]
                                            )
                                        ),
                                        actions: [
                                          Align(
                                              alignment: Alignment.center,
                                              child: TextButton(
                                                // align it on center
                                                onPressed: () async {
                                                  String phoneNumber = _prefix.substring(_prefix.indexOf("(") + 1, _prefix.indexOf(")")) + _phoneNumber.trim().replaceAll(" ", "");
                                                  _messageImported = (await getFirstMorseMessageWith(phoneNumber))!;
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
                  _messageImported!.isEmpty ? const Icon(Icons.clear, color: Colors.red, size: 40.0) : const Icon(Icons.check, color: Colors.green, size: 40.0),
                ],
                )
              ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  componentSize *= 2;
                  _isTransmitting = true;
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
