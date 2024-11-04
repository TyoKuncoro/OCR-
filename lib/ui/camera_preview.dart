import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ocr/ui/text_scanner.dart';

class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({super.key});

  @override
  State<CameraPreviewWidget> createState() {
    return _CamerapreviewState();
  }
}

class _CamerapreviewState extends State<CameraPreviewWidget>
    with WidgetsBindingObserver {
  late Future<void> _initializeCamera;
  late CameraController _cameraController;
  double _scaleAnimCamBtn = 1.0;
  FlashMode _cameraFlashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera = _initializeCameras();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        _cameraController.pausePreview();
        break;
      case AppLifecycleState.resumed:
        _cameraController.resumePreview();
        break;
      default:
        break;
    }
  }

  Future<void> _initializeCameras() async {
    var camList = await availableCameras();

    _cameraController = CameraController(
      imageFormatGroup: ImageFormatGroup.jpeg,
      camList[0],
      ResolutionPreset.veryHigh,
    );

    await _cameraController.initialize();
  }

  Future<void> _takePicture() async {
    try {
      var result = await _cameraController.takePicture();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => TextScanner(
                imageFile: result,
              )));
    } catch (e) {
      print('Error capture image: $e');
    }
  }

  Widget flashButton() {
    return ElevatedButton(
        onPressed: () {
          setState(() {
            if (_cameraFlashMode == FlashMode.off) {
              _cameraFlashMode = FlashMode.always;
            } else {
              _cameraFlashMode = FlashMode.off;
            }
          });
          _cameraController.setFlashMode(_cameraFlashMode);
        },
        style: const ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(50, 50)),
            shape: WidgetStatePropertyAll(CircleBorder()),
            elevation: WidgetStatePropertyAll(5),
            backgroundColor: WidgetStatePropertyAll(Colors.white)),
        child: Builder(builder: (BuildContext context) {
          IconData selectedIcon;

          if (_cameraFlashMode == FlashMode.always) {
            selectedIcon = Icons.flash_on;
          } else {
            selectedIcon = Icons.flash_off;
          }

          return Icon(selectedIcon);
        }));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeCamera,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  child: CameraPreview(_cameraController),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                      ),
                      GestureDetector(
                          onTapUp: (details) => setState(() {
                                _scaleAnimCamBtn = 1.0;
                                _takePicture();
                              }),
                          onTapDown: (details) => setState(() {
                                _scaleAnimCamBtn = 0.8;
                              }),
                          onTapCancel: () => setState(() {
                                _scaleAnimCamBtn = 1.0;
                              }),
                          child: ElevatedButton(
                            onPressed: null,
                            style: ButtonStyle(
                                minimumSize:
                                    const WidgetStatePropertyAll(Size(70, 70)),
                                shape:
                                    const WidgetStatePropertyAll(CircleBorder()),
                                elevation: const WidgetStatePropertyAll(5),
                                backgroundColor: WidgetStatePropertyAll(
                                    Colors.black.withOpacity(0.5))),
                            child: AnimatedScale(
                              scale: _scaleAnimCamBtn,
                              duration: const Duration(milliseconds: 100),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                    color: Colors.white, shape: BoxShape.circle),
                              ),
                            ),
                          )),
                      flashButton(),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
