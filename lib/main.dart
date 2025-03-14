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
import 'package:http/io_client.dart'; // Add this import
import 'app_config.dart';

late List<CameraDescription> cameras;

class CupertinoStoreApp extends StatelessWidget {
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
        middle: Text('VIS廠內相機'),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 64), // Add some space from the top
            Container(
              height: 1.0,
              color: CupertinoColors.systemGrey4,
            ), // Add horizontal line
            SizedBox(height: 4), // Add some space from the line
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.all(10), // 設置內邊距
                  child: Container(
                    width: buttonWidth,
                    height: 100,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10), // 設置圓角
                            image: DecorationImage(
                              image: AssetImage('assets/images/picture-01.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '生產環境拍照',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              backgroundColor: Colors.black54,
                            ),
                          ),
                        ),
                      ],
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
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10), // 設置圓角
                            image: DecorationImage(
                              image: AssetImage('assets/images/picture-02.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '安全衛生拍照',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              backgroundColor: Colors.black54,
                            ),
                          ),
                        ),
                      ],
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
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10), // 設置圓角
                            image: DecorationImage(
                              image: AssetImage('assets/images/picture-04.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '客戶需求拍照',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              backgroundColor: Colors.black54,
                            ),
                          ),
                        ),
                      ],
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
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10), // 設置圓角
                            image: DecorationImage(
                              image: AssetImage('assets/images/picture-07.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '照片瀏覽',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              backgroundColor: Colors.black54,
                            ),
                          ),
                        ),
                      ],
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
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
    _tagsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> uploadImage(File imageFile) async {
    final uri = Uri.parse('https://10.125.1.104/api/photo/add');
    final request = http.MultipartRequest('POST', uri);
    final fileStream = http.ByteStream(imageFile.openRead());
    final length = await imageFile.length();
    final multipartFile = http.MultipartFile('photo', fileStream, length,
        filename: imageFile.path.split('/').last);

    request.files.add(multipartFile);
    request.fields['class_type'] = 'class one';
    request.fields['tags'] = _tagsController.text;
    request.fields['description'] = _descriptionController.text;

    try {
      // Bypass SSL certificate verification
      final httpClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      final ioClient = IOClient(httpClient);

      final response = await ioClient.send(request);
      if (response.statusCode == 200) {
        print('Image uploaded successfully');
        BotToast.showText(text: '照片上傳（成功）');
      } else {
        BotToast.showText(text: '照片上傳（失敗）');
      }
    } catch (e) {
      print('Upload failed: $e');
      BotToast.showText(text: '照片上傳（失敗）');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            return Column(
              children: [
                Expanded(
                  child: CameraPreview(_controller),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.7,
                      child: TextField(
                        controller: _tagsController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '照片標籤（以,分隔）選填',
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.7,
                      child: TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '說明（選填）',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
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
