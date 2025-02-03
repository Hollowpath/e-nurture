import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingCertificationPage extends StatefulWidget {
  const TrainingCertificationPage({super.key});

  @override
  _TrainingCertificationPageState createState() =>
      _TrainingCertificationPageState();
}

class _TrainingCertificationPageState extends State<TrainingCertificationPage> {
  final List<Map<String, String>> _certifications = []; // List of certifications
  final double _trainingProgress = 0.5; // Example training progress (50%)

  @override
  void initState() {
    super.initState();
    _loadCertifications();
  }

  Future<void> _loadCertifications() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('certifications').get();
      final certifications = querySnapshot.docs.map((doc) {
        return {
          'name': doc['name'],
          'file': doc['fileUrl'],
        };
      }).toList();

      setState(() {
        _certifications.addAll(certifications.map((cert) => cert.map((key, value) => MapEntry(key, value.toString()))));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load certifications: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training & Certifications'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Training Progress
            _buildTrainingProgress(),
            const SizedBox(height: 20),

            // Certifications List
            _buildCertificationsList(),
            const SizedBox(height: 20),

            // Upload Certification Button
            ElevatedButton(
              onPressed: _uploadCertification,
              child: const Text('Upload Certification'),
            ),
            const SizedBox(height: 20),

            // Training Materials
            _buildTrainingMaterials(),
          ],
        ),
      ),
    );
  }

  // Training Progress Widget
  Widget _buildTrainingProgress() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Training Progress',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: _trainingProgress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 10),
            Text('${(_trainingProgress * 100).toStringAsFixed(0)}% completed'),
          ],
        ),
      ),
    );
  }

  // Certifications List Widget
  Widget _buildCertificationsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Certifications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_certifications.isEmpty)
              const Text('No certifications uploaded yet.')
            else
              Column(
                children: _certifications
                    .map((certification) => ListTile(
                          title: Text(certification['name']!),
                          subtitle: certification['file']!.startsWith('http')
                              ? Image.network(
                                  certification['file']!,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text('Invalid Image Data');
                                  },
                                )
                              : Text(certification['file']!),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCertification(certification),
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  // Upload Certification
  void _uploadCertification() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController urlController = TextEditingController();
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Certification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Certification Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'Certification URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop({
                  'name': nameController.text,
                  'file': urlController.text,
                });
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    if (result != null && result['name']!.isNotEmpty && result['file']!.isNotEmpty) {
      await _uploadCertificationToFirebase(context, result['name']!, result['file']!);
      setState(() {
        _certifications.add({
          'name': result['name']!,
          'file': result['file']!, // Display the URL
        });
      });
    }
  }

  // Delete Certification
  void _deleteCertification(Map<String, String> certification) async {
    try {
      // Delete from Firestore (assuming you have the document ID)
      final querySnapshot = await FirebaseFirestore.instance
          .collection('certifications')
          .where('name', isEqualTo: certification['name'])
          .get();
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _certifications.remove(certification);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${certification['name']} deleted.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete certification: $e')),
      );
    }
  }

  // Training Materials Widget
  Widget _buildTrainingMaterials() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Training Materials',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              title: Text('Childcare Basics'),
              subtitle: Text('Introduction to childcare best practices.'),
              trailing: Icon(Icons.download),
            ),
            const ListTile(
              title: Text('CPR Training'),
              subtitle: Text('Learn CPR techniques for infants and children.'),
              trailing: Icon(Icons.download),
            ),
            const ListTile(
              title: Text('Special Needs Care'),
              subtitle: Text('Training for caring for children with special needs.'),
              trailing: Icon(Icons.download),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to all training materials
              },
              child: const Text('View All Training Materials'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _uploadCertificationToFirebase(BuildContext context, String name, String fileUrl) async {
  try {
    // Save certification info to Firestore
    await FirebaseFirestore.instance.collection('certifications').add({
      'name': name,
      'fileUrl': fileUrl,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name uploaded successfully!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to upload certification: $e')),
    );
  }
}
