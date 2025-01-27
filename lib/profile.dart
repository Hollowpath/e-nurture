import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: ((builder) => bottomSheet()),
                  );
                },
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _imageFile == null
                      ? AssetImage('assets/default_profile.png')
                      : FileImage(File(_imageFile!.path)),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              'John Doe',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Email',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              'john.doe@example.com',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Phone',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '+1234567890',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              '123 Main Street, City, Country',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Choose Profile Photo',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.camera),
                onPressed: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
                label: Text('Camera'),
              ),
              TextButton.icon(
                icon: Icon(Icons.image),
                onPressed: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
                label: Text('Gallery'),
              ),
            ],
          )
        ],
      ),
    );
  }
}