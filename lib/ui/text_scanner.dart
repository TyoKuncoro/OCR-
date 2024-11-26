import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ocr/utils/db.dart';
import 'package:ocr/model/recognized_text.dart' as rnt;

class TextScanner extends StatefulWidget {
  late XFile? imageFile; // data from gallery or camera
  late rnt.RecognizedTextItem? item; // data from database

  // if imageFile parameter passed then it assumed as new item or
  // else it's editing existing item
  TextScanner({super.key, this.imageFile, this.item}) {
    if (imageFile == null && item == null) {
      throw Exception("Must pass imageFile or item");
    }
  }

  @override
  State<TextScanner> createState() => _TextScannerState();
}

class _TextScannerState extends State<TextScanner> with WidgetsBindingObserver {
  final TextEditingController _textEditingController = TextEditingController();
  late Future<_ProcessResult> _processImage;
  Offset imagePos = Offset(0, 0); // Initial position

  Future<_ProcessResult> doProcessImage() async {
    if (widget.imageFile != null) {
      var file = File(widget.imageFile!.path);
      var image = await file.readAsBytes();
      final TextRecognizer textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      var ret = await textRecognizer.processImage(InputImage.fromFile(file));
      textRecognizer.close();

      // delete file image immediately after use since flutter only copy original image
      file.deleteSync(recursive: true);
      return Future.value(_ProcessResult(ret.text, image, false));
    } else if (widget.item != null) {
      var text = widget.item!.text;
      var image = widget.item!.image;
      return Future.value(_ProcessResult(text, image, true));
    }

    throw Exception("Must pass imageFile or item");
  }

  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _processImage = doProcessImage();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _processImage,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!;

          if (data.text.isEmpty) {
            Fluttertoast.showToast(msg: "No text scanned in image");
            Navigator.popUntil(
              context,
              (route) {
                return route.isFirst;
              },
            );
            return const SizedBox.shrink();
          }

          _textEditingController.text = data.text;

          var screenWidth = MediaQuery.of(context).size.width;
          screenWidth -= 100;
          imagePos = Offset(screenWidth, 0);

          return Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                    onPressed: () async {
                      var navigator = Navigator.of(context);

                      try {
                        if (data.exists) {
                          var item = widget.item!;
                          item.text = _textEditingController.text;
                          item.timeLastUpdated =
                              DateTime.now().millisecondsSinceEpoch;
                          await DbManager.instance.recognizedTextDao
                              .update(item);
                        } else {
                          var i = rnt.RecognizedTextItem(
                              image: data.image,
                              text: _textEditingController.text);
                          await DbManager.instance.recognizedTextDao.add(i);
                        }
                      } catch (error) {
                        Fluttertoast.showToast(msg: "Error: $error");
                      } finally {
                        navigator.popUntil(
                          (route) {
                            return route.isFirst;
                          },
                        );
                      }
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
                  left: imagePos.dx,
                  top: imagePos.dy,
                  child: Image(
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    image: MemoryImage(data.image),
                  ),
                )
              ]),
            ),
          );
        });
  }
}

class _ProcessResult {
  String text;
  Uint8List image;
  bool exists; //indicates that item already saved up into database
  _ProcessResult(this.text, this.image, this.exists);
}
