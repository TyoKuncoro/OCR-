import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextScanner extends StatefulWidget {
  final XFile imageFile;
  const TextScanner({super.key, required this.imageFile});

  @override
  State<TextScanner> createState() => _TextScannerState();
}

class _TextScannerState extends State<TextScanner> {
  final QuillController _quillController = QuillController.basic();
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  Offset position = Offset(100, 100); // Initial position

  @override
  void initState() {
    super.initState();
    var s = _textRecognizer
        .processImage(InputImage.fromFilePath(widget.imageFile.path));
    s.then(
      (value) {
        setState(() {
          _quillController.document.insert(0, value.text);
        });
      },
    );
  }

  @override
  void dispose() {
    _quillController.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(children: <Widget>[
          QuillEditor.basic(
            controller: _quillController,
          ),
          Positioned(
            left: position.dx,
            top: position.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  var x = position.dx + details.delta.dx;
                  if (x <= 0) x = 0;
                  var y = position.dy + details.delta.dy;
                  if (y <= 0) y = 0;
                  position = Offset(
                    x,
                    y,
                  );
                  print("${position.dx} ${position.dy}");
                });
              },
              child: Image(
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  image: FileImage(File(widget.imageFile.path))),
            ),
          ),
        ]),
      ),
    );
  }
}
