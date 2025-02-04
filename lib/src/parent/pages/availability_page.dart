import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class AvailabilityPage extends StatefulWidget {
  final String caregiverId;

  const AvailabilityPage({super.key, required this.caregiverId});

  @override
  _AvailabilityPageState createState() => _AvailabilityPageState();
}

class _AvailabilityPageState extends State<AvailabilityPage> {
  late Future<Map<String, dynamic>> _availabilityFuture;
  late Map<DateTime, List> _events;
  late List _selectedEvents;
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _availabilityFuture = _fetchAvailability();
    _events = {};
    _selectedEvents = [];
  }

  Future<Map<String, dynamic>> _fetchAvailability() async {
    final caregiverDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.caregiverId)
        .get();

    if (caregiverDoc.exists) {
      final data = caregiverDoc.data()!;
      final unavailableDays = List<String>.from(data['unavailableDays'] ?? []);
      final unavailableDates = unavailableDays.map((day) => DateTime.parse(day)).toList();

      setState(() {
        _events = {
          for (var date in unavailableDates) date: ['Unavailable']
        };
      });

      return {
        'startTime': data['startTime'] ?? 'N/A',
        'endTime': data['endTime'] ?? 'N/A',
        'unavailableDays': unavailableDays,
      };
    } else {
      throw Exception('Caregiver not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _availabilityFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final availability = snapshot.data!;
          final startTime = availability['startTime'];
          final endTime = availability['endTime'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Start Time: $startTime'),
                Text('End Time: $endTime'),
                const SizedBox(height: 20),
                const Text(
                  'Unavailable Dates:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TableCalendar(
                  focusedDay: _selectedDay,
                  firstDay: DateTime(2000),
                  lastDay: DateTime(2100),
                  calendarFormat: CalendarFormat.month,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  eventLoader: (day) {
                    return _events[day] ?? [];
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _selectedEvents = _events[selectedDay] ?? [];
                    });
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      if (_events.containsKey(day)) {
                        return Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            day.day.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: _selectedEvents
                        .map((event) => ListTile(
                              title: Text(event.toString()),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
