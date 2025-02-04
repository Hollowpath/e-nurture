import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
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
  File? _profileImage;
  Map<String, dynamic> _userData = {};
  LatLng _selectedLocation = LatLng(0, 0); // For Google Maps location
  final TextEditingController _addressController = TextEditingController();
  final List<String> _certifications = [];

  // Field controllers for editable information
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();

  // Completer for GoogleMapController to control the map camera
  Completer<GoogleMapController> _googleMapController = Completer();

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
          _addressController.text = _userData['address'] ?? ''; // Load address
          _selectedLocation = LatLng(
            _userData['latitude'] ?? 0.0,
            _userData['longitude'] ?? 0.0,
          );
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
        
        // Update Firestore with address, image, and other data
        await _firestore.collection('users').doc(user.uid).update({
          'profileImageUrl': imageUrl,
          'latitude': _selectedLocation.latitude,
          'longitude': _selectedLocation.longitude,
          'address': _addressController.text, // Save address here
        });
      } else {
        // Update Firestore without uploading a profile image
        await _firestore.collection('users').doc(user.uid).set({
          'role': 'Childcare Giver',
          'caregiverID': user.uid,
          'name': _nameController.text,
          'age': int.tryParse(_ageController.text) ?? 0,
          'phone': _phoneController.text,
          'bio': _bioController.text,
          'rate': double.tryParse(_rateController.text) ?? 0.0,
          'service': _serviceController.text,
          'latitude': _selectedLocation.latitude,
          'longitude': _selectedLocation.longitude,
          'address': _addressController.text, // Save address here
        });
      }

      // Show confirmation message
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

  /// Widget for the Google Map location picker
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
                target: _selectedLocation, // Set this to the user's saved location
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
                _googleMapController.complete(controller); // Save the controller
                // Move the camera to the marker position after the map is created
                controller.animateCamera(
                  CameraUpdate.newLatLng(_selectedLocation),
                );
              },
              onTap: (LatLng position) {
                setState(() {
                  _selectedLocation = position; // Update marker position
                });
                _moveCameraToMarker(); // Move camera when the user taps the map
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


// Function to move camera to marker location
void _moveCameraToMarker() async {
  final GoogleMapController controller = await _googleMapController.future;
  controller.animateCamera(
    CameraUpdate.newLatLng(_selectedLocation),
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
              _buildLocationPicker(), // Add location picker
              const SizedBox(height: 20),
              _buildRatesAndServices(),
              const SizedBox(height: 20),
              _buildEarningsAndPayments(),
              const SizedBox(height: 20),
              _buildRatingsAndReviews(),
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
