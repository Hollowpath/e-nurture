import 'dart:io'; // Import for File class
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrainingCertificationPage extends StatefulWidget {
  const TrainingCertificationPage({super.key});

  @override
  _TrainingCertificationPageState createState() =>
      _TrainingCertificationPageState();
}

class _TrainingCertificationPageState extends State<TrainingCertificationPage> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  List<Map<String, String>> _certifications = []; // List of certifications
  final TextEditingController _certificateNameController = TextEditingController();

  // Upload Certification
  Future<void> _uploadCertification() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    final String certificateName = _certificateNameController.text.trim();

    if (pickedFile != null && certificateName.isNotEmpty) {
      setState(() {
        _isUploading = true;
      });

      try {
        final storageRef = FirebaseStorage.instance.ref().child('certificates/${pickedFile.name}');
        final uploadTask = storageRef.putFile(File(pickedFile.path));

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          setState(() {
            _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        });

        final snapshot = await uploadTask.whenComplete(() {});
        final fileUrl = await snapshot.ref.getDownloadURL();
        final String uid = FirebaseAuth.instance.currentUser!.uid;

        // Store certificate in Firestore
        await FirebaseFirestore.instance.collection('certifications').add({
          'uid': uid,  // Save UID with certificate
          'name': certificateName,
          'fileUrl': fileUrl,  // Store the file URL
        });

        // Refresh the certificates list
        _loadCertifications();

        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
          _certificateNameController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$certificateName uploaded successfully!')),
        );
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload certification: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file and enter a certificate name.')),
      );
    }
  }

  // Fetch certifications from Firestore
  Future<void> _loadCertifications() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('certifications')
        .where('uid', isEqualTo: uid)
        .get();

    final certifications = querySnapshot.docs.map((doc) {
      return {
        'name': doc['name'] as String,  // Explicitly cast to String
        'fileUrl': doc['fileUrl'] as String,  // Explicitly cast to String
      };
    }).toList();

    setState(() {
      _certifications = certifications;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCertifications(); // Load certifications when the screen is initialized
  }

  // Display uploaded certificates
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
                          subtitle: Image.network(certification['fileUrl']!),
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

  // Delete Certification
  void _deleteCertification(Map<String, String> certification) async {
    try {
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
            if (_isUploading)
              Column(
                children: [
                  const Text('Uploading Certificate...'),
                  LinearProgressIndicator(value: _uploadProgress),
                  Text('${(_uploadProgress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            _buildCertificationsList(),
            TextField(
              controller: _certificateNameController,
              decoration: const InputDecoration(
                labelText: 'Certificate Name',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _uploadCertification,
              child: const Text('Upload Certification'),
            ),
          ],
        ),
      ),
    );
  }
}
