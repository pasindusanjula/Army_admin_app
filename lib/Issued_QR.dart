import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // Import for RenderRepaintBoundary
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class IssuedQRPage extends StatelessWidget {
  const IssuedQRPage({Key? key}) : super(key: key);

  Future<void> _shareQRCode(GlobalKey key) async {
    try {
      // Step 1: Convert QR widget to image
      RenderRepaintBoundary boundary =
      key.currentContext?.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes == null) throw Exception("Could not generate QR code image");

      // Step 2: Save image to temporary file
      final tempDir = await getTemporaryDirectory();
      final qrFile = File('${tempDir.path}/qr_code.png');
      await qrFile.writeAsBytes(pngBytes);

      // Step 3: Share the image file
      await Share.shareXFiles([XFile(qrFile.path)], text: 'Here is your QR Code');
    } catch (e) {
      print("Error sharing QR Code: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issued QR Codes'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('vehicle-data').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Error Handling
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // No Data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No vehicle data available.'),
            );
          }

          final documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data() as Map<String, dynamic>;

              // Safely access Firestore data
              final vehicleNo = data.containsKey('vehicleNo') ? data['vehicleNo'] : 'N/A';
              final driverName = data.containsKey('driverName') ? data['driverName'] : 'N/A';
              final driverNo = data.containsKey('driverNo') ? data['driverNo'] : 'N/A';

              // Prepare QR data
              final qrData =
                  "Vehicle No: $vehicleNo, Driver Name: $driverName, Driver No: $driverNo";

              // Unique key for each QR code
              final GlobalKey qrKey = GlobalKey();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: ListTile(
                  title: Text("Vehicle No: $vehicleNo"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RepaintBoundary(
                        key: qrKey,
                        child: QrImageView(data: qrData, size: 80),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () {
                              // Edit functionality
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('vehicle-data')
                                  .doc(documents[index].id)
                                  .delete();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.blue),
                            onPressed: () => _shareQRCode(qrKey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
