import 'package:flutter/material.dart';

class CaregiverHomeScreen extends StatelessWidget {
  const CaregiverHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example data
    final List<Map<String, dynamic>> upcomingBookings = [
      {
        'date': 'Oct 15, 2023',
        'time': '9:00 AM - 1:00 PM',
        'parentName': 'John',
        'children': 2,
        'location': 'At Home',
      },
      {
        'date': 'Oct 16, 2023',
        'time': '2:00 PM - 6:00 PM',
        'parentName': 'Sarah',
        'children': 1,
        'location': 'Office',
      },
    ];

    final bool isAvailable = true; // Example availability status
    final double weeklyEarnings = 200.0; // Example earnings

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
            _buildAvailabilityStatus(isAvailable),
            const SizedBox(height: 20),

            // Upcoming Bookings
            _buildUpcomingBookings(upcomingBookings),
            const SizedBox(height: 20),

            // Earnings Summary
            _buildEarningsSummary(weeklyEarnings),
            const SizedBox(height: 20),

            // Notifications
            _buildNotifications(),
            const SizedBox(height: 20),

            // Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 20),

            // Empty State (if no bookings)
            if (upcomingBookings.isEmpty) _buildEmptyState(),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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
  Widget _buildUpcomingBookings(List<Map<String, dynamic>> bookings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Bookings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (bookings.isEmpty)
          _buildEmptyState()
        else
          Column(
            children: bookings.map((booking) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${booking['date']}, ${booking['time']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text('Parent: ${booking['parentName']}'),
                      Text('Children: ${booking['children']}'),
                      Text('Location: ${booking['location']}'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to booking details
                            },
                            child: const Text('View Details'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to message parent
                            },
                            child: const Text('Message Parent'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
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

  // Empty State Widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No upcoming bookings.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Update your availability to get started!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to set availability screen
            },
            child: const Text('Set Availability'),
          ),
        ],
      ),
    );
  }
}