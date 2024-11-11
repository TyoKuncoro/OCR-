import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ocr/utils/db.dart';
import 'package:ocr/model/recognized_text.dart' as rnt;

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
  Offset position = Offset(100, 100); // Initial position

  @override
  void initState() {
    super.initState();
    var s = _textRecognizer
        .processImage(InputImage.fromFilePath(widget.imageFile.path));
    s.then(
      (value) {
        _textEditingController.text = value.text;
      },
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
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                var navigator = Navigator.of(context);
                var bytes = await widget.imageFile.readAsBytes();
                await DbManager.instance.recognizedTextDao
                    .insertItem(rnt.RecognizedText(bytes));
                navigator.popUntil(
                  (route) {
                    return route.isFirst;
                  },
                );
              },
              icon: Icon(Icons.done))
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              controller: _textEditingController,
              maxLines: null,
              decoration: InputDecoration(border: null),
              expands: true,
            ),
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
