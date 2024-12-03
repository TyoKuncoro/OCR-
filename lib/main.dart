import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocr/ui/camera_preview.dart';
import 'package:ocr/ui/text_scanner.dart';
import 'package:ocr/utils/db.dart';
import 'package:ocr/widget/grid_list.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //ensure main database initialized
  await DbManager.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xFF1976D2),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          primary: Color(0xFF1976D2),
          secondary: Color(0xFFBBDEFB), // Use this instead of accentColor
          tertiary: Color(0xFF0D47A1),
        ),

        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Image to Text'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  DateTime? lastPressed;
  GlobalKey<RecognizedTextListState> gridKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  Future<bool> onWillPop() async {
    final now = DateTime.now();
    final maxDuration = Duration(seconds: 2);

    if (lastPressed == null || now.difference(lastPressed!) > maxDuration) {
      lastPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tekan kembali sekali lagi untuk keluar'),
          duration: Duration(seconds: 2),
        ),
      );
      return Future.value(false);
    }
    return Future.value(
        true); // Jika ditekan lagi dalam 2 detik, keluar dari app
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: !isSearching
              ? Text(widget.title)
              : TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Search...",
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) => gridKey.currentState!.search(value),
                  style: TextStyle(color: Colors.black),
                ),
          actions: [
            IconButton(
              icon: Icon(isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  isSearching = !isSearching;
                  if (!isSearching) searchController.clear();
                });
              },
            ),
          ],
        ),
        body: RecognizedTextList(
          key: gridKey,
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          verticalDirection: VerticalDirection.down,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                heroTag: "cameraFab",
                onPressed: () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CameraPreviewWidget()));
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Image.asset(
                  'assets/icons/Camera.PNG',
                  width: 48,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                heroTag: "galleryFab",
                onPressed: () async {
                  var navigator = Navigator.of(context);
                  var imagePicker = ImagePicker();

                  var file =
                      await imagePicker.pickImage(source: ImageSource.gallery);
                  if (file == null) {
                    return;
                  }

                  navigator.push(MaterialPageRoute(
                    builder: (context) {
                      return TextScanner(imageFile: file);
                    },
                  ));
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Image.asset(
                  'assets/icons/Gallery.PNG',
                  width: 48,
                ),
              ),
            ),
          ],
        ));
  }
}
