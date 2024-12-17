import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 250.0,
            ),
            const SizedBox(height: 20),
            Text('Scan this QR Code', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Share.share(qrData);
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
}
