import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // Add this package to your pubspec.yaml

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<String>> _availabilityMap = {}; // Example: Stores availability slots
  bool _isAvailable = true; // Toggle for availability status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Availability Status Toggle
            _buildAvailabilityToggle(),
            const SizedBox(height: 20),

            // Calendar View
            _buildCalendar(),
            const SizedBox(height: 20),

            // Time Slot Selection
            _buildTimeSlotSelection(),
            const SizedBox(height: 20),

            // Booking Requests & Confirmation
            _buildBookingRequests(),
            const SizedBox(height: 20),

            // Availability Preferences
            _buildAvailabilityPreferences(),
            const SizedBox(height: 20),

            // Notification & Alerts
            _buildNotifications(),
          ],
        ),
      ),
    );
  }

  // Availability Status Toggle Widget
  Widget _buildAvailabilityToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Text(
              'Availability Status:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Switch(
              value: _isAvailable,
              onChanged: (value) {
                setState(() {
                  _isAvailable = value;
                });
              },
            ),
            Text(
              _isAvailable ? 'Available' : 'Not Available',
              style: TextStyle(
                color: _isAvailable ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Calendar Widget
  Widget _buildCalendar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          eventLoader: (day) => _availabilityMap[day] ?? [],
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${events.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  // Time Slot Selection Widget
  Widget _buildTimeSlotSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Availability for Selected Day',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_selectedDay != null)
              Column(
                children: [
                  const Text('Select Time Slots:'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: [
                      _buildTimeSlotButton('8:00 AM - 10:00 AM'),
                      _buildTimeSlotButton('10:00 AM - 12:00 PM'),
                      _buildTimeSlotButton('12:00 PM - 2:00 PM'),
                      _buildTimeSlotButton('2:00 PM - 4:00 PM'),
                      _buildTimeSlotButton('4:00 PM - 6:00 PM'),
                    ],
                  ),
                ],
              )
            else
              const Text('Please select a day from the calendar.'),
          ],
        ),
      ),
    );
  }

  // Time Slot Button Widget
  Widget _buildTimeSlotButton(String timeSlot) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          if (_availabilityMap[_selectedDay!] == null) {
            _availabilityMap[_selectedDay!] = [];
          }
          if (_availabilityMap[_selectedDay!]!.contains(timeSlot)) {
            _availabilityMap[_selectedDay!]!.remove(timeSlot);
          } else {
            _availabilityMap[_selectedDay!]!.add(timeSlot);
          }
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _availabilityMap[_selectedDay!]?.contains(timeSlot) ?? false
            ? Colors.blue
            : Colors.grey[300],
      ),
      child: Text(
        timeSlot,
        style: TextStyle(
          color: _availabilityMap[_selectedDay!]?.contains(timeSlot) ?? false
              ? Colors.white
              : Colors.black,
        ),
      ),
    );
  }

  // Booking Requests Widget
  Widget _buildBookingRequests() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Requests',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              title: Text('John - Oct 15, 9:00 AM - 1:00 PM'),
              subtitle: Text('2 children, At Home'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: Colors.green),
                  SizedBox(width: 10),
                  Icon(Icons.close, color: Colors.red),
                ],
              ),
            ),
            const ListTile(
              title: Text('Sarah - Oct 16, 2:00 PM - 6:00 PM'),
              subtitle: Text('1 child, Office'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: Colors.green),
                  SizedBox(width: 10),
                  Icon(Icons.close, color: Colors.red),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to all booking requests
              },
              child: const Text('View All Requests'),
            ),
          ],
        ),
      ),
    );
  }

  // Availability Preferences Widget
  Widget _buildAvailabilityPreferences() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Availability Preferences',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Enable Instant Booking'),
              value: true, // Example value
              onChanged: (value) {
                // Handle instant booking toggle
              },
            ),
            const ListTile(
              title: Text('Advance Notice Requirement'),
              subtitle: Text('At least 24 hours before'),
              trailing: Icon(Icons.edit),
            ),
            const ListTile(
              title: Text('Maximum Daily Hours'),
              subtitle: Text('8 hours'),
              trailing: Icon(Icons.edit),
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
              'Notifications & Alerts',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: true, // Example value
              onChanged: (value) {
                // Handle notification toggle
              },
            ),
            const ListTile(
              title: Text('Sync with Google Calendar'),
              trailing: Icon(Icons.sync),
            ),
          ],
        ),
      ),
    );
  }
}