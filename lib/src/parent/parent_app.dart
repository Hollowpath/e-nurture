import 'package:flutter/material.dart';
import 'widgets/parent_bottom_nav.dart';
import '../auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'pages/booking_list_page.dart';
import 'pages/home_screen.dart';
import 'pages/profile_scree.dart';
import 'pages/donation_page.dart';

class ParentApp extends StatefulWidget {
  const ParentApp({super.key});

  @override
  _ParentAppState createState() => _ParentAppState();
  
}

class _ParentAppState extends State<ParentApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ParentHomePage(),
    const ParentBookingListPage(),
    const DonationPage(),
    const ParentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        title: const Text('E-Nurture Home'),
        actions: [
          IconButton(
            icon: const Row(
              children: [
              Icon(Icons.logout),
              SizedBox(width: 5),
              Text('Logout'),
              ],
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: ParentBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}