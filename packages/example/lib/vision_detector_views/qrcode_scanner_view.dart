// filepath: /C:/Users/canred/Downloads/google_ml_kit_flutter-master/google_ml_kit_flutter-master/packages/example/lib/vision_detector_views/qrcode_scanner_view.dart
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:bot_toast/bot_toast.dart';
import 'detector_view.dart';
import 'painters/barcode_detector_painter.dart';

class QrcodeScannerView extends StatefulWidget {
  final Function(Map<String, dynamic>) onJsonDecoded;

  QrcodeScannerView({required this.onJsonDecoded});

  @override
  State<QrcodeScannerView> createState() => _QrcodeScannerViewState();
}

class _QrcodeScannerViewState extends State<QrcodeScannerView> {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;

  @override
  void dispose() {
    _canProcess = false;
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'QRCode Scanner',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final barcodes = await _barcodeScanner.processImage(inputImage);
    if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
      final painter = BarcodeDetectorPainter(
        barcodes,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      try {
        // 這邊有完整的barcode資訊
        if (barcodes.last.rawValue != null) {
          try {
            Map<String, dynamic> jsonObject = jsonDecode(barcodes.last.rawValue.toString());
            widget.onJsonDecoded(jsonObject);
            // 在返回上一個畫面之前進行清理操作
            _canProcess = false;
            _barcodeScanner.close();
            Navigator.pop(context); // 返回到 main 畫面
          } catch (e) {
            BotToast.showText(
              text: '不是有效的連接QRCode',
              duration: Duration(seconds: 10),
              align: Alignment.bottomCenter,
              contentColor: Colors.red,
              textStyle: TextStyle(color: Colors.black, fontSize: 16),
            );
          }
        }
      } catch (e) {
        //print("error");
      }
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'Barcodes found: ${barcodes.length}\n\n';
      for (final barcode in barcodes) {
        text += 'Barcode: ${barcode.rawValue}\n\n';
        print('Barcode found: ${barcode.rawValue}');
        print('Format: ${barcode.format}');
        print('Type: ${barcode.type}');
      }
      _text = text;
      print('text: ${text}');
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
