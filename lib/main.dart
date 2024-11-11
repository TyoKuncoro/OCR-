import 'package:flutter/material.dart';
import 'package:ocr/ui/camera_preview.dart';
import 'package:ocr/ui/reuseableComponent/Empty.dart';

void main() {
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
  void _incrementCounter() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const CameraPreviewWidget()));
  }

  bool isSearching = false;

  TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> images = [
    {'name': 'Image1', 'path': 'assets/Image1.PNG'},
    {'name': 'Image2', 'path': 'assets/Image2.PNG'},
    {'name': 'Image3', 'path': 'assets/Image2.PNG'},
    // Add more images here
  ];
  DateTime? lastPressed;

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
      body: Center(
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
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final image = images[index];
                  return Stack(
                    children: [
                      // Image container
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(image['path']!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          color: Colors.black54,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                image['name']!,
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
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
              bottom: 90,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  _incrementCounter();
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
                onPressed: () {
                  _incrementCounter();
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
