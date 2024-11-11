import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ocr/model/recognized_text.dart';
import 'package:ocr/ui/camera_preview.dart';
import 'package:ocr/ui/reuseableComponent/Empty.dart';
import 'package:ocr/ui/test.dart';
import 'package:ocr/ui/text_scanner.dart';
import 'package:ocr/utils/db.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const MyHomePage(title: 'Homepage'),
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
  late Future<List<RecognizedText>> _items;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchItems() async {
    setState(() {
      _items = DbManager.instance.recognizedTextDao.findAll();
    });
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

  Widget createGridList() {
    return FutureBuilder<List<RecognizedText>>(
      future: _items,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        var list = snapshot.data;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Two columns
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: list!.length,
                  itemBuilder: (context, index) {
                    var imageBytes = list[index].image;
                    var x = Image.memory(imageBytes);
                    return Stack(
                      children: [x,
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 16),
                            color: Colors.black54,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "test",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.menu, color: Colors.white),
                                  onPressed: () {
                                    // Handle menu action
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // EmptyState(
              //   message: "No data",
              // ),
              // Container(
              //   width: 50,
              //   height: 50,
              //   decoration:
              //       BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              // )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // onWillPop: onWillPop()
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: !isSearching
            ? Text("Image to Text")
            : TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search...",
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
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
      body: createGridList(),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
              bottom: 90,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
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
                  // fit: BoxFit.cover,
                ),
              )),
          Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () async {
                  var navigator = Navigator.of(context);
                  var imagePicker = ImagePicker();

                  var file =
                      await imagePicker.pickImage(source: ImageSource.gallery);

                  navigator.push(MaterialPageRoute(
                    builder: (context) {
                      return ImageTextRecognition(image: file!);
                    },
                  ));
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Image.asset(
                  'assets/icons/Gallery.PNG',
                  width: 48,
                  // fit: BoxFit.cover,
                ),
              ))
        ],
      ),
    );
  }
}
