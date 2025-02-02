import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Add this package to your pubspec.yaml

class TrainingCertificationPage extends StatefulWidget {
  const TrainingCertificationPage({super.key});

  @override
  _TrainingCertificationPageState createState() =>
      _TrainingCertificationPageState();
}

class _TrainingCertificationPageState extends State<TrainingCertificationPage> {
  final List<String> _certifications = []; // List of certifications
  final double _trainingProgress = 0.5; // Example training progress (50%)

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
                          title: Text(certification),
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      final file = result.files.single;
      setState(() {
        _certifications.add(file.name);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${file.name} uploaded successfully!')),
      );
    }
  }

  // Delete Certification
  void _deleteCertification(String certification) {
    setState(() {
      _certifications.remove(certification);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$certification deleted.')),
    );
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