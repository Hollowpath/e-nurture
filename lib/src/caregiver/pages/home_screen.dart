import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking_list_page.dart';
import 'profile_screen.dart';

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
            _buildAvailabilityDetails(), // Example availability status
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
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('No user logged in'));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Error loading profile data'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final name = userData['name'] ?? 'Unknown';
        final age = userData['age'] ?? 'Unknown';
        final rating = userData['rating'] ?? 0.0;

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('certifications')
              .where('uid', isEqualTo: user.uid)
              .get(),
          builder: (context, certSnapshot) {
            if (certSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (certSnapshot.hasError || !certSnapshot.hasData) {
              return const Center(child: Text('Error loading certifications'));
            }

            final certifications = certSnapshot.data!.docs.map((doc) {
              final certData = doc.data() as Map<String, dynamic>;
              return certData['name'] ?? 'Not certified';
            }).toList();

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: userData['image'] != null
                          ? AssetImage('assets/images/${userData['image']}')
                          : const AssetImage('assets/caregiver.jpg') as ImageProvider,
                      radius: 30,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$name, $age',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            Text(rating.toString()),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: certifications.map((cert) => Text(cert)).toList(),
                        ),
                      ],
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CaregiverProfileScreen(),
                          ),
                        );
                      },
                      child: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Availability Status Widget

  Widget _buildAvailabilityDetails() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('No user logged in'));
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Error loading profile data'));
        }

        final availabilityData = snapshot.data!.data() as Map<String, dynamic>;
        final startTime = availabilityData['startTime'] ?? 'N/A';
        final endTime = availabilityData['endTime'] ?? 'N/A';
        final unavailableDays = List<String>.from(availabilityData['unavailableDays'] ?? []);

        // Convert and sort unavailable days
        final sortedUnavailableDays = unavailableDays.map((day) {
          final date = DateTime.parse(day);
          return date;
        }).toList()
          ..sort();

        // Format dates and take the first 3
        final formattedUnavailableDays = sortedUnavailableDays.take(3).map((date) {
          return '${date.day} ${_monthName(date.month)} ${date.year}';
        }).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Availability Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('Start Time: $startTime'),
                Text('End Time: $endTime'),
                const SizedBox(height: 10),
                const Text(
                  'Unavailable Days:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...formattedUnavailableDays.map((day) => Text(day)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  String _monthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
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
          children: bookings.take(3).map((booking) {
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
                          _buildDayIcons(bookingData['selectedDays']),
                          const SizedBox(height: 5),
                          Text('Parent: $parentName'),
                          Text('Children: $children'),
                          Text('Location: $location'),
                          Text(
                            _formatDate(date),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  Widget _buildDayIcons(List<dynamic> days) {
    final dayIcons = {
      'Mon': Icons.calendar_today,
      'Tue': Icons.calendar_today,
      'Wed': Icons.calendar_today,
      'Thu': Icons.calendar_today,
      'Fri': Icons.calendar_today,
      'Sat': Icons.calendar_today,
      'Sun': Icons.calendar_today,
    };

    return Row(
      children: days.map((day) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            children: [
              Icon(dayIcons[day] ?? Icons.error),
              Text(day),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
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
