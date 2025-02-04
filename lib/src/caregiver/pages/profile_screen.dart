import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
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
  String? _selectedProfilePicture; // Store the selected predefined image name
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
    _fetchReviews(); // Fetch reviews when the screen loads
    _calculateAverageRating(); // Calculate average rating when the screen loads
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
          _selectedProfilePicture = _userData['image'];
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      User? user = _auth.currentUser;
      if (user != null) {
        // Update Firestore with the selected predefined image and other data
        await _firestore.collection('users').doc(user.uid).set({
          'image': _selectedProfilePicture,
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
        }, SetOptions(merge: true));

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

  Future<void> _logOut() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _removeAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).delete();
      await user.delete();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  /// Widget for the profile picture section.
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
                  : (_userData['image'] != null
                      ? NetworkImage(_userData['image'])
                      : AssetImage('assets/pfpArtboard 1.png')) as ImageProvider<Object>?,
              child: _selectedProfilePicture == null &&
                      _userData['image'] == null
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

  /// Show a dialog to choose between predefined profile pictures
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
                crossAxisCount: 3, // 3 images per row
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: 14, // 14 predefined images
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

  Widget _buildRatingsAndReviews() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ratings and Reviews',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<double>(
              future: _calculateAverageRating(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final averageRating = snapshot.data ?? 0.0;
                return Row(
                  children: [
                  const Text('Overall Rating: '),
                  ...List.generate(5, (index) {
                    return Icon(
                    index < averageRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    );
                  }),
                  Text(' (${averageRating.toStringAsFixed(1)}/5)'),
                  ],
                );
              },
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchReviews(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final reviews = snapshot.data ?? [];
              return Column(
                children: [
                ListTile(
                  title: const Text('Number of Reviews'),
                  subtitle: Text('${reviews.length} Reviews'),
                ),
                const SizedBox(height: 10),
                ...reviews.map((review) {
                  return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ExpansionTile(
                    title: Row(
                      children: List.generate(5, (index) {
                      return Icon(
                        index < (review['rating'] ?? 0.0)
                          ? Icons.star
                          : Icons.star_border,
                      );
                      }),
                    ),
                    subtitle: Text(
                      review['timestamp'] != null
                        ? DateFormat('MMM dd, yyyy').format(
                          (review['timestamp'] as Timestamp).toDate(),
                        )
                        : 'No date',
                    ),
                    children: [
                      Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(review['review'] ?? 'No review text'),
                      ),
                    ],
                    ),
                  );
                }).toList(),
                ],
              );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchReviews() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot reviewsSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reviews')
          .get();
      return reviewsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<double> _calculateAverageRating() async {
    List<Map<String, dynamic>> reviews = await _fetchReviews();
    if (reviews.isEmpty) return 0.0;
    double totalRating = 0.0;
    for (var review in reviews) {
      totalRating += review['rating'] ?? 0.0;
    }
    return totalRating / reviews.length;
  }

  Widget _buildAccountActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Log Out'),
              trailing: const Icon(Icons.logout),
              onTap: _logOut,
            ),
            ListTile(
              title: const Text('Remove Account'),
              trailing: const Icon(Icons.delete, color: Colors.red),
              onTap: _removeAccount,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 20),
              _buildPersonalInformation(),
              const SizedBox(height: 20),
              _buildLocationPicker(),
              const SizedBox(height: 20),
              _buildCertifications(context),
              const SizedBox(height: 20),
              _buildRatesAndServices(),
              const SizedBox(height: 20),
              _buildEarningsAndPayments(),
              const SizedBox(height: 20),
              _buildRatingsAndReviews(),
              const SizedBox(height: 20),
              _buildAccountActions(),
            ],
          ),
        ),
      ),
    );
  }
}