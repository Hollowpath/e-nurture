import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'training_certification_page.dart';

class CaregiverProfileScreen extends StatefulWidget {
  const CaregiverProfileScreen({super.key});

  @override
  _CaregiverProfileScreen createState() => _CaregiverProfileScreen();
}

class _CaregiverProfileScreen extends State<CaregiverProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String? _selectedProfilePicture;
  Map<String, dynamic> _userData = {};
  LatLng _selectedLocation = LatLng(0, 0);
  final TextEditingController _addressController = TextEditingController();
  final List<String> _certifications = [];

  // Field controllers for editable information
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();

  Completer<GoogleMapController> _googleMapController = Completer();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCertifications();
  }

  // Load user data from Firestore
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
          _addressController.text = _userData['address'] ?? '';
          _selectedLocation = LatLng(
            _userData['latitude'] ?? 0.0,
            _userData['longitude'] ?? 0.0,
          );
          _selectedProfilePicture = _userData['profileImageUrl'];
        });
      }
    }
  }

  // Load certifications from Firestore
  Future<void> _loadCertifications() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    // Get the certifications that belong to the logged-in user
    final querySnapshot = await FirebaseFirestore.instance
        .collection('certifications')
        .where('uid', isEqualTo: uid)
        .get();

    final certifications = querySnapshot.docs.map((doc) {
      return doc['fileUrl'] as String;
    }).toList();

    setState(() {
      _certifications.clear();
      _certifications.addAll(certifications);
    });
  }

  // Update user profile
  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'profileImageUrl': _selectedProfilePicture,
          'caregiverID': user.uid,
          'name': _nameController.text,
          'age': int.tryParse(_ageController.text) ?? 0,
          'phone': _phoneController.text,
          'bio': _bioController.text,
          'rate': double.tryParse(_rateController.text) ?? 0.0,
          'service': _serviceController.text,
          'latitude': _selectedLocation.latitude,
          'longitude': _selectedLocation.longitude,
          'address': _addressController.text,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

  // Log out
  Future<void> _logOut() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  // Remove account
  Future<void> _removeAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  // Profile picture widget
  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _showProfilePictureOptions,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _selectedProfilePicture != null
                  ? AssetImage('assets/images/$_selectedProfilePicture')
                  : (_userData['profileImageUrl'] != null
                      ? NetworkImage(_userData['profileImageUrl'])
                      : AssetImage('assets/pfpArtboard 1.png')) as ImageProvider<Object>?,
              child: _selectedProfilePicture == null &&
                      _userData['profileImageUrl'] == null
                  ? const Icon(Icons.add_a_photo, size: 40)
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: _showProfilePictureOptions,
            ),
          ),
        ],
      ),
    );
  }

  // Show profile picture options
  Future<void> _showProfilePictureOptions() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose a Profile Picture'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 14,
              itemBuilder: (context, index) {
                final imageName = 'pfpArtboard ${index + 1}.png';
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedProfilePicture = imageName;
                    });
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    'assets/images/$imageName',
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Location picker widget
  Widget _buildLocationPicker() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Select Your Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedLocation,
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('selected-location'),
                    position: _selectedLocation,
                    infoWindow: InfoWindow(
                      title: 'Your Location',
                    ),
                  ),
                },
                onMapCreated: (GoogleMapController controller) {
                  _googleMapController.complete(controller);
                  controller.animateCamera(
                    CameraUpdate.newLatLng(_selectedLocation),
                  );
                },
                onTap: (LatLng position) {
                  setState(() {
                    _selectedLocation = position;
                  });
                  _moveCameraToMarker();
                },
              ),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Enter Address',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Move camera to marker location
  void _moveCameraToMarker() async {
    final GoogleMapController controller = await _googleMapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLng(_selectedLocation),
    );
  }

  // Personal Information widget
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

  // Certification widget
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
              (cert) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0), // Add spacing
                child: Container(
                  width: double.infinity, // Ensure it takes full width
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0), // Optional rounded corners
                        child: Image.network(
                          cert,
                          width: double.infinity, // Make it responsive
                          height: 200, // Set a fixed height
                          fit: BoxFit.contain, // Ensure the full image is visible
                        ),
                      ),
                    ],
                  ),
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

  // Save Profile button
  Widget _buildSaveProfileButton() {
    return ElevatedButton(
      onPressed: _updateProfile,
      child: const Text('Save Profile'),
    );
  }

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
              _buildLocationPicker(),
              const SizedBox(height: 20),
              _buildSaveProfileButton(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logOut,
                child: const Text('Log Out'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _removeAccount,
                child: const Text('Remove Account'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
