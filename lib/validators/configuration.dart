import '../builders/alert_builder.dart';

String validateConfiguration(Wrapper wrapper) {
  Duration dotDuration = wrapper.obj["dotDuration"], dashDuration = wrapper.obj["dashDuration"];
  Duration betweenWordsDuration = wrapper.obj["betweenWordsDuration"], betweenLettersDuration = wrapper.obj["betweenLettersDuration"];
  Duration betweenMorseDuration = wrapper.obj["betweenMorseDuration"];

  if (dotDuration.inMilliseconds < 10){
    return '"Dot duration" trebuie sa aiba o valoare de minim 10 ms.';
  }
  if (dashDuration.inMilliseconds < 100){
    return '"Dash duration" trebuie sa aiba o valoare de minim 100 ms.';
  }
  if (betweenMorseDuration.inMilliseconds < 10){
    return '"Between morse" trebuie sa aiba o valoare de minim 10 ms.';
  }
  if (betweenWordsDuration.inMilliseconds < 200){
    return '"Between words" trebuie sa aiba o valoare de minim 200 ms.';
  }
  if (betweenLettersDuration.inMilliseconds < 10){
    return '"Between letters" trebuie sa aiba o valoare de minim 10 ms.';
  }
  return '';
}