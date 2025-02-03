import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  DateTime _focusedDay = DateTime.now();
  final Set<DateTime> _unavailableDays = {};
  String? _selectedWeeklyAvailability;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  @override
  void initState() {
    super.initState();
    _fetchAvailability();
  }

  Future<void> _fetchAvailability() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      _selectedWeeklyAvailability = userDoc.data()?['weeklyAvailability'];
      List<dynamic>? unavailableDays = userDoc.data()?['unavailableDays'];
      if (unavailableDays != null) {
        _unavailableDays.addAll(
          unavailableDays.map((date) => DateTime.parse(date)),
        );
      }
      _selectedStartTime = _parseTimeOfDay(userDoc.data()?['startTime']);
      _selectedEndTime = _parseTimeOfDay(userDoc.data()?['endTime']);
    });
  }

  TimeOfDay? _parseTimeOfDay(String? timeString) {
    if (timeString == null) return null;
    final timeParts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
  }

  Future<void> _saveAvailability() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'weeklyAvailability': _selectedWeeklyAvailability,
      'unavailableDays': _unavailableDays.map((date) => date.toIso8601String()).toList(),
      'startTime': _selectedStartTime != null
          ? '${_selectedStartTime!.hour}:${_selectedStartTime!.minute}'
          : null,
      'endTime': _selectedEndTime != null
          ? '${_selectedEndTime!.hour}:${_selectedEndTime!.minute}'
          : null,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Availability saved successfully!')),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? (_selectedStartTime ?? TimeOfDay.now()) : (_selectedEndTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = picked;
        } else {
          _selectedEndTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimePicker(),
              const SizedBox(height: 20),
              _buildUnavailableDaysCalendar(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAvailability,
                child: const Text('Save Availability'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Set Available Time:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text('Start Time:'),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _selectTime(context, true),
              child: Text(_selectedStartTime != null
                  ? _selectedStartTime!.format(context)
                  : 'Select Start Time'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text('End Time:'),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _selectTime(context, false),
              child: Text(_selectedEndTime != null
                  ? _selectedEndTime!.format(context)
                  : 'Select End Time'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnavailableDaysCalendar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mark Unavailable Days:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime.now(),
          lastDay: DateTime(2100),
          selectedDayPredicate: (day) {
            return _unavailableDays.any((d) => isSameDay(d, day));
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              if (_unavailableDays.any((d) => isSameDay(d, selectedDay))) {
                _unavailableDays.removeWhere((d) => isSameDay(d, selectedDay));
              } else {
                _unavailableDays.add(selectedDay);
              }
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}