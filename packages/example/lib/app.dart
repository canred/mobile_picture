import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

import 'pages/ptsLingJian.dart';
import 'vision_detector_views/qrcode_scanner_view.dart';
import 'vision_detector_views/barcode_scanner_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bot_toast/bot_toast.dart';
import '../main.dart';
import 'widgets/ConnectButton.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

late MqttBrowserClient clientBrowser;
late MqttServerClient clientServer;
//late bool mqtt_is_on_line = false;
late Map<String, dynamic> json_qrcode = {};
String deviceInfo = 'Loading...';

class CupertinoStoreApp extends StatefulWidget {
  @override
  _CupertinoStoreAppState createState() => _CupertinoStoreAppState();
}

class _CupertinoStoreAppState extends State<CupertinoStoreApp> {
  late dynamic box_setting_mqtt;
  @override
  void initState() {
    super.initState();
    initHive();
  }

  Future<void> initHive() async {
    try {
      await Hive.initFlutter();
      box_setting_mqtt = await Hive.openBox<Map>('vis_scanner_setting');

      if (box_setting_mqtt.isNotEmpty) {
        var firstEntry = box_setting_mqtt.getAt(0);
        dotenv.env['MQTT_SERVER_URL'] = firstEntry['mqtt_server'];
        dotenv.env['MQTT_TOPIC'] = firstEntry['mqtt_topic'];
        deviceName = firstEntry['pc_name'];
      } else {
        // 處理空的情況
        print('Box is empty');
      }
    } catch (e) {
      // 處理錯誤
      print('Error initializing Hive: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    dotenv.load(fileName: 'assets/.env');
    // This app is designed only to work vertically, so we limit
    // orientations to portrait up and down.
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    return CupertinoApp(
      builder: (context, child) {
        child = BotToastInit()(context, child); // 初始化 BotToast
        return child;
      },
      debugShowCheckedModeBanner: false,
      navigatorObservers: [BotToastNavigatorObserver()],
      home: CupertinoStoreHomePage(),
    );
  }
}

class CupertinoStoreHomePage extends StatefulWidget {
  const CupertinoStoreHomePage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CupertinoStoreHomePageState createState() => _CupertinoStoreHomePageState();
}

class _CupertinoStoreHomePageState extends State<CupertinoStoreHomePage> {
  late dynamic box_setting_mqtt;
  //final Widget _viewPage_bc = BarcodeScannerView();
  final Widget _PtsLingJian = PtsLingJian();
  @override
  void initState() {
    super.initState();
    initHive();
  }

  Future<void> initHive() async {
    await Hive.initFlutter();
    box_setting_mqtt = await Hive.openBox('vis_scanner_setting');

    dotenv.env['MQTT_SERVER_URL'] =
        box_setting_mqtt.values.first['mqtt_server'];
    dotenv.env['MQTT_TOPIC'] = box_setting_mqtt.values.first['mqtt_topic'];
    deviceName = box_setting_mqtt.values.first['pc_name'];
  }

  @override
  Widget build(BuildContext context) {
    bool isIpad = MediaQuery.of(context).size.shortestSide >= 600;

    cpConnectButton = ConnectButton(mqtt_server_connect: () {
      connect_Server(box_setting_mqtt.values.first['mqtt_server']!,
          box_setting_mqtt.values.first['mqtt_topic']!);
      deviceName = dotenv.env['MQTT_TOPIC']!;
    });
    viewPageQrcode = QrcodeScannerView(onJsonDecoded: (json) async {
      json_qrcode = json;
      deviceName = json_qrcode['topic'];
      dotenv.env['MQTT_SERVER_URL'] = "ws://" + json_qrcode['mqtt'];
      dotenv.env['MQTT_TOPIC'] = json_qrcode['topic'];
      var box_setting = await Hive.openBox('vis_scanner_setting');

      var item_setting = {
        'mqtt_server': dotenv.env['MQTT_SERVER_URL'],
        'mqtt_topic': dotenv.env['MQTT_TOPIC'],
        'pc_name': dotenv.env['MQTT_TOPIC'],
      };
      await box_setting.put('mqtt_setting', item_setting);
      if (json_qrcode['mqtt'] == '' || json_qrcode['topic'] == '') {
        BotToast.showText(
          text: '請先掃描 QR Code',
          duration: Duration(seconds: 3),
          align: Alignment.bottomCenter,
          contentColor: Colors.red,
          textStyle: TextStyle(color: Colors.white, fontSize: 16),
        );
        return;
      }

      if (json_qrcode['mqtt'] == '' || json_qrcode['topic'] == '') {
        BotToast.showText(
          text: '請先掃描 QR Code',
          duration: Duration(seconds: 3),
          align: Alignment.bottomCenter,
          contentColor: Colors.red,
          textStyle: TextStyle(color: Colors.white, fontSize: 16),
        );
        return;
      }
      connect_Server(json_qrcode['mqtt'], json_qrcode['topic']);
    });

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.zero,

        middle: Text(
          'VIS Scanner',
          style: TextStyle(color: Colors.black),
        ),
        leading: Icon(CupertinoIcons.bars), // 加上系統設定的 ICON
        // backgroundColor: CupertinoColors.activeBlue,
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey, // 設置邊框顏色為灰色
            width: 2.0, // 設置邊框寬度
          ),
        ),

        //backgroundColor: CupertinoColors.systemRed,
      ),
      backgroundColor: CupertinoColors.white,
      child: Stack(
        children: [
          SingleChildScrollView(
            //scrollDirection: Axis.vertical,
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 插入一個空白的空間
                SizedBox(height: 58),
                Divider(
                  color: CupertinoColors.systemGrey, // 設置水平線顏色
                  thickness: 1.0, // 設置水平線厚度
                ),
                cpConnectButton,
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: isIpad ? 200 : 120,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero, // 移除內邊距
                            onPressed: () {
                              // 按鈕點擊事件處理邏輯
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => this._PtsLingJian));
                            },
                            child: SizedBox(
                              height: isIpad ? 200 : 120, // 設置高度
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(8.0), // 設置圓角
                                      child: Image.asset(
                                        'assets/images/btn_01.jpg', // 替換為你的按鈕底圖路徑
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    color:
                                        CupertinoColors.white.withOpacity(0.7),
                                    width: double.infinity,
                                    padding: EdgeInsets.all(8.0), // 添加一些內邊距
                                    child: Text(
                                      'PTS\n零件上機/下機',
                                      style: TextStyle(
                                          color: CupertinoColors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: isIpad ? 200 : 120,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(8.0), // 設置圓角
                                  child: Image.asset(
                                    'assets/images/btn_02.jpg', // 替換為你的按鈕底圖路徑
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                color: CupertinoColors.white.withOpacity(0.7),
                                width: double.infinity,
                                padding: EdgeInsets.all(8.0), // 添加一些內邊距
                                child: Text(
                                  'Excel\n掃描到Excel',
                                  style:
                                      TextStyle(color: CupertinoColors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: isIpad ? 200 : 120,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(8.0), // 設置圓角
                                  child: Image.asset(
                                    'assets/images/btn_03.jpg', // 替換為你的按鈕底圖路徑
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                color: CupertinoColors.white.withOpacity(0.7),
                                width: double.infinity,
                                padding: EdgeInsets.all(8.0), // 添加一些內邊距
                                child: Text(
                                  'PTS\n出貨QC檢查',
                                  style:
                                      TextStyle(color: CupertinoColors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: isIpad ? 200 : 120,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(8.0), // 設置圓角
                                  child: Image.asset(
                                    'assets/images/btn_busy.jpg', // 替換為你的按鈕底圖路徑
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                color: CupertinoColors.white.withOpacity(0.7),
                                width: double.infinity,
                                padding: EdgeInsets.all(8.0), // 添加一些內邊距
                                child: Text(
                                  '\n施工中',
                                  style:
                                      TextStyle(color: CupertinoColors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: isIpad ? 200 : 120,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(8.0), // 設置圓角
                                  child: Image.asset(
                                    'assets/images/btn_busy.jpg', // 替換為你的按鈕底圖路徑
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                color: CupertinoColors.white.withOpacity(0.7),
                                width: double.infinity,
                                padding: EdgeInsets.all(8.0), // 添加一些內邊距
                                child: Text(
                                  '\n施工中',
                                  style:
                                      TextStyle(color: CupertinoColors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: isIpad ? 200 : 120,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(8.0), // 設置圓角
                                  child: Image.asset(
                                    'assets/images/btn_busy.jpg', // 替換為你的按鈕底圖路徑
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                color: CupertinoColors.white.withOpacity(0.7),
                                width: double.infinity,
                                padding: EdgeInsets.all(8.0), // 添加一些內邊距
                                child: Text(
                                  '\n施工中',
                                  style:
                                      TextStyle(color: CupertinoColors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1), // 添加這行以確保有適當的大小
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '© 2025 世界先進. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> connect_Server(String mqtt_ip, String topic) async {
    print('canred-mqtt-01');
    if (mqtt_ip == '' || topic == '') {
      BotToast.showText(
        text: '請先掃描 QR Code',
        duration: Duration(seconds: 3),
        align: Alignment.bottomCenter,
        contentColor: Colors.red,
        textStyle: TextStyle(color: Colors.white, fontSize: 16),
      );
      return;
    }
    setupMqttClient_Server(mqtt_ip, topic);
    print('canred-mqtt-02');
    try {
      await clientServer.connect();
      print('canred-mqtt-03');
      setState(() {
        mqttIsOnline = true;
        cpConnectButton = ConnectButton(mqtt_server_connect: () {
          connect_Server(
              dotenv.env['MQTT_SERVER_URL']!, dotenv.env['MQTT_TOPIC']!);
        });
        // 我要強制 ConnectButton 重新繪製
      });
    } on NoConnectionException catch (e) {
      print('NoConnectionException:$e');
      clientServer.disconnect();
    } on SocketException catch (e) {
      //print('SocketException:$e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("連接失敗，請檢查網路連線。1111"),
      ));
      BotToast.showText(
        text: '連接失敗，請檢查網路連線。',
        duration: Duration(seconds: 3),
        align: Alignment.bottomCenter,
        contentColor: Colors.red,
        textStyle: TextStyle(color: Colors.white, fontSize: 16),
      );
      //clientServer.disconnect();
    } on Exception catch (e) {
      print('Exception:$e');
      clientServer.disconnect();
    } catch (e) {
      print('Error:$e');
      clientServer.disconnect();
    }
  }

  void setupMqttClient_Server(String qrCode_mqtt_serverip, String topic) {
    if (qrCode_mqtt_serverip != '' && topic != '') {
      if (qrCode_mqtt_serverip.startsWith('ws://')) {
        dotenv.env['MQTT_SERVER_URL'] = qrCode_mqtt_serverip;
      } else {
        dotenv.env['MQTT_SERVER_URL'] = "ws://" + qrCode_mqtt_serverip;
      }
    }
    clientServer =
        MqttServerClient(dotenv.env['MQTT_SERVER_URL']!, 'flutter_client');
    clientServer.port = int.parse(dotenv.env['MQTT_PORT']!);
    clientServer.secure = false;
    clientServer.useWebSocket = true;
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier('Mqtt_MyClientUniqueId')
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .authenticateAs(
            dotenv.env['MQTT_USERNAME']!, dotenv.env['MQTT_PASSWORD']!)
        .withWillQos(MqttQos.atLeastOnce);
    clientServer.keepAlivePeriod = 10;
    clientServer.connectionMessage = connMess;
    clientServer.onDisconnected = onDisconnected;
    clientServer.onConnected = onConnected;
    clientServer.onSubscribed = onSubscribed;
    clientServer.logging(on: true);
    clientServer.setProtocolV311();
  }

  void disconnect() {
    // try {
    //   clientBrowser.disconnect();
    //   setState(() {
    //     mqttIsOnline = false;
    //   });
    // } catch (e) {}
    // try {
    //   clientServer.disconnect();
    //   setState(() {
    //     mqttIsOnline = false;
    //   });
    // } catch (e) {}
    // print('Disconnected');
  }

  void onConnected() {
    setState(() {
      mqttIsOnline = true;
    });

    BotToast.showText(
      text: '連接成功',
      duration: Duration(seconds: 3),
      align: Alignment.bottomCenter,
      contentColor: Colors.green,
      textStyle: TextStyle(color: Colors.white, fontSize: 16),
    );
    print('Connected');
  }

  void onDisconnected() {
    // setState(() {
    //   mqttIsOnline = false;
    // });
    // print('Disconnected');
  }

  void onSubscribed(String topic) {
    print('Subscribed to $topic');
  }
}
