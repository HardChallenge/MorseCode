import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';

import 'morse_coding.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

String fromTextToMorse(String text) {
  String morse = '';
  List<String> words = text.trim().split(RegExp(r"\s+"));
  for (int i = 0; i < words.length; i++) {
    String word = words[i];
    if (word.isEmpty) {
      continue;
    }
    for (int j = 0; j < word.length; j++) {
      morse += '${letterToMorse[word[j]] ?? "?"} ';
    }
    morse += (i != words.length - 1) ? '\n' : '';
  }

  return morse;
}

void sendMorseCode(String text, String recipient) async {
  String morse = fromTextToMorse(text);
  String result = await sendSMS(message: morse, recipients: [recipient])
      .catchError((onError) {
    print(onError);
  });
  print(result);
}

bool isValidMorse(String? morse) {
  if (morse == null) {
    return false;
  }

  List<String> words = morse.trim().split('\n');
  for (int i = 0; i < words.length; i++) {
    String word = words[i];
    List<String> letters = word.trim().split(' ');
    for (int j = 0; j < letters.length; j++) {
      if (letters[j] == "?"){
        continue;
      }
      if (morseToLetter[letters[j]] == null) {
        return false;
      }
    }
  }
  return true;
}

Future<String?> getFirstMorseMessageWith(String phoneNumber) async {
  PermissionStatus status = await Permission.sms.request();
  if (status.isDenied) {
    return '';
  }
  final SmsQuery query = SmsQuery();
  List<SmsMessage> messages = await query.querySms(
                                      sort: true,
                                      address: phoneNumber,
                                      kinds: [SmsQueryKind.inbox, SmsQueryKind.sent]
                                    );

  return messages.isEmpty ? '' : messages[0].body;
}

void buildDialog(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.amber[100],
        title: Center(child: Text(title)),
        content: SingleChildScrollView(
          child: Text(content, textAlign: TextAlign.center),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Center(child: Text('OK')),
          )
        ],
      );
    }
  );
}

Future<bool> isTorchAvailable() async {
  try {
    return await TorchLight.isTorchAvailable();
  } on Exception catch (_) {
    return false;
  }
}

Future<void> turnOnTorch() async {
  try {
    await TorchLight.enableTorch();
  } on Exception catch (_) {
    print('Error turning on torch');
  }
}

Future<void> turnOffTorch() async {
  try {
    await TorchLight.disableTorch();
  } on Exception catch (_) {
    print('Error turning off torch');
  }
}