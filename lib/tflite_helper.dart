import 'package:tflite/tflite.dart';

class TFLiteHelper {
  static Future<void> loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );
  }

  static Future<List<dynamic>> detectColors(String imagePath) async {
    var recognitions = await Tflite.runModelOnImage(
      path: imagePath,
      numResults: 5,
      threshold: 0.5,
    );
    return recognitions ?? [];
  }

  static Future<void> disposeModel() async {
    await Tflite.close();
  }
}