import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'tflite_helper.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';

class UploadPhoto extends StatefulWidget {
  @override
  _UploadPhotoState createState() => _UploadPhotoState();
}

class _UploadPhotoState extends State<UploadPhoto> {
  final ImagePicker _picker = ImagePicker();
  FlutterTts flutterTts = FlutterTts();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
      _detectColors(image.path);
    }
  }

  Future<void> _detectColors(String imagePath) async {
    var recognitions = await TFLiteHelper.detectColors(imagePath);
    if (recognitions.isNotEmpty) {
      _provideVoiceFeedback("Color detected");
    }
  }

  Future<void> _provideVoiceFeedback(String message) async {
    await flutterTts.speak(message);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Photo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            if (_imagePath != null) Image.file(File(_imagePath!)),
          ],
        ),
      ),
    );
  }
}
