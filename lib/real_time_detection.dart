import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter_tts/flutter_tts.dart';

class RealTimeDetection extends StatefulWidget {
  const RealTimeDetection({Key? key}) : super(key: key);

  @override
  RealTimeDetectionState createState() => RealTimeDetectionState(); // Made public
}

class RealTimeDetectionState extends State<RealTimeDetection> { // Made public
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool isDetecting = false;
  FlutterTts flutterTts = FlutterTts();
  String? _detectedColor; // To store the detected color
  String? _warningMessage; // To store the warning message

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
    _startDetection();
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

  void _startDetection() {
    _cameraController!.startImageStream((CameraImage image) async {
      if (!isDetecting) {
        isDetecting = true;

        // Run the TFLite model on the image
        var recognitions = await _runModelOnFrame(image);

        if (recognitions.isNotEmpty) {
          // Extract the label of the first recognition
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

        // Delay to avoid continuous detections
        Future.delayed(const Duration(seconds: 3), () {
          isDetecting = false;
        });
      }
    });
  }

  Future<List<dynamic>> _runModelOnFrame(CameraImage image) async {
    return await Tflite.runModelOnFrame(
          bytesList: image.planes.map((plane) => plane.bytes).toList(),
          imageHeight: image.height,
          imageWidth: image.width,
          numResults: 5, // Number of results to return
          threshold: 0.3, // Confidence threshold
        ) ??
        []; // Return an empty list if null
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
        title: const Text('Real-Time Detection'),
      ),
      body: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
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