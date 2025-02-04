import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking_list_page.dart';

class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('You must be logged in to view bookings.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to notifications screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Summary
            _buildProfileSummary(),
            const SizedBox(height: 20),

            // Availability Status
            _buildAvailabilityStatus(true), // Example availability status
            const SizedBox(height: 20),

            // Upcoming Bookings
            _buildUpcomingBookings(user.uid),
            const SizedBox(height: 20),

            // Earnings Summary
            _buildEarningsSummary(200.0), // Example earnings
            const SizedBox(height: 20),

            // Notifications
            _buildNotifications(),
            const SizedBox(height: 20),

            // Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Profile Summary Widget
  Widget _buildProfileSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/caregiver.jpg'), // Add caregiver image
              radius: 30,
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sarah, 36',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Text('4.5'),
                  ],
                ),
                SizedBox(height: 5),
                Text('CPR Certified'),
              ],
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // Navigate to edit profile screen
              },
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  // Availability Status Widget
  Widget _buildAvailabilityStatus(bool isAvailable) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Availability',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Switch(
                  value: isAvailable,
                  onChanged: (value) {
                    // Update availability status
                  },
                ),
                const SizedBox(width: 10),
                Text(
                  isAvailable ? 'Available Today' : 'Unavailable',
                  style: TextStyle(
                    color: isAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to set availability screen
              },
              child: const Text('Set Availability'),
            ),
          ],
        ),
      ),
    );
  }

  // Upcoming Bookings Widget
  Widget _buildUpcomingBookings(String caregiverId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(caregiverId)
          .collection('pendingBookings')
          .where('status', isEqualTo: 'Pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No upcoming bookings.'));
        }

        final bookings = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: bookings.map((booking) {
            final bookingData = booking.data() as Map<String, dynamic>;

            // Fetching parent information
            final parentId = bookingData['parentID'];
            final date = bookingData['timestamp'] != null
                ? (bookingData['timestamp'] as Timestamp).toDate()
                : DateTime.now();
            final time = '${bookingData['selectedDays']}';
            final children = bookingData['childQuantity'];
            final location = bookingData['location'] ?? 'Unknown location';

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(parentId).get(),
              builder: (context, parentSnapshot) {
                if (parentSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (parentSnapshot.hasError || !parentSnapshot.hasData) {
                  return const Text('Error loading parent details.');
                }

                final parent = parentSnapshot.data!.data() as Map<String, dynamic>;
                final parentName = parent['name'] ?? 'Unknown Parent';

                return GestureDetector(
                  onTap: () {
                    // Navigate to the booking list page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CaregiverBookingList(),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${date.toLocal()} at $time',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text('Parent: $parentName'),
                          Text('Children: $children'),
                          Text('Location: $location'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  // Earnings Summary Widget
  Widget _buildEarningsSummary(double weeklyEarnings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Earnings Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'This Week: \$${weeklyEarnings.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to earnings history screen
              },
              child: const Text('View Earnings History'),
            ),
          ],
        ),
      ),
    );
  }

  // Notifications Widget
  Widget _buildNotifications() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.notifications),
              title: Text('New Booking Request'),
              subtitle: Text('From John for Oct 17, 2023'),
            ),
            const ListTile(
              leading: Icon(Icons.payment),
              title: Text('Payment Received'),
              subtitle: Text('\$50 for booking on Oct 10, 2023'),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all notifications screen
              },
              child: const Text('View All Notifications'),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Actions Widget
  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2,
      children: [
        _buildQuickActionButton(Icons.calendar_today, 'Set Availability'),
        _buildQuickActionButton(Icons.person, 'View Profile'),
        _buildQuickActionButton(Icons.message, 'Message Center'),
        _buildQuickActionButton(Icons.school, 'Training'),
      ],
    );
  }

  // Quick Action Button Widget
  Widget _buildQuickActionButton(IconData icon, String label) {
    return Card(
      child: InkWell(
        onTap: () {
          // Handle quick action
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30),
              const SizedBox(height: 5),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
