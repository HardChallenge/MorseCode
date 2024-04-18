import 'package:torch_light/torch_light.dart';

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
    return;
  }
}

Future<void> turnOffTorch() async {
  try {
    await TorchLight.disableTorch();
  } on Exception catch (_) {
    return;
  }
}

