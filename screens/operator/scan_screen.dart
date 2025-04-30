import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  String scannedData = "No scan yet";

  void scanCode() async {
    String result = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.BARCODE,
    );
    if (result != '-1') {
      setState(() => scannedData = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan Material")),
      body: Center(child: Text(scannedData)),
      floatingActionButton: FloatingActionButton(
        onPressed: scanCode,
        child: Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
