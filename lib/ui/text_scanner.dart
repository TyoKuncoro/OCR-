import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextScanner extends StatefulWidget {
  final XFile imageFile;
  const TextScanner({super.key, required this.imageFile});

  @override
  State<TextScanner> createState() => _TextScannerState();
}

class _TextScannerState extends State<TextScanner> {
  final TextEditingController _textEditingController = TextEditingController();
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  @override
  void initState() {
    super.initState();
    var s = _textRecognizer
        .processImage(InputImage.fromFilePath(widget.imageFile.path));
    s.then(
      (value) => {_textEditingController.text = value.text},
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: TextField(
        maxLines: null,
        controller: _textEditingController,
      ),
    );
  }
}
