import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:io' show Platform;

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(QRCodeGeneratorApp());
}

class QRCodeGeneratorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coupon QR Code Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QRCodeGeneratorPage(),
    );
  }
}

class QRCodeGeneratorPage extends StatefulWidget {
  @override
  _QRCodeGeneratorPageState createState() => _QRCodeGeneratorPageState();
}

class _QRCodeGeneratorPageState extends State<QRCodeGeneratorPage> {
  String _qrData = '';
  final String _storeName = "XYZ Store"; // Example store name
  final double _couponAmount = 50.0; // Example coupon amount
  final Uuid uuid = Uuid();

  void _generateQRCode() async {
    // Generate unique ID
    final uniqueId = uuid.v4();
    final currentDateTime = DateTime.now().toString();

    setState(() {
      _qrData =
      'Store:$_storeName|Amount:$_couponAmount|ID:$uniqueId|Date:$currentDateTime';
    });

    // Save details to Firebase
    try {
      await FirebaseFirestore.instance.collection('coupons').add({
        'store': _storeName,
        'amount': _couponAmount,
        'id': uniqueId,
        'date': currentDateTime,
      });
      print('Coupon details saved to Firebase');
    } catch (e) {
      print('Failed to save coupon details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Coupon QR Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _generateQRCode,
              child: Text('Generate QR Code'),
            ),
            SizedBox(height: 20),
            if (_qrData.isNotEmpty)
              QrImageView(
                data: _qrData,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            SizedBox(height: 20),
            Text(
              _qrData.isNotEmpty
                  ? 'Scan this QR code at the store to redeem your coupon.'
                  : '',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
