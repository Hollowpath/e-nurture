import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final List<String> _daysOfWeek = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _fetchBookingStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchBookingStatus();
  }

  Future<void> _fetchBookingStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final bookingQuery = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookings')
        .where('caregiverID', isEqualTo: widget.caregiverId)
        .get();

    if (bookingQuery.docs.isNotEmpty) {
      setState(() {
        _isBooked = true;
        _status = bookingQuery.docs.first['status'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isBooked = false;
        _status = 'Pending';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
                  backgroundImage: AssetImage(widget.image),
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
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text('${widget.rating}'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('\$${widget.hourlyRate}/hour'),
            Text('Certifications: ${widget.certifications.join(', ')}'),
            Text('Service: ${widget.service}'),
            Text('Availability: ${widget.availability}'),
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
                  onPressed: () {},
                  child: const Text('View Profile'),
                ),
              ],
            ),
            if (_showBookingForm) _buildBookingForm(),
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
      .where('status', whereIn: ['Pending', 'Accepted'])
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


  
}