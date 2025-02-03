// merged_profile_screen.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'training_certification_page.dart';
import 'package:image_picker/image_picker.dart';


class CaregiverProfileScreen extends StatefulWidget {
  const CaregiverProfileScreen({super.key});

  @override
  _CaregiverProfileScreen createState() => _CaregiverProfileScreen();
}

class _CaregiverProfileScreen extends State<CaregiverProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  Map<String, dynamic> _userData = {};
  final List<String> _certifications = [];
  final TextEditingController _certificationController = TextEditingController();

  // Field controllers for editable information
  final TextEditingController _nameController    = TextEditingController();
  final TextEditingController _ageController     = TextEditingController();
  final TextEditingController _phoneController   = TextEditingController();
  final TextEditingController _bioController     = TextEditingController();
  final TextEditingController _rateController    = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userData = doc.data() as Map<String, dynamic>;
          _nameController.text = _userData['name'] ?? '';
          _ageController.text = _userData['age']?.toString() ?? '';
          _phoneController.text = _userData['phone'] ?? '';
          _bioController.text = _userData['bio'] ?? '';
          _rateController.text = _userData['rate']?.toString() ?? '';
          _serviceController.text = _userData['service'] ?? '';
          // _certifications =
          //     List<String>.from(_userData['certifications'] ?? []);
        });
      }
    }
        await _firestore.collection('users').doc(user!.uid).set({
          'role': 'Childcare Giver',
          'caregiverID': user.uid,
          'name': _nameController.text,
          'age': int.tryParse(_ageController.text) ?? 0,
          'phone': _phoneController.text,
          'bio': _bioController.text,
          'rate': double.tryParse(_rateController.text) ?? 0.0,
          'service': _serviceController.text,
          // 'certifications': _certifications,
        });

  }
  

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      User? user = _auth.currentUser;
      if (user != null) {
        // Upload image if selected
        if (_profileImage != null) {
          Reference storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images/${user.uid}');
          await storageRef.putFile(_profileImage!);
          String imageUrl = await storageRef.getDownloadURL();
          await _firestore.collection('users').doc(user.uid).update({
            'profileImageUrl': imageUrl,
          });
        }

        // Update other fields
        await _firestore.collection('users').doc(user.uid).set({
          'role': 'Childcare Giver',
          'caregiverID': user.uid,
          'name': _nameController.text,
          'age': int.tryParse(_ageController.text) ?? 0,
          'phone': _phoneController.text,
          'bio': _bioController.text,
          'rate': double.tryParse(_rateController.text) ?? 0.0,
          'service': _serviceController.text,
          // 'certifications': _certifications,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _addCertification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Certification'),
        content: TextField(
          controller: _certificationController,
          decoration: const InputDecoration(hintText: 'Enter certification'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_certificationController.text.isNotEmpty) {
                setState(() {
                  _certifications.add(_certificationController.text);
                });
              }
              _certificationController.clear();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Widget for the profile picture section.
  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : (_userData['profileImageUrl'] != null
                      ? NetworkImage(_userData['profileImageUrl'])
                      : null) as ImageProvider<Object>?,
              child: (_profileImage == null &&
                      _userData['profileImageUrl'] == null)
                  ? const Icon(Icons.add_a_photo, size: 40)
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: _pickImage,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget for the Personal Information section (editable).
  Widget _buildPersonalInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Personal Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                suffixIcon: Icon(Icons.edit),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter name' : null,
            ),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Age',
                suffixIcon: Icon(Icons.edit),
              ),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                suffixIcon: Icon(Icons.edit),
              ),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                suffixIcon: Icon(Icons.edit),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  // Certifications and Training Widget
  Widget _buildCertifications(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Certifications and Training',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // List existing certifications
            ..._certifications.map(
              (cert) => ListTile(
                title: Text(cert),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _certifications.remove(cert);
                    });
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrainingCertificationPage()),
              );
              },
              child: const Text('Upload New Certification'),
            ),
            ],
        ),
      ),
    );
  }

  /// Widget for the Rates and Services section (editable).
  Widget _buildRatesAndServices() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rates and Services',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _rateController,
              decoration: const InputDecoration(
                labelText: 'Hourly Rate',
                suffixIcon: Icon(Icons.edit),
              ),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _serviceController,
              decoration: const InputDecoration(
                labelText: 'Services Offered',
                suffixIcon: Icon(Icons.edit),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Below are static sections from your friend's UI design ---

  Widget _buildAvailability() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Availability',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const ListTile(
              title: Text('Calendar View'),
              trailing: Icon(Icons.calendar_today),
            ),
            SwitchListTile(
              title: const Text('Available for Last-Minute Bookings'),
              value: true,
              onChanged: (value) {
                // Handle availability toggle if needed.
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingsAndReviews() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ratings and Reviews',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const ListTile(
              title: Text('Overall Rating'),
              subtitle: Text('★★★★☆ 4.5/5'),
            ),
            const ListTile(
              title: Text('Number of Reviews'),
              subtitle: Text('25 Reviews'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to all reviews screen if needed.
              },
              child: const Text('View All Reviews'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsAndPayments() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Earnings and Payments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const ListTile(
              title: Text('This Week'),
              subtitle: Text('\$200'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to payment history screen.
              },
              child: const Text('View Payment History'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to update payment method screen.
              },
              child: const Text('Update Payment Method'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContact() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Emergency Contact',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ListTile(
              title: Text('Name'),
              subtitle: Text('John Doe'),
              trailing: Icon(Icons.edit),
            ),
            ListTile(
              title: Text('Relationship'),
              subtitle: Text('Spouse'),
              trailing: Icon(Icons.edit),
            ),
            ListTile(
              title: Text('Phone'),
              subtitle: Text('+1 987-654-3210'),
              trailing: Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Settings and Preferences',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: true,
              onChanged: (value) {
                // Handle notification toggle if needed.
              },
            ),
            const ListTile(
              title: Text('Language Preferences'),
              subtitle: Text('English'),
              trailing: Icon(Icons.edit),
            ),
            const ListTile(
              title: Text('Privacy Settings'),
              trailing: Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutAndAccountManagement() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Handle logout logic.
          },
          child: const Text('Logout'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            // Handle account deletion.
          },
          child: const Text(
            'Delete Account',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  // --- Build the overall UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 20),
              _buildPersonalInformation(),
              const SizedBox(height: 20),
              _buildCertifications(context),
              const SizedBox(height: 20),
              _buildAvailability(),
              const SizedBox(height: 20),
              _buildRatesAndServices(),
              const SizedBox(height: 20),
              _buildRatingsAndReviews(),
              const SizedBox(height: 20),
              _buildEarningsAndPayments(),
              const SizedBox(height: 20),
              _buildEmergencyContact(),
              const SizedBox(height: 20),
              _buildSettings(),
              const SizedBox(height: 20),
              _buildLogoutAndAccountManagement(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
