import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ImageTextRecognition extends StatefulWidget {
  final XFile image;

  const ImageTextRecognition({super.key, required this.image});

  @override
  State<ImageTextRecognition> createState() => _ImageTextRecognitionState();
}

class _ImageTextRecognitionState extends State<ImageTextRecognition> {
  late Future<List<TextBlock>> list;

  Future<List<TextBlock>> recognizeText(File image) async {
    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer();

    final recognizedText = await textRecognizer.processImage(inputImage);
    return recognizedText.blocks;
  }

  @override
  void initState() {
    list = recognizeText(File(widget.image.path));
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TextBlock>>(
      future: list,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Center(child:Stack(
            children: [
              // Display the image
              Image.file(File(widget.image.path)),
              // Overlay selectable text
              ...snapshot.data!.map((block) {
                final boundingBox = block.boundingBox;
                return Positioned(
                  left: boundingBox.left,
                  top: boundingBox.top,
                  width: boundingBox.width,
                  height: boundingBox.height,
                  child: Container(
                    color: Colors.yellow.withOpacity(0.3),
                    // Highlight background
                    child: SelectableText(
                      block.text,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ));
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
