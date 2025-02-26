import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:bot_toast/bot_toast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../app.dart';
import '../main.dart';

class LingJianList extends StatefulWidget {
  @override
  _LingJianListState createState() => _LingJianListState();
}

class _LingJianListState extends State<LingJianList> {
  var box = Hive.box('lingJian');
  late MqttServerClient clientServer;

  late dynamic box_setting_mqtt;

  @override
  void initState() {
    super.initState();
    initHive();
  }

  Future<void> initHive() async {
    await Hive.initFlutter();
    box = await Hive.openBox('lingJian');
    box_setting_mqtt = await Hive.openBox('vis_scanner_setting');
    dotenv.env['MQTT_SERVER_URL'] =
        box_setting_mqtt.values.first['mqtt_server'];
    dotenv.env['MQTT_TOPIC'] = box_setting_mqtt.values.first['mqtt_topic'];
    deviceName = box_setting_mqtt.values.first['pc_name'];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 200, // 設置高度
      child: box.length > 0
          ? Container(
              width: double.infinity,
              child: ValueListenableBuilder(
                valueListenable: Hive.box('lingJian').listenable(),
                builder: (context, Box box, _) {
                  List<Map<dynamic, dynamic>> sortedItems = [];
                  for (var i = 0; i < box.length; i++) {
                    sortedItems.add(box.getAt(i));
                  }
                  sortedItems
                      .sort((a, b) => a['scan_dt'].compareTo(b['scan_dt']));
                  return ListView.builder(
                    //shrinkWrap: true,
                    itemCount: sortedItems.length,
                    itemBuilder: (context, index) {
                      var item = sortedItems[index];
                      var scanDt = DateFormat('yyyy/MM/dd HH:mm:ss')
                          .parse(item['scan_dt']);
                      var formattedTime = DateFormat('HH:mm:ss').format(scanDt);
                      return Container(
                        color: const Color.fromARGB(40, 190, 187, 187), // 設置底色
                        child: Column(
                          children: [
                            Divider(),
                            Row(children: [
                              Text("  時間:" + formattedTime,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black)),
                              SizedBox(width: 10),
                              item['is_send'] > 0
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green, // 設置底色
                                        border: Border.all(
                                            color: Colors.black,
                                            width: 0.0), // 設置邊框
                                        borderRadius:
                                            BorderRadius.circular(4.0), // 設置圓角
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                          vertical: 2.0), // 設置內邊距
                                      child: Text("已送出",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white)),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 218, 121, 114), // 設置底色
                                        border: Border.all(
                                            color: Colors.green,
                                            width: 0), // 設置邊框
                                        borderRadius:
                                            BorderRadius.circular(4.0), // 設置圓角
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                          vertical: 2.0), // 設置內邊距
                                      child: Text("未送出",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0))),
                                    ),
                              Expanded(child: Container()),
                              IconButton(
                                  onPressed: () {
                                    int correctIndex = box.values
                                        .toList()
                                        .indexWhere((element) =>
                                            element['id'] == item['id']);
                                    if (correctIndex != -1) {
                                      Hive.box('LingJian')
                                          .deleteAt(correctIndex);
                                    } else {
                                      print('item not found');
                                    }
                                  },
                                  icon: Icon(Icons.delete, color: Colors.red)),
                              IconButton(
                                  onPressed: () async {
                                    publishMessage_server(
                                        "barcode/" +
                                            box_setting_mqtt
                                                .values.first['mqtt_topic']!,
                                        """{"sendkey":"${item['barcode']}","ack":"${item['ack']}"}""");

                                    int correctIndex = box.values
                                        .toList()
                                        .indexWhere((element) =>
                                            element['id'] == item['id']);
                                    if (correctIndex != -1) {
                                      var obj_item = Hive.box('lingJian')
                                          .getAt(correctIndex);
                                      Hive.box('lingJian')
                                          .deleteAt(correctIndex);
                                      obj_item['is_send'] = 1;
                                      Hive.box('lingJian')
                                          .put(obj_item['id'], obj_item);
                                      // ScaffoldMessenger.of(context)
                                      //     .showSnackBar(SnackBar(
                                      //   content: Text('已送出'),
                                      //   duration: Duration(seconds: 1),
                                      // ));
                                    } else {
                                      print('item not found');
                                    }
                                  },
                                  icon: Icon(Icons.send))
                            ]),
                            Row(
                              children: [
                                Text("  條碼:" + item['barcode'],
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black)),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 20),
                  Text(
                    '沒有任何條碼資料',
                    style: TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text('請掃描條碼加入資料',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            ),
    );
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

  Future<void> connect_Server() async {
    setupMqttClient_Server(box_setting_mqtt.values.first['mqtt_server']!,
        box_setting_mqtt.values.first['mqtt_topic']!);
    try {
      await clientServer.connect();
      setState(() {
        mqttIsOnline = true;
      });
    } on NoConnectionException catch (e) {
      print('NoConnectionException:$e');
      clientServer.disconnect();
    } on SocketException catch (e) {
      print('SocketException:$e');
      clientServer.disconnect();
    } on Exception catch (e) {
      print('Exception:$e');
      clientServer.disconnect();
    } catch (e) {
      print('Error:$e');
      clientServer.disconnect();
    }
  }

  void publishMessage_server(String topic, String message) async {
    try {
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      await connect_Server();
      builder.addString(message);
      clientServer.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      BotToast.showText(
        text: '\n訊息已經發送\n',
        duration: Duration(seconds: 3),
        align: Alignment.bottomCenter,
        contentColor: Colors.green,
        textStyle: TextStyle(color: Colors.white, fontSize: 16),
      );
      setState(() {
        mqttIsOnline = true;
      });
    } catch (e) {
      setState(() {
        mqttIsOnline = false;
      });
      BotToast.showText(
        text: '有異常 publishMessage_bowser',
        duration: Duration(seconds: 6),
        align: Alignment.bottomCenter,
        contentColor: Colors.red,
        textStyle: TextStyle(color: Colors.black, fontSize: 16),
      );
    }
  }

  void disconnect() {
    // try {
    //   clientServer.disconnect();
    //   setState(() {
    //     mqttIsOnline = false;
    //   });
    // } catch (e) {}
    print('Disconnected');
  }

  void onConnected() {
    setState(() {
      mqttIsOnline = true;
    });
    print('Connected');
  }

  void onDisconnected() {
    // setState(() {
    //   mqttIsOnline = false;
    // });
    print('Disconnected');
  }

  void onSubscribed(String topic) {
    print('Subscribed to $topic');
  }
}
