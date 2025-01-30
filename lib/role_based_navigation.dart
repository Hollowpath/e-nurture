import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'parent_home.dart';
import 'donor_home.dart';
import 'login_screen.dart';
import 'childcare_home';


class RoleBasedNavigation {
  static Widget determineHomeScreen(User? user) {
    if (user == null) return LoginScreen();
    
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final role = snapshot.data?.get('role') ?? 'unknown';
        
        switch (role) {
          case 'Parent':
            return ParentHome();
          case 'Childcare Giver':
            return ChildcareHome();
          case 'Donor':
            return DonorHome();
          default:
            return LoginScreen();
        }
      },
    );
  }
}