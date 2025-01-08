import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleHistoryPage extends StatelessWidget {
  const VehicleHistoryPage({Key? key}) : super(key: key);

  void _editVehicle(BuildContext context, DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    final TextEditingController vehicleNoController =
    TextEditingController(text: data['vehicleNo']);
    final TextEditingController inTimeController =
    TextEditingController(text: data['IN-Time']);
    final TextEditingController outTimeController =
    TextEditingController(text: data['OUT-Time']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Vehicle Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vehicleNoController,
                decoration: const InputDecoration(labelText: 'Vehicle No'),
              ),
              TextField(
                controller: inTimeController,
                decoration: const InputDecoration(labelText: 'IN-Time'),
              ),
              TextField(
                controller: outTimeController,
                decoration: const InputDecoration(labelText: 'OUT-Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('vehicle-data')
                    .doc(document.id)
                    .update({
                  'vehicleNo': vehicleNoController.text,
                  'IN-Time': inTimeController.text,
                  'OUT-Time': outTimeController.text,
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteVehicle(BuildContext context, String documentId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Vehicle'),
          content: const Text('Are you sure you want to delete this record?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('vehicle-data')
                    .doc(documentId)
                    .delete();
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle History'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('vehicle-data').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No vehicle history available.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final document = documents[index];
              final data = document.data() as Map<String, dynamic>;
              final vehicleNo = data['vehicleNo']?.toString() ?? 'N/A';
              final inTime = data['IN-Time']?.toString() ?? 'N/A';
              final outTime = data['OUT-Time']?.toString() ?? 'N/A';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: ListTile(
                  leading: const Icon(Icons.directions_car, color: Colors.blueAccent),
                  title: Text(
                    "Vehicle No: $vehicleNo",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "IN-Time: $inTime\nOUT-Time: $outTime",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.green),
                        onPressed: () => _editVehicle(context, document),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteVehicle(context, document.id),
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
