import 'package:flutter/material.dart';

class ParentBookingListPage extends StatefulWidget {
  const ParentBookingListPage({Key? key}) : super(key: key);

  @override
  _BookingListPageState createState() => _BookingListPageState();
}

class _BookingListPageState extends State<ParentBookingListPage> {
  // Example data for bookings
  final List<Map<String, dynamic>> bookings = [
    {
      'caregiverName': 'Sarah',
      'caregiverAge': 36,
      'rating': 4.5,
      'date': 'Oct 15, 2023',
      'time': '9:00 AM - 1:00 PM',
      'location': 'At Home',
      'status': 'Upcoming',
    },
    {
      'caregiverName': 'John',
      'caregiverAge': 28,
      'rating': 5.0,
      'date': 'Oct 10, 2023',
      'time': '2:00 PM - 6:00 PM',
      'location': 'Office',
      'status': 'Completed',
    },
  ];

  String _selectedFilter = 'All'; // Default filter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search bookings...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          // Booking List
          Expanded(
            child: bookings.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return _buildBookingCard(booking);
                    },
                  ),
          ),
        ],
      ),
      // Call-to-Action Button for New Bookings
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to booking screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Booking Card Widget
  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Caregiver Information
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/caregiver.jpg'), // Add caregiver image
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${booking['caregiverName']}, ${booking['caregiverAge']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text('${booking['rating']}'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Booking Details
            Text('Date: ${booking['date']}'),
            Text('Time: ${booking['time']}'),
            Text('Location: ${booking['location']}'),
            Text('Status: ${booking['status']}'),
            const SizedBox(height: 10),
            // Quick Actions
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to booking details
                  },
                  child: const Text('View Details'),
                ),
                const SizedBox(width: 10),
                if (booking['status'] == 'Upcoming')
                  ElevatedButton(
                    onPressed: () {
                      // Reschedule booking
                    },
                    child: const Text('Reschedule'),
                  ),
                if (booking['status'] == 'Upcoming')
                  const SizedBox(width: 10),
                if (booking['status'] == 'Upcoming')
                  ElevatedButton(
                    onPressed: () {
                      // Cancel booking
                    },
                    child: const Text('Cancel'),
                  ),
              ],
            ),
          ],
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
            'No bookings yet.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start by finding a caregiver!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to booking screen
            },
            child: const Text('Book a Caregiver'),
          ),
        ],
      ),
    );
  }

  // Filter Options Dialog
  void _showFilterOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Bookings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('All'),
              _buildFilterOption('Upcoming'),
              _buildFilterOption('Completed'),
              _buildFilterOption('Canceled'),
            ],
          ),
        );
      },
    );
  }

  // Filter Option Widget
  Widget _buildFilterOption(String filter) {
    return ListTile(
      title: Text(filter),
      trailing: _selectedFilter == filter ? const Icon(Icons.check) : null,
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
        Navigator.pop(context); // Close the dialog
      },
    );
  }
}