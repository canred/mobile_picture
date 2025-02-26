import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../vision_detector_views/barcode_scanner_view.dart';
import '../widgets/ConnectButton.dart';
import '../widgets/lingJianList.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:bot_toast/bot_toast.dart';

late MqttServerClient clientServer;

class PtsLingJian extends StatefulWidget {
  const PtsLingJian({Key? key}) : super(key: key);

  @override
  _PtsLingJianState createState() => _PtsLingJianState();
}

class _PtsLingJianState extends State<PtsLingJian> {
  late dynamic box;
  late Map<String, dynamic> json_barcode = {};
  late dynamic box_setting_mqtt;
  @override
  void initState() {
    super.initState();
    initHive();
  }

  Future<void> initHive() async {
    await Hive.initFlutter();
    box = await Hive.openBox('lingJian');
    viewPageBarcode = BarcodeScannerView(onScanAfter: (barcode) async {
      var now = DateTime.now();
      var formattedDate = DateFormat('yyyy/MM/dd HH:mm:ss').format(now);
      var item = {
        'id': barcode,
        'barcode': barcode,
        'scan_dt': formattedDate,
        'ack': 'enter',
        'is_send': 0,
      };
      int correctIndex = box.values
          .toList()
          .indexWhere((element) => element['id'] == item['id']);
      if (correctIndex == -1) {
        await box.put(barcode, item);
        setState(() {
          print('更新資料');
        });
      } else {
        print('資料已經存在了');
      }
    });

    box_setting_mqtt = await Hive.openBox('vis_scanner_setting');

    dotenv.env['MQTT_SERVER_URL'] =
        box_setting_mqtt.values.first['mqtt_server'];
    dotenv.env['MQTT_TOPIC'] = box_setting_mqtt.values.first['mqtt_topic'];
    deviceName = box_setting_mqtt.values.first['pc_name'];
  }

  @override
  Widget build(BuildContext context) {
    dotenv.load(fileName: 'assets/.env');

    return ScaffoldMessenger(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('PTS-零件上機/下機', style: TextStyle(color: Colors.black)),
        ),
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 58),
              Divider(
                color: CupertinoColors.systemGrey, // 設置水平線顏色
                thickness: 1.0, // 設置水平線厚度
              ),
              Center(
                child: Builder(
                  builder: (context) {
                    return ConnectButton(
                      mqtt_server_connect: () {
                        if (dotenv.env['MQTT_SERVER_URL'] == '' ||
                            dotenv.env['MQTT_TOPIC'] == '') {
                          BotToast.showText(
                            text: '請先掃描 QR Code',
                            duration: Duration(seconds: 3),
                            align: Alignment.bottomCenter,
                            contentColor: Colors.red,
                            textStyle:
                                TextStyle(color: Colors.white, fontSize: 16),
                          );
                          return;
                        }
                        connect_Server(dotenv.env['MQTT_SERVER_URL']!,
                            dotenv.env['MQTT_TOPIC']!);
                      },
                    );
                  },
                ),
              ),
              Stack(
                children: <Widget>[
                  Transform.translate(
                    offset: Offset(0, -20),
                    child: LingJianList(),
                  ),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white, // 設置底色
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 8),
                            SizedBox(
                              width: 120,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  side: BorderSide(
                                      color: Colors.blue, width: 1.0), // 設置邊框
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(4.0), // 設置圓角
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0), // 調整內邊距
                                  minimumSize: Size(40, 30),
                                ),
                                onPressed: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => viewPageBarcode),
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.camera_alt), // 相機圖標
                                    SizedBox(width: 8), // 圖標和文本之間的間距
                                    Text('掃描'),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            SizedBox(
                              width: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  side: BorderSide(
                                      color: Colors.blue, width: 1.0), // 設置邊框
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(4.0), // 設置圓角
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0), // 調整內邊距
                                  minimumSize: Size(40, 30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.plus_one,
                                      size: 16,
                                    ), // 相機圖標
                                    SizedBox(width: 4), // 圖標和文本之間的間距
                                  ],
                                ),
                                onPressed: () async {
                                  var box = await Hive.openBox('lingJian');
                                  var uuid = Uuid();
                                  var now = DateTime.now();
                                  var formattedDate =
                                      DateFormat('yyyy/MM/dd HH:mm:ss')
                                          .format(now);
                                  var item = {
                                    'id': uuid.v4(),
                                    'barcode': uuid.v4(),
                                    'scan_dt': formattedDate,
                                    'ack': 'enter',
                                    'is_send': 0,
                                  };
                                  await box.put(item['id'], item);
                                  print('item: $item');
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> connect_Server(String mqtt_ip, String topic) async {
    print('canred-mqtt-01');
    setupMqttClient_Server(mqtt_ip, topic);
    print('canred-mqtt-02');
    try {
      await clientServer.connect();
      print('canred-mqtt-03');
      setState(() {
        mqttIsOnline = true;
        cpConnectButton = ConnectButton(mqtt_server_connect: () {
          if (dotenv.env['MQTT_SERVER_URL']! == '' ||
              dotenv.env['MQTT_TOPIC']! == '') {
            BotToast.showText(
              text: '請先掃描 QR Code',
              duration: Duration(seconds: 3),
              align: Alignment.bottomCenter,
              contentColor: Colors.red,
              textStyle: TextStyle(color: Colors.white, fontSize: 16),
            );
            return;
          }
          connect_Server(
              dotenv.env['MQTT_SERVER_URL']!, dotenv.env['MQTT_TOPIC']!);
        });
        // 我要強制 ConnectButton 重新繪製
      });
    } on NoConnectionException catch (e) {
      print('NoConnectionException:$e');
      clientServer.disconnect();
    } on SocketException catch (e) {
      //print('NoConnectionException:$e');
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //   content: Text("連接失敗，請檢查網路連線。1111"),
      // ));
      // BotToast.showText(
      //   text: '連接失敗，請檢查網路連線。2222',
      //   duration: Duration(seconds: 3),
      //   align: Alignment.bottomCenter,
      //   contentColor: Colors.red,
      //   textStyle: TextStyle(color: Colors.white, fontSize: 16),
      // );
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
