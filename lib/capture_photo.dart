import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';

class CapturePhoto extends StatefulWidget {
  const CapturePhoto({Key? key}) : super(key: key);

  @override
  CapturePhotoState createState() => CapturePhotoState(); // Made public
}

class CapturePhotoState extends State<CapturePhoto> { // Made public
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  FlutterTts flutterTts = FlutterTts();
  String? _imagePath;
  String? _detectedColor;
  double? _accuracy; // To store the accuracy of the detected color
  String? _warningMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeTts();
    _loadModel(); // Load the TFLite model
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {});
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
  }

  Future<void> _loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    );
  }

  Future<void> _captureImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final XFile image = await _cameraController!.takePicture();
      setState(() {
        _imagePath = image.path;
      });
      _detectColors(image.path);
    }
  }

  Future<void> _detectColors(String imagePath) async {
    var recognitions = await Tflite.runModelOnImage(
      path: imagePath,
      numResults: 5,
      threshold: 0.3,
    );

    print("Recognitions: $recognitions"); // Debugging output

    // Null check for recognitions
    if (recognitions != null && recognitions.isNotEmpty) {
      String detectedColor = recognitions[0]['label'];
      double confidence = recognitions[0]['confidence'] * 100; // Convert to percentage
      print("Detected Color: $detectedColor, Confidence: $confidence"); // Debugging output

      setState(() {
        _detectedColor = detectedColor;
        _accuracy = confidence; // Update accuracy
        _warningMessage = null;
      });
      _provideVoiceFeedback("Detected color is $detectedColor with ${confidence.toStringAsFixed(2)}% accuracy");
    } else {
      print("No color detected"); // Debugging output

      setState(() {
        _detectedColor = "No color detected";
        _accuracy = null;
        _warningMessage =
            "Warning: Detection failed. This might be due to poor lighting, low camera quality, or too many objects with different colors.";
      });
      _provideVoiceFeedback("No color detected. Please check lighting or camera quality.");
    }
  }

  Future<void> _provideVoiceFeedback(String message) async {
    await flutterTts.speak(message);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    flutterTts.stop();
    _disposeModel();
    super.dispose();
  }

  Future<void> _disposeModel() async {
    await Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Photo'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            // Use Expanded to make the camera preview fit the screen
            child: CameraPreview(_cameraController!),
          ),
          ElevatedButton(
            onPressed: _captureImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Capture Image'),
          ),
          if (_imagePath != null)
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Image.file(File(_imagePath!)),
                if (_detectedColor != null)
                  Container(
                    color: Colors.black54, // Semi-transparent background
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Detected Color: $_detectedColor\nAccuracy: ${_accuracy?.toStringAsFixed(2)}%",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          if (_warningMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _warningMessage!,
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}