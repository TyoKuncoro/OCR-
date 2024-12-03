import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ocr/ui/text_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ocr/widget/camera_focus_frame.dart';

class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({super.key});

  @override
  State<CameraPreviewWidget> createState() {
    return _CameraPreviewState();
  }
}

class _CameraPreviewState extends State<CameraPreviewWidget>
    with WidgetsBindingObserver {
  late Future<void> _initializeCamera;
  late CameraController _cameraController;
  double _scaleAnimCamBtn = 1.0;
  FlashMode _cameraFlashMode = FlashMode.off;
  bool _isTakingPicture = false;
  String inputName = "";

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
      var navigator = Navigator.of(context);
      var result = await _cameraController.takePicture();
      navigator.push(MaterialPageRoute(
        builder: (context) {
          return TextScanner(imageFile: result);
        },
      ));
    } catch (e) {
      Fluttertoast.showToast(msg: "There was an error when taking picture: $e");
    }
  }

  Widget cameraPreviewWidget() {
    // Calculate the aspect ratio of the preview dynamically
    var screenSize = MediaQuery.of(context).size;
    final previewSize = _cameraController.value.previewSize!;
    // final previewAspectRatio = previewSize.height / previewSize.width;
    final screenAspectRatio = screenSize.width / screenSize.height;
    return Stack(
      children: [
        SizedBox(
            width: screenSize.width,
            child: AspectRatio(
              aspectRatio: screenAspectRatio,
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: previewSize.height,
                    height: previewSize.width,
                    child: GestureDetector(
                        child: Stack(children: [
                      _cameraController.buildPreview(),
                      CameraFocusFrame(),
                    ])),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget mainCameraToolWidget() {
    var screenSize = MediaQuery.of(context).size;

    //padding bottom takes 10% of actual screen height
    var bottomPadding = (10 / 100) * screenSize.height;

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottomPadding),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 50,
              width: 50,
            ),
            GestureDetector(
                onTapUp: (details) async {
                  setState(() {
                    _scaleAnimCamBtn = 1.0;
                  });

                  if (_isTakingPicture) return;
                  _isTakingPicture = true;

                  await _takePicture();

                  _isTakingPicture = false;
                },
                onTapDown: (details) => setState(() {
                      _scaleAnimCamBtn = 0.8;
                    }),
                onTapCancel: () => setState(() {
                      _scaleAnimCamBtn = 1.0;
                    }),
                child: ElevatedButton(
                  onPressed: null,
                  style: ButtonStyle(
                      minimumSize: const WidgetStatePropertyAll(Size(70, 70)),
                      shape: const WidgetStatePropertyAll(CircleBorder()),
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
            ElevatedButton(
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
                }))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeCamera,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(
            children: [cameraPreviewWidget(), mainCameraToolWidget()],
          );
        } else if (snapshot.hasError) {
          Fluttertoast.showToast(
              msg: "Unable to open camera: ${snapshot.error}");
          Navigator.of(context).pop();
          return const SizedBox.shrink();
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
