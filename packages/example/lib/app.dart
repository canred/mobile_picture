import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bot_toast/bot_toast.dart';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

late List<CameraDescription> cameras;

class CupertinoStoreApp extends StatelessWidget {
  //const CupertinoStoreApp({Key? key, required cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    try {
      availableCameras()
          .then((onValue) => {
                print('Cameras started'),
                cameras = onValue,
                cameras.forEach((camera) {
                  print('Camera: ${camera.name}');
                }),
              })
          .onError((e, stackTrace) => {
                print('Error: $e.code\nError Message: $e.message'),
              });
    } on CameraException catch (e) {
      print('Error: $e.code\nError Message: $e.message');
    }

    return CupertinoApp(
      builder: (context, child) {
        child = BotToastInit()(context, child);
        return child;
      },
      debugShowCheckedModeBanner: false,
      navigatorObservers: [BotToastNavigatorObserver()],
      home: CupertinoStoreHomePage(),
    );
  }
}

class CupertinoStoreHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width - 35;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('VIS Picture'),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 75), // Add some space from the top
          Container(
            height: 1.0,
            color: CupertinoColors.systemGrey4,
          ), // Add horizontal line
          SizedBox(height: 10), // Add some space from the line
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoButton(
                padding: EdgeInsets.all(10), // 設置內邊距
                child: Container(
                  width: buttonWidth,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // 設置圓角
                    image: DecorationImage(
                      image: AssetImage('assets/images/btn_01.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => MaterialApp(
                        home: TakePictureScreen(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoButton(
                padding: EdgeInsets.all(10), // 設置內邊距
                child: Container(
                  width: buttonWidth,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // 設置圓角
                    image: DecorationImage(
                      image: AssetImage('assets/images/btn_02.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => MaterialApp(
                        home: TakePictureScreen(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoButton(
                padding: EdgeInsets.all(10), // 設置內邊距
                child: Container(
                  width: buttonWidth,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // 設置圓角
                    image: DecorationImage(
                      image: AssetImage('assets/images/btn_03.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => MaterialApp(
                        home: TakePictureScreen(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoButton(
                padding: EdgeInsets.all(10), // 設置內邊距
                child: Container(
                  width: buttonWidth,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // 設置圓角
                    image: DecorationImage(
                      image: AssetImage('assets/images/btn_03.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => MaterialApp(
                        home: TakePictureScreen(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoButton(
                padding: EdgeInsets.all(10), // 設置內邊距
                child: Container(
                  width: buttonWidth,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // 設置圓角
                    image: DecorationImage(
                      image: AssetImage('assets/images/btn_03.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => MaterialApp(
                        home: TakePictureScreen(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoButton(
                padding: EdgeInsets.all(10), // 設置內邊距
                child: Container(
                  width: buttonWidth,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10), // 設置圓角
                    image: DecorationImage(
                      image: AssetImage('assets/images/btn_03.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => MaterialApp(
                        home: TakePictureScreen(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _controller.initialize();

      // _controller.initialize().then((_) {
      //   if (!mounted) {
      //     return;
      //   }
      //   setState(() {});
      // }).catchError((Object e) {
      //   if (e is CameraException) {
      //     switch (e.code) {
      //       case 'CameraAccessDenied':
      //         // Handle access errors here.
      //         break;
      //       default:
      //         // Handle other errors here.
      //         break;
      //     }
      //   }
      // });
    } else {
      _initializeControllerFuture = Future.error('No cameras available');
    }
  }

  @override
  void dispose() {
    // if (cameras.isNotEmpty) {
    //   _controller.dispose();
    // }
    super.dispose();
  }

  Future<void> uploadImage(File imageFile) async {
    final uri = Uri.parse('YOUR_API_URL');
    final request = http.MultipartRequest('POST', uri);
    final fileStream = http.ByteStream(imageFile.openRead());
    final length = await imageFile.length();
    final multipartFile = http.MultipartFile('image', fileStream, length,
        filename: imageFile.path.split('/').last);
    request.files.add(multipartFile);
    final response = await request.send();
    if (response.statusCode == 200) {
      print('Image uploaded successfully');
    } else {
      print('Failed to upload image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take a picture'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              if (cameras.isNotEmpty) {
                try {
                  await _initializeControllerFuture;
                  final path =
                      '${(await getTemporaryDirectory()).path}/image_${DateTime.now()}.jpg';
                  await _controller.takePicture().then((image) async {
                    await image.saveTo(path);
                    final file = File(path);
                    await uploadImage(file);
                  });
                } catch (e) {
                  print(e);
                }
              } else {
                print('No cameras available');
              }
            },
            child: const Icon(Icons.camera_alt),
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                CupertinoPageRoute(
                    builder: (context) => CupertinoStoreHomePage()),
                (Route<dynamic> route) => false,
              );
            },
            child: const Icon(Icons.arrow_back),
          ),
        ],
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'assets/.env');
  runApp(CupertinoStoreApp());
}
