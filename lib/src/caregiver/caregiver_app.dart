import 'package:flutter/material.dart';
import 'widgets/caregiver_bottom_nav.dart';
import '../auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'pages/booking_list_page.dart';
import 'pages/home_screen.dart';
import 'pages/profile_screen.dart';
import 'pages/availability_page.dart';

class CaregiverApp extends StatefulWidget {
  const CaregiverApp({super.key});

  @override
  _CaregiverAppState createState() => _CaregiverAppState();
  
}

class _CaregiverAppState extends State<CaregiverApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const CaregiverHomeScreen(),
    const CaregiverBookingList(),
    const AvailabilityScreen(),
    const CaregiverProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        title: const Text('E-Nurture Home'),
        actions: [],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: CaregiverBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}