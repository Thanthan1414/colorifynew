import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'tflite_helper.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';

class CapturePhoto extends StatefulWidget {
  const CapturePhoto({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CapturePhotoState createState() => _CapturePhotoState();
}

class _CapturePhotoState extends State<CapturePhoto> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  FlutterTts flutterTts = FlutterTts();
  String? _imagePath;
  String? _detectedColor; // To store the detected color
  String? _warningMessage; // To store the warning message

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeTts();
    TFLiteHelper.loadModel(); // Load the TFLite model
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

  Future<void> _captureImage() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      final XFile image = await _cameraController!.takePicture();
      setState(() {
        _imagePath = image.path;
      });
      _detectColors(image.path); // Detect colors after capturing the image
    }
  }

  Future<void> _detectColors(String imagePath) async {
    var recognitions = await TFLiteHelper.detectColors(imagePath);
    if (recognitions.isNotEmpty) {
      // Get the label of the first detected color
      String detectedColor = recognitions[0]['label'];
      setState(() {
        _detectedColor = detectedColor; // Update the detected color
        _warningMessage = null; // Clear any previous warning
      });
      _provideVoiceFeedback("Detected color is $detectedColor");
    } else {
      setState(() {
        _detectedColor = "No color detected"; // Update if no color is detected
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
    TFLiteHelper.disposeModel(); // Dispose of the TFLite model
    super.dispose();
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
          AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
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
          if (_imagePath != null) Image.file(File(_imagePath!)),
          if (_detectedColor != null) // Show detected color text
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Detected Color: $_detectedColor",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          if (_warningMessage != null) // Show warning message if detection fails
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