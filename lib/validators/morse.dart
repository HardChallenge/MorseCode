import '../utils/morse_coding.dart';

bool isValidMorse(String? morse) {
  if (morse == null) {
    return false;
  }

  List<String> words = morse.trim().split('\n');
  for (int i = 0; i < words.length; i++) {
    String word = words[i];
    List<String> letters = word.trim().split(RegExp(r"\s+"));
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
