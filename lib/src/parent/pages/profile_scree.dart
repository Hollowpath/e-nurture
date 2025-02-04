import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ParentProfileScreen extends StatefulWidget {
  const ParentProfileScreen({super.key});

  @override
  _ParentProfileScreenState createState() => _ParentProfileScreenState();
}

class _ParentProfileScreenState extends State<ParentProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String? _selectedProfilePicture; // Store the selected predefined image name
  Map<String, dynamic> _userData = {};

  // Field controllers for editable information
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

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
          _phoneController.text = _userData['phone'] ?? '';
          _addressController.text = _userData['address'] ?? '';
          _bioController.text = _userData['bio'] ?? '';
          _selectedProfilePicture = _userData['profileImageUrl'];
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
          'profileImageUrl': _selectedProfilePicture,
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'bio': _bioController.text,
        }, SetOptions(merge: true));

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _deleteAccount() async {
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
                  : (_userData['profileImageUrl'] != null
                      ? NetworkImage(_userData['profileImageUrl'])
                      : AssetImage('assets/images/pfpArtboard 1.png')) as ImageProvider<Object>?,
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
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                suffixIcon: Icon(Icons.edit),
              ),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                suffixIcon: Icon(Icons.edit),
              ),
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
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Save Profile'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                child: const Text('Logout'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteAccount,
                child: const Text('Delete Account'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}