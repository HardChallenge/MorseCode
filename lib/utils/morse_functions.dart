import 'morse_coding.dart';

String fromTextToMorse(String text) {
  String morse = '';
  List<String> words = text.trim().split(RegExp(r"\s+"));
  for (int i = 0; i < words.length; i++) {
    String word = words[i];
    if (word.isEmpty) {
      continue;
    }
    for (int j = 0; j < word.length; j++) {
      morse += '${letterToMorse[word[j].toUpperCase()] ?? "?"} ';
    }
    morse += (i != words.length - 1) ? '\n' : '';
  }

  return morse;
}
