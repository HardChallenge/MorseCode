import 'package:flutter/cupertino.dart';
import 'package:morse_code_project/pages/morse_code.dart';

SingleChildScrollView buildUpperMorse(){
  return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MorseCodeState.isTransmitting ? const SizedBox() :
          const Text("Send Morse Code",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          MorseCodeState.isTransmitting ? const SizedBox() : const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: MorseCodeState.currentDuration.inMilliseconds),
                  width: MorseCodeState.componentSize,
                  height: MorseCodeState.componentSize,
                  decoration: BoxDecoration(
                    color: MorseCodeState.circleColor,
                    shape: BoxShape.circle,
                  ),
                  curve: Curves.easeOutCirc,
                ),
              ),
              SizedBox(width: MorseCodeState.componentSize / 5.0),
              Expanded(
                flex: 1,
                child: Text(
                    MorseCodeState.currentLetter,
                    style: TextStyle(fontSize: MorseCodeState.componentSize / 2.0, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          )],
      )
  );
}

