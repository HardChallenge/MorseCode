import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  runApp(const MorseCode());
}

class MorseCode extends StatelessWidget {
  const MorseCode({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: 'Morse Code App', home: App());
  }
}
