import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:e_nurture/src/geolocator/map_screen.dart'; // Import the MapScreen
import '../pages/availability_page.dart'; // Import the AvailabilityPage

class ParentCard extends StatefulWidget {
  final String caregiverId;
  final String name;
  final int age;
  final double rating;
  final int hourlyRate;
  final List<String> certifications;
  final String service;
  final String availability;
  final String distance;
  final String image;
  final bool isBooked; // New parameter to check if it's in the Booked List
  final String status; // New parameter for booking status
  final double latitude; // New parameter for latitude
  final double longitude; // New parameter for longitude

  const ParentCard({
    super.key,
    required this.caregiverId,
    required this.name,
    required this.age,
    required this.rating,
    required this.hourlyRate,
    required this.certifications,
    required this.service,
    required this.availability,
    required this.distance,
    required this.image,
    this.isBooked = false, // Default to false
    this.status = 'Pending', // Default status
    required this.latitude, // Required latitude
    required this.longitude, // Required longitude
  });

  @override
  _ParentCardState createState() => _ParentCardState();
}

class _ParentCardState extends State<ParentCard> {
  bool _showBookingForm = false;
  bool _everyday = false;
  List<String> _selectedDays = [];
  int _childQuantity = 1;
  String _location = '';
  bool _isLoading = true;
  bool _isBooked = false;
  String _status = 'Pending';
  double _rating = 0.0;
  String _review = '';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<String> _daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    _listenToBookingStatus();
  }

  void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String status) async {
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

    await flutterLocalNotificationsPlugin.show(
      0,
      'Booking $status',
      'Your booking request has been $status by the caregiver.',
      platformChannelSpecifics,
      payload: widget.name,
    );
  }
  Future<void> _showAvailability() async {
    final caregiverDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.caregiverId)
        .get();

    if (caregiverDoc.exists) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AvailabilityPage(caregiverId: widget.caregiverId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caregiver not found')),
      );
    }
  }

  void _listenToBookingStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookings')
        .where('caregiverID', isEqualTo: widget.caregiverId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final newStatus = snapshot.docs.first['status'];
        if (_status != newStatus && (newStatus == 'Accepted' || newStatus == 'Cancelled')) {
          showNotification(newStatus);
        }
        setState(() {
          _isBooked = true;
          _status = newStatus;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isBooked = false;
          _status = 'Pending';
          _isLoading = false;
        });
      }
    });
  }


  Future<void> _submitRatingAndReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final reviewQuery = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.caregiverId)
        .collection('reviews')
        .where('parentID', isEqualTo: user.uid)
        .get();

    if (reviewQuery.docs.isNotEmpty) {
      // Update the existing review
      final reviewDocId = reviewQuery.docs.first.id;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.caregiverId)
          .collection('reviews')
          .doc(reviewDocId)
          .update({
        'rating': _rating,
        'review': _review,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Add a new review
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.caregiverId)
          .collection('reviews')
          .add({
        'parentID': user.uid,
        'rating': _rating,
        'review': _review,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Recalculate the average rating
    final allReviewsQuery = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.caregiverId)
        .collection('reviews')
        .get();

    double totalRating = 0.0;
    for (var doc in allReviewsQuery.docs) {
      totalRating += doc['rating'];
    }
    final averageRating = totalRating / allReviewsQuery.docs.length;

    // Update the caregiver's rating in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.caregiverId)
        .update({'rating': averageRating});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review submitted!')),
    );

    setState(() {
      _rating = 0.0;
      _review = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final caregiver = {
      'name': widget.name,
      'age': widget.age,
      'latitude': widget.latitude,
      'longitude': widget.longitude,
      'phone': '', // Add phone if available
      'rate': widget.hourlyRate,
      'service': widget.service,
      'address': '', // Add address if available
      'role': '', // Add role if available
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/images/${widget.image}'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.name}, ${widget.age}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < widget.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    Text(
                      widget.rating.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('\$${widget.hourlyRate}/hour'),
            Text('Certifications: ${widget.certifications.join(', ')}'),
            Text('Service: ${widget.service}'),
            // Text('Availability: ${widget.availability}'),
            Text('Distance: ${widget.distance}'),
            if (_isBooked) // Display status if it's in the Booked List
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Status: $_status',
                  style: TextStyle(
                    color: _getStatusColor(_status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (!_isBooked) // Show "Book Now" button only if not in Booked List
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showBookingForm = !_showBookingForm;
                      });
                    },
                    child: const Text('Book Now'),
                  ),
                if (_isBooked) // Show "Cancel Booking" button if in Booked List
                  ElevatedButton(
                    onPressed: _cancelBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Red color for cancel button
                    ),
                    child: const Text('Cancel Booking'),
                  ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to MapScreen with only the selected caregiver's data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(caregivers: [caregiver]),
                      ),
                    );
                  },
                  child: const Text('View Location'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showAvailability,
              child: const Text('Show Availability'),
            ),
            if (_showBookingForm) _buildBookingForm(),
            if (_status == 'Accepted') _buildRatingAndReviewForm(),
          ],
        ),
      ),
    );
  }

  /// Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Accepted':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBookingForm() {
    bool isFormValid() {
      return _childQuantity > 0 && _location.isNotEmpty && (_everyday || _selectedDays.isNotEmpty);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          'Select Days:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        CheckboxListTile(
          title: const Text('Every day'),
          value: _everyday,
          onChanged: (value) {
            setState(() {
              _everyday = value!;
              _selectedDays = _everyday ? List.from(_daysOfWeek) : [];
            });
          },
        ),
        if (!_everyday)
          Wrap(
            children: _daysOfWeek.map((day) {
              return ChoiceChip(
                label: Text(day),
                selected: _selectedDays.contains(day),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDays.add(day);
                    } else {
                      _selectedDays.remove(day);
                    }
                  });
                },
              );
            }).toList(),
          ),
        const SizedBox(height: 10),
        TextFormField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Number of Children',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _childQuantity = int.tryParse(value) ?? 1;
            });
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Location',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _location = value;
            });
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: isFormValid()
              ? () async {
                  await _submitBooking();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Booking confirmed!')),
                    );
                  }
                  setState(() {
                    _showBookingForm = false;
                  });
                }
              : null,
          child: const Text("Confirm Booking"),
        ),
      ],
    );
  }

  Widget _buildRatingAndReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          'Rate and Review:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: () {
                setState(() {
                  _rating = index + 1.0;
                });
              },
            );
          }),
        ),
        const SizedBox(height: 10),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Review',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            setState(() {
              _review = value;
            });
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _rating > 0 && _review.isNotEmpty
              ? _submitRatingAndReview
              : null,
          child: const Text("Submit Review"),
        ),
      ],
    );
  }

  Future<void> _submitBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final bookingRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.caregiverId)
        .collection('pendingBookings')
        .doc();

    await bookingRef.set({
      'parentID': user.uid,
      'childQuantity': _childQuantity,
      'selectedDays': _selectedDays,
      'everyday': _everyday,
      'location': _location,
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Save reference in parent's booking history
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookings')
        .doc(bookingRef.id)
        .set({
          'caregiverID': widget.caregiverId,
          'status': 'Pending',
          'name': widget.name,
        });

    _fetchBookingStatus(); // Refresh booking status after submitting
  }

  Future<void> _cancelBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Find the booking to cancel
    final bookingQuery = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookings')
        .where('caregiverID', isEqualTo: widget.caregiverId)
        .where('status', whereIn: ['Pending', 'Accepted', 'Cancelled'])
        .get();

    if (bookingQuery.docs.isNotEmpty) {
      final bookingId = bookingQuery.docs.first.id;

      // Delete the booking from the parent's bookings collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('bookings')
          .doc(bookingId)
          .delete();

      // Optionally, delete the booking from the caregiver's pending bookings
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.caregiverId)
          .collection('pendingBookings')
          .doc(bookingId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking canceled!')),
      );

      _fetchBookingStatus(); // Refresh booking status after canceling
    }
  }

  void _fetchBookingStatus() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookings')
        .where('caregiverID', isEqualTo: widget.caregiverId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _isBooked = true;
          _status = snapshot.docs.first['status'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isBooked = false;
          _status = 'Pending';
          _isLoading = false;
        });
      }
    });
  }
}




