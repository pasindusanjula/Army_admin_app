import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'QR_code.dart';
import 'Issued_QR.dart';
import 'Vehicle_history.dart';

class Pasi extends StatefulWidget {
  const Pasi({Key? key}) : super(key: key);

  @override
  State<Pasi> createState() => _PasiState();
}

class _PasiState extends State<Pasi> {
  // Text Editing Controllers
  final TextEditingController _vehicleNoController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverNoController = TextEditingController();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to clear input fields
  void _clearFields() {
    _vehicleNoController.clear();
    _driverNameController.clear();
    _driverNoController.clear();
  }

  // Submit Function to Save Data to Firestore
  Future<void> _submitData() async {
    final vehicleNo = _vehicleNoController.text.trim();
    final driverName = _driverNameController.text.trim();
    final driverNo = _driverNoController.text.trim();

    if (vehicleNo.isNotEmpty && driverName.isNotEmpty && driverNo.isNotEmpty) {
      try {
        // Save data to Firestore
        await _firestore.collection('vehicle-data').add({
          'vehicleNo': vehicleNo,
          'driverName': driverName,
          'driverNo': driverNo,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Prepare data to send to QR Code Page
        final data = {
          'vehicleNo': vehicleNo,
          'driverName': driverName,
          'driverNo': driverNo,
        };

        // Navigate to QR Code Page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QRCodePage(data: data)),
        ).then((_) {
          _clearFields();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data uploaded successfully!')),
        );
      } catch (e) {
        print("Error uploading data: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload data!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Vehicle Data'),
        backgroundColor: Colors.blueAccent,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Issued QR-Code') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const IssuedQRPage()),
                );
              } else if (value == 'Vehicle History') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VehicleHistoryPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'Issued QR-Code',
                child: Text('Issued QR-Code'),
              ),
              const PopupMenuItem(
                value: 'Vehicle History',
                child: Text('Vehicle History'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _vehicleNoController,
              decoration: const InputDecoration(labelText: 'Vehicle No'),
            ),
            TextFormField(
              controller: _driverNameController,
              decoration: const InputDecoration(labelText: 'Driver Name'),
            ),
            TextFormField(
              controller: _driverNoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Driver Number'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
