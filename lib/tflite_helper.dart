// import 'package:tflite/tflite.dart';
// import 'package:camera/camera.dart';

// class TFLiteHelper {
//   // Load the TFLite model and labels
//   static Future<void> loadModel() async {
//     await Tflite.loadModel(
//       model: 'assets/model.tflite', // Path to your TFLite model
//       labels: 'assets/labels.txt',  // Path to your labels file
//     );
//   }

//   // Run the model on a single image (for static image detection)
//   static Future<List<dynamic>> detectColors(String imagePath) async {
//     var recognitions = await Tflite.runModelOnImage(
//       path: imagePath,
//       numResults: 5, // Number of results to return
//       threshold: 0.5, // Confidence threshold
//     );
//     return recognitions ?? []; // Return an empty list if recognitions is null
//   }

//   // Run the model on a camera frame (for real-time detection)
//   static Future<List<dynamic>> runModelOnFrame(CameraImage image) async {
//     var recognitions = await Tflite.runModelOnFrame(
//       bytesList: image.planes.map((plane) => plane.bytes).toList(),
//       imageHeight: image.height,
//       imageWidth: image.width,
//       numResults: 5, // Number of results to return
//       threshold: 0.5, // Confidence threshold
//     );
//     return recognitions ?? []; // Return an empty list if recognitions is null
//   }

//   // Dispose of the TFLite model to free up resources
//   static Future<void> disposeModel() async {
//     await Tflite.close();
//   }
// }