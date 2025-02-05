## Group Name
- The Reel

## Group Members
- Name: Faizal Akhtar Bin Azhar, Matric No: 2124565
- Name: Dhazreel Aiman Bin Darmawi, Matric No: 2116597
- Name: Hanif Asyraf Bin Mohd Sabri, Matric No: 2217813

## Project Initiation
### Title
e-Nurture

### Background of the Problem
The childcare industry faces challenges like limited caregiver access, unreliable services, and poor communication tools, leaving parents struggling to ensure safe, professional care (Reinventing Childcare, 2023; Beebe, 2024). Caregivers seek reliable clients and better resources, while providers must meet rising demands with high standards (Modestino et al., 2021). This paper proposes an "eNurture platform service" to address these issues through digital tools that relieve pain and create gains for parents, caregivers, and providers, aligning with SDG 3 (Good Health and Well-being), SDG 4 (Quality Education), and SDG 8 (Decent Work and Economic Growth).

### Purpose or Objective
The objective of this project is to develop a conceptual eNurture business model for the "Childcare E-Platform" that integrates digital platforms and apps to provide child caretaker services acting as pain relievers and gain creators, including:
- Providing parents with secured, reviewed, user-friendly tools for finding and vetting child caregivers, enhancing their trust and confidence.
- Offering customizable childcare service packages and flexible booking options to accommodate various family schedules and needs.
- Integrating real-time communication, monitoring, and tracking features for transparency and peace of mind.
- Equipping child caregivers with access to a supportive, dependable network, enabling them to provide consistently high-quality care.

### Target User
- Parents in need of childcare services
- Childcare givers
- B40 interested in working as childcare givers
- Donors

### Preferred Platform
Platform: Android Mobile App (Only)

## Features and Functionalities
### **Geolocation Services**
#### Implemented by **Faizal Akhtar Bin Azhar (Matric No: 2124565)**
- **Real-time caregiver location tracking.**
- **Google Maps API integration for service discovery.**
- **User-driven location selection.**

#### **Code Snippets**
##### **1. Getting the User’s Current Location**
```dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled. Please enable them.');
    }

    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return Future.error('Location permission denied. Enable it in settings.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}
```
##### **2. Displaying Caregivers on Google Maps**
```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final List<Map<String, dynamic>> caregivers;
  MapScreen({required this.caregivers});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  Set<Marker> _createMarkers() {
    Set<Marker> markers = {};
    var caregiver = widget.caregivers[0];
    markers.add(
      Marker(
        markerId: MarkerId(caregiver['name']),
        position: LatLng(caregiver['latitude'], caregiver['longitude']),
        infoWindow: InfoWindow(
          title: caregiver['name'],
          snippet: 'Rating: ${caregiver['rating']}',
        ),
      ),
    );
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Caregiver's Location")),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.caregivers[0]['latitude'], widget.caregivers[0]['longitude']),
          zoom: 14.0,
        ),
        markers: _createMarkers(),
      ),
    );
  }
}
```

### **Image Uploading for Certifications**
#### Implemented by **Faizal Akhtar Bin Azhar (Matric No: 2124565)**
- **Uploading caregiver training certificates to Firebase Storage.**
- **Displaying uploaded certifications as images within the app.**

##### **3. Uploading Certification to Firebase**
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrainingCertificationPage extends StatefulWidget {
  @override
  _TrainingCertificationPageState createState() => _TrainingCertificationPageState();
}

class _TrainingCertificationPageState extends State<TrainingCertificationPage> {
  Future<void> _uploadCertification() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        final storageRef = FirebaseStorage.instance.ref().child('certificates/${pickedFile.name}');
        final uploadTask = storageRef.putFile(File(pickedFile.path));
        final snapshot = await uploadTask.whenComplete(() {});
        final fileUrl = await snapshot.ref.getDownloadURL();
        final String uid = FirebaseAuth.instance.currentUser!.uid;

        await FirebaseFirestore.instance.collection('certifications').add({
          'uid': uid,
          'name': pickedFile.name,
          'fileUrl': fileUrl,
        });
      } catch (e) {
        print('Failed to upload certification: $e');
      }
    }
  }
}
```

4. **Push Notifications for Real-Time Updates** 
#### Implemented by **Dhazreel Aiman Bin Darmawi (Matric No: 2116597)**
   Push notifications are implemented to provide real-time updates to both parents and caregivers. For example, parents will receive notifications when a caregiver confirms their booking.
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService() {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String status, String caregiverName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'caretaker_request_channel',
      'Caretaker Request Notifications',
      channelDescription: 'Notifications for caretaker requests',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Booking $status',
      'Your booking request has been $status by $caregiverName.',
      platformChannelSpecifics,
      payload: caregiverName,
    );
  }
}
```

5. **User Profile and Sentiment-Based Review System**
#### Implemented by **Dhazreel Aiman Bin Darmawi (Matric No: 2116597)**
   **Mobile-based sentiment analysis** can help summarize caregiver reviews into an overall sentiment score. Ratings and reviews will be collected and displayed within the app to build trust and ensure transparency between caregivers and parents.
```dart
// Rating and Reviews Functionality

double _averageRating = 0.0;
List<Map<String, dynamic>> _reviews = [];

// Fetch reviews from Firestore
Future<void> _fetchReviews() async {
  User? user = _auth.currentUser;
  if (user != null) {
    QuerySnapshot querySnapshot = await _firestore
        .collection('reviews')
        .where('caregiverID', isEqualTo: user.uid)
        .get();

    setState(() {
      _reviews = querySnapshot.docs.map((doc) {
        return {
          'rating': doc['rating'] ?? 0.0,
          'comment': doc['comment'] ?? '',
          'reviewer': doc['reviewer'] ?? 'Anonymous',
          'timestamp': doc['timestamp'] ?? Timestamp.now(),
        };
      }).toList();
    });

    _calculateAverageRating();
  }
}

// Calculate average rating
void _calculateAverageRating() {
  if (_reviews.isNotEmpty) {
    double totalRating = _reviews.fold(0, (sum, review) => sum + review['rating']);
    setState(() {
      _averageRating = totalRating / _reviews.length;
    });
  }
}

// Widget to display ratings and reviews
Widget _buildRatingsAndReviews() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Ratings & Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Icon(Icons.star, color: Colors.amber),
              Text(_averageRating.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 10),
          _reviews.isNotEmpty
              ? Column(
                  children: _reviews.map((review) {
                    return ListTile(
                      leading: Icon(Icons.person, color: Colors.grey),
                      title: Text(review['reviewer']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < review['rating'] ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                              );
                            }),
                          ),
                          Text(review['comment']),
                          Text(
                            DateFormat('yyyy-MM-dd').format((review['timestamp'] as Timestamp).toDate()),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              : const Center(child: Text('No reviews yet')),
        ],
      ),
    ),
  );
}

```
##### **6. User based authentication**
#### Implemented by **Hanif Asyraf Bin Mohd Sabri (Matric No: 2217813)**
```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  Future<User?> signUpWithEmail(
    String email,
    String password,
    String role,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await _firestore.collection('users').doc(result.user?.uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return result.user;
    } catch (e) {
      print("Registration error: $e");
      return null;
    }
  }

  Future<void> signOut() async => await _auth.signOut();

  Future<String> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.get('role') ?? 'unknown';
  }
}
```
```dart
void _handleLogin() async {
  if (_formKey.currentState!.validate()) {
    final user = await _authService.signInWithEmail(
      _emailController.text,
      _passwordController.text,
    );
    if (user == null) {
      Get.snackbar('Error', 'Login failed');
    } else {
      Get.off(() => RoleBasedNavigation.determineHomeScreen(user));
    }
  }
}
```
```dart
 void _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      final user = await _authService.signUpWithEmail(
        _emailController.text,
        _passwordController.text,
        _selectedRole,
      );
      if (user == null) {
        Get.snackbar('Error', 'Registration failed');
      } else {
        Get.off(() => RoleBasedNavigation.determineHomeScreen(user));
      }
    }
  }
```
##### **7. Display and search users**
#### Implemented by **Hanif Asyraf Bin Mohd Sabri (Matric No: 2217813)**
```dart
Widget _buildSearchList() {
    final Stream<QuerySnapshot<Map<String, dynamic>>> caregiverStream = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: "Childcare Giver")
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: caregiverStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final docs = snapshot.data?.docs ?? [];

        // Filter caregivers based on the search query
        final filteredDocs = docs.where((doc) {
          final name = (doc.data()['name'] ?? '').toString().toLowerCase();
          return name.contains(_searchQuery.toLowerCase());
        }).toList();

        if (filteredDocs.isEmpty) {
          return _buildEmptyState('No caregivers found.');
        }

```
##### **8. Profile Page**
#### Implemented by **Hanif Asyraf Bin Mohd Sabri (Matric No: 2217813)**
```dart
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
          _selectedProfilePicture = _userData['image'];
        });
      }
    }
  }  `
```
```dart
  // Update user profile
  Future<void> _updateProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      User? user = _auth.currentUser;
      if (user != null) {
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
          'address': _addressController.text,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

```


## Requirement Analysis
### Technical Feasibility
The app uses Firebase for backend services including authentication, real-time database, and cloud messaging. Firebase is chosen for its scalability and ease of integration with Flutter. The app will store user profiles, caregiver documents, and booking data on Firestore, with a CRUD system for managing appointments. Geolocation features will be implemented using Google Maps API, and Firebase Cloud Messaging will handle notifications.

### Compatibility
**Software:**
- Google Play Services: For geolocation and in-app messaging.
- Material Design Components: For a consistent user interface experience on Android.
- Firebase Backend Integration: For authentication, real-time database, and notifications.

**Hardware:**
- GPS Module: For geolocation services.
- Camera: For document uploads and profile photos.
- Push Notification Support: Utilizes Firebase Cloud Messaging for real-time updates.

**Testing:**
- Android Emulator: Testing the app on the Flutter emulator and Android Studio to ensure compatibility and functionality.
- Physical Devices: Testing on various Android phone models to verify performance and user experience across different devices.

**Phone models used for testing:**
- Samsung S21+ (specs: [Samsung Galaxy S21+ 5G](https://www.gsmarena.com/samsung_galaxy_s21+_5g-10625.php))
- Samsung A35 (specs: [Samsung Galaxy A35](https://www.gsmarena.com/samsung_galaxy_a35-12705.php))
- Xiaomi Poco F3 (specs: [Xiaomi Poco F3](https://www.gsmarena.com/xiaomi_poco_f3-10758.php))

### Logical Design
- **Sequence Diagram**: ![e-nurture Sequence Diagram](https://github.com/user-attachments/assets/1c9b74a8-48cc-48c6-8d52-74e49b18ae6f)
- **Screen Navigation Flow**: ![e-nurture Screen Navigation Flow](https://drive.google.com/uc?export=view&id=1fNsf8TP5-PWpUoTe9RQgn2h3XJkmRvaS)

## Planning
### Gantt Chart and Timeline
![Gantt Chart for e-Nurture](https://drive.google.com/uc?export=view&id=13dtG3OyqcSJh5PsRyAOwc9_9JOam2BP2)

## Assigned Tasks
### Authentication and User Management
- **Hanif Asyraf Bin Mohd Sabri, Matric No: 2217813**:
  - Implement Firebase Authentication to enable user registration, login, and logout (parents and caregivers).
  - Set up role-based access (e.g., parent vs. caregiver) within the app.
  - Create a simple user profile screen using TextField and ListView widgets for editing profile details.

### Push Notifications
- **Hanif Asyraf Bin Mohd Sabri, Matric No: 2217813**:
  - Integrate Firebase Cloud Messaging to send real-time notifications (e.g., booking confirmations, training reminders).

### UI/UX Implementation
- **Hanif Asyraf Bin Mohd Sabri, Matric No: 2217813**:
  - Build the home screen (with navigation) using Scaffold, AppBar, and BottomNavigationBar.
  - Design the caregiver search and booking screens using ListView, GridView, and Geolocation Services.
  - Implement state management (e.g., Provider or setState) for dynamic UI updates like filtering caregiver profiles by location or rating.

### Real-Time Communication
- **Hanif Asyraf Bin Mohd Sabri, Matric No: 2217813**:
  - Use Firebase Realtime Database or Firestore to enable in-app messaging between parents and caregivers.

### Geolocation and Maps Integration
- **Faizal Akhtar Bin Azhar, Matric No: 2124565**:
  - Implement Google Maps API to display caregivers' locations on a map.
  - Add features to filter caregivers by proximity using geolocation services.

### Booking System
- **Hanif Asyraf Bin Mohd Sabri, Matric No: 2217813**:
  - Create a CRUD system for booking appointments using Firestore.
  - Build a calendar view for caregivers to manage their availability.

### Profile and Document Management
- **Faizal Akhtar Bin Azhar, Matric No: 2124565**:
  - Enable caregivers to upload profile photos and certifications using camera and file picker plugins.

### Shared Responsibilities
**Testing and Debugging**
- **All Members**: 
  - Test the app on physical devices and emulators, covering different Android versions and screen sizes.
  - Fix any identified bugs and ensure consistent performance across devices.

**Integration of Features**
- **All Members**:
  - Collaborate on GitHub for seamless integration of front-end and back-end components.

## What We Applied from the Course
1. **Flutter Basics**: Use widgets like Column, Row, Stack, Container, and ListView for layout.
2. **State Management**: Apply Provider, setState, or other state management tools for dynamic updates.
3. **Firebase**: Authentication, Realtime Database, Firestore, and Cloud Messaging.
4. **Plugins and Packages**: Use FlutterFire plugins, Google Maps, and Camera for app functionality.
5. **Routing**: Implement named routes for navigation between screens.
6. **Testing**: Perform unit tests and app performance testing using Android Studio and emulators.

## References
Clark, K., Lovich, D., McBride, L., De Santis, N., Milian, R., & Baskin, T. (2023, May 3). Reinventing Childcare for Today’s Workforce. Boston Consulting Group. https://www.bcg.com/publications/2023/reinventing-the-childcare-industry-for-the-workforce-of-today?form=MG0AV3

Modestino, A. S., Ladge, J. J., Swartz, A., & Lincoln, A. (2021, April 29). Childcare Is a Business Issue. Harvard Business Review. https://hbr.org/2021/04/childcare-is-a-business-issue?form=MG0AV3

- **Google Maps API Documentation**: [Google Maps for Flutter](https://pub.dev/packages/google_maps_flutter)

- **Firebase Storage for Flutter**: [Firebase Docs](https://firebase.flutter.dev/docs/storage/overview/)

- **Geolocator Plugin**: [Geolocator Package](https://pub.dev/packages/geolocator)
