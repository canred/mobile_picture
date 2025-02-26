import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bot_toast/bot_toast.dart';
import '../main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ConnectButton extends StatefulWidget {
  final Function() mqtt_server_connect;
  ConnectButton({required this.mqtt_server_connect});
  @override
  _ConnectButtonState createState() => _ConnectButtonState();
}

// class QrcodeScannerView extends StatefulWidget {
//   final Function(Map<String, dynamic>) onJsonDecoded;

//   QrcodeScannerView({required this.onJsonDecoded});

//   @override
//   State<QrcodeScannerView> createState() => _QrcodeScannerViewState();
// }

class _ConnectButtonState extends State<ConnectButton> {
  late dynamic box_setting_mqtt;
  @override
  void initState() {
    super.initState();
    initHive();
  }

  Future<void> initHive() async {
    try {
      await Hive.initFlutter();
      var box = await Hive.openBox<Map>('vis_scanner_setting');

      if (box.isNotEmpty) {
        final firstEntry = box.values.first;
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
    print('canred mqttIsOnline: $mqttIsOnline');

    bool isIpad = MediaQuery.of(context).size.shortestSide >= 600;

    return SizedBox(
      height: isIpad ? 200 : 100, // 設置高度
      width: MediaQuery.of(context).size.width * 0.99, // 設置寬度
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/connect.png'), // 設置背景圖片
            fit: BoxFit.fitWidth,
          ),
          borderRadius: BorderRadius.circular(8.0), // 設置邊框圓角
        ),
        child: ElevatedButton(
          onPressed: () {
            widget.mqtt_server_connect();
            // BotToast.showText(
            //   text: box_setting_mqtt.values.first['mqtt_server'],
            //   duration: Duration(seconds: 3),
            //   align: Alignment.bottomCenter,
            //   contentColor: Colors.red,
            //   textStyle: TextStyle(color: Colors.white, fontSize: 16),
            // );
          },
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => viewPageQrcode),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: mqttIsOnline
                ? const Color.fromARGB(255, 246, 247, 246).withOpacity(0.7)
                : const Color.fromARGB(255, 247, 8, 8).withOpacity(0.5),
            shadowColor: Colors.transparent, // 設置陰影顏色
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // 設置按鈕圓角
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 置中對齊
            children: [
              Align(
                alignment: Alignment.centerLeft, // 將文字置中對齊
                child: Text(
                  mqttIsOnline ? '裝置連線中' : '未連接裝置',
                  style: TextStyle(
                    fontSize: 24,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft, // 將文字置中對齊
                child: Text(
                  deviceName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: const Color.fromARGB(255, 17, 17, 204),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft, // 將文字置中對齊
                child: Text(
                  '連接新電腦，請長按。',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ],
          ), // 按鈕文字
        ),
      ),
    );
  }
}
