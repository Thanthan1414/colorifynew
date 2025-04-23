import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'tflite_helper.dart';
import 'package:flutter_tts/flutter_tts.dart';

class RealTimeDetection extends StatefulWidget {
  const RealTimeDetection({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RealTimeDetectionState createState() => _RealTimeDetectionState();
}

class _RealTimeDetectionState extends State<RealTimeDetection> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool isDetecting = false;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeTts();
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

  void _startDetection() {
    if (_cameraController != null) {
      _cameraController!.startImageStream((CameraImage image) {
        if (!isDetecting) {
          isDetecting = true;
          // Convert image to input format for TFLite
          // Run TFLite model
          // Provide voice feedback
          _provideVoiceFeedback("Color detected");
          Future.delayed(const Duration(seconds: 3), () {
            isDetecting = false;
          });
        }
      });
    }
  }

  Future<void> _provideVoiceFeedback(String message) async {
    await flutterTts.speak(message);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    TFLiteHelper.disposeModel();
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: _cameraController!.value.aspectRatio,
      child: CameraPreview(_cameraController!),
    );
  }
}
