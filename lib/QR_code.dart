import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QRCodePage extends StatelessWidget {
  final Map<String, String> data;

  const QRCodePage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Combine data into a string for QR code
    final qrData =
        "Vehicle No: ${data['vehicleNo']}, Driver Name: ${data['driverName']}, Driver No: ${data['driverNo']}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // QR Code widget
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250.0,
            ),
            const SizedBox(height: 20),
            const Text('Scan this QR Code', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            // Share Button
            ElevatedButton.icon(
              onPressed: () async {
                await _shareQRCode(qrData);
              },
              icon: const Icon(Icons.share),
              label: const Text('Share QR Code'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  // Method to Share QR Code as an Image
  Future<void> _shareQRCode(String qrData) async {
    try {
      // Step 1: Render the QR code as an image
      final qrValidationResult = QrValidator.validate(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode;

        // Step 2: Convert to image
        final painter = QrPainter.withQr(
          qr: qrCode!,
          color: const Color(0xFF000000),
          gapless: true,
        );

        // Get temporary directory to save the image
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/qr_code.png';

        final picData = await painter.toImageData(300); // Size of the image
        final buffer = picData!.buffer.asUint8List();

        // Write image to file
        final file = await File(filePath).writeAsBytes(buffer);

        // Step 3: Share the image
        await Share.shareXFiles([XFile(file.path)], text: 'Scan this QR Code');
      }
    } catch (e) {
      print('Error sharing QR Code: $e');
    }
  }
}
