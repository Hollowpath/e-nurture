import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../parent/parent_app.dart';
import '../caregiver/caregiver_app.dart';
import '../auth/login_screen.dart';


class RoleBasedNavigation {
  static Widget determineHomeScreen(User? user) {
    if (user == null) return const LoginScreen();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const LoginScreen();
        }

        final role = snapshot.data!.get('role') ?? 'unknown';

        switch (role) {
          case 'Parent':
            return const ParentApp();
          case 'Childcare Giver':
            return const CaregiverApp();
          default:
            return const LoginScreen();
        }
      },
    );
  }
}