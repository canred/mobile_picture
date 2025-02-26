import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:bot_toast/bot_toast.dart';
import 'detector_view.dart';
import 'painters/barcode_detector_painter.dart';
import '../main.dart';

class BarcodeScannerView extends StatefulWidget {
  final Function(String) onScanAfter;

  BarcodeScannerView({required this.onScanAfter});
  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView> {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _canProcess = true;

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
      title: 'Barcode Scanner',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (qrcode_isBusy) return;
    qrcode_isBusy = true;
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
            widget.onScanAfter(barcodes.last.rawValue.toString());
            // 在返回上一個畫面之前進行清理操作
            //_canProcess = false;
            //_barcodeScanner.close();
            //Navigator.pop(context); // 返回到 main 畫面
          } catch (e) {}
        }

        //print("canred" + barcodes.last.rawValue!!);
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
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    qrcode_isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
