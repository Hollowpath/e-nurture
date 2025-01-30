import 'package:flutter/material.dart';

class CaregiverBookingList extends StatelessWidget {
  const CaregiverBookingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example data for bookings
    final List<Map<String, dynamic>> upcomingBookings = [
      {
        'date': 'Oct 15, 2023',
        'time': '9:00 AM - 1:00 PM',
        'parentName': 'John',
        'children': 2,
        'location': 'At Home',
        'status': 'Upcoming',
      },
      {
        'date': 'Oct 16, 2023',
        'time': '2:00 PM - 6:00 PM',
        'parentName': 'Sarah',
        'children': 1,
        'location': 'Office',
        'status': 'Upcoming',
      },
    ];

    final List<Map<String, dynamic>> completedBookings = [
      {
        'date': 'Oct 10, 2023',
        'time': '9:00 AM - 1:00 PM',
        'parentName': 'Mike',
        'children': 3,
        'location': 'At Home',
        'status': 'Completed',
      },
    ];

    final List<Map<String, dynamic>> cancelledBookings = [
      {
        'date': 'Oct 5, 2023',
        'time': '9:00 AM - 1:00 PM',
        'parentName': 'Anna',
        'children': 2,
        'location': 'At Home',
        'status': 'Cancelled',
      },
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Upcoming Bookings
            _buildBookingList(upcomingBookings),
            // Completed Bookings
            _buildBookingList(completedBookings),
            // Cancelled Bookings
            _buildBookingList(cancelledBookings),
          ],
        ),
      ),
    );
  }

  // Booking List Widget
  Widget _buildBookingList(List<Map<String, dynamic>> bookings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
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
                Text(
                  'Status: ${booking['status']}',
                  style: TextStyle(
                    color: booking['status'] == 'Upcoming'
                        ? Colors.blue
                        : booking['status'] == 'Completed'
                            ? Colors.green
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (booking['status'] == 'Upcoming')
                      ElevatedButton(
                        onPressed: () {
                          // Handle reschedule
                        },
                        child: const Text('Reschedule'),
                      ),
                    if (booking['status'] == 'Upcoming')
                      const SizedBox(width: 10),
                    if (booking['status'] == 'Upcoming')
                      ElevatedButton(
                        onPressed: () {
                          // Handle cancel
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Cancel'),
                      ),
                    const Spacer(),
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
      },
    );
  }
}