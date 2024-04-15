import 'package:flutter/cupertino.dart';

class MorseCode extends StatefulWidget {
  const MorseCode({super.key});

  @override
  MorseCodeState createState() => MorseCodeState();
}

class MorseCodeState extends State<MorseCode> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Morse Code'),
    );
  }
}
