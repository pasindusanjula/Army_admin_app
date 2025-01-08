import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;

  const EditPage({Key? key, required this.data, required this.docId}) : super(key: key);

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final TextEditingController _vehicleNoController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vehicleNoController.text = widget.data['vehicleNo'];
    _driverNameController.text = widget.data['driverName'];
    _driverNoController.text = widget.data['driverNo'];
  }

  // Submit the updated data to Firestore
  Future<void> _updateData() async {
    final updatedData = {
      'vehicleNo': _vehicleNoController.text.trim(),
      'driverName': _driverNameController.text.trim(),
      'driverNo': _driverNoController.text.trim(),
    };

    if (updatedData['vehicleNo']!.isNotEmpty && updatedData['driverName']!.isNotEmpty && updatedData['driverNo']!.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('vehicle-data').doc(widget.docId).update(updatedData);
        Navigator.pop(context); // Go back after saving
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data updated successfully!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update data!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Vehicle Data')),
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
              onPressed: _updateData,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
