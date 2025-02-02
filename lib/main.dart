import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'src/auth/login_screen.dart';
import 'src/parent/parent_app.dart';
import 'src/caregiver/caregiver_app.dart';
import 'package:get/get.dart';
// import 'donor_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDUeV-ZOI0EoSeIrF00DgwhhYsI-NlTJyA",
        authDomain: "e-nurture.firebaseapp.com",
        projectId: "e-nurture",
        storageBucket: "e-nurture.firebasasestorage.app",
        messagingSenderId: "888588822737",
        appId: "1:888588822737:web:c0601454c44f5c17b1bdf0",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Nurture',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/parent': (context) => const ParentApp(),
        '/childcare': (context) => const CaregiverApp(),
        // '/donor': (context) => DonorHome(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          } else {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.done) {
                  if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
                    final role = roleSnapshot.data!['role'] as String;
                    
                    switch (role) {
                      case 'Parent':
                        return const ParentApp();
                      case 'Childcare Giver':
                        return const CaregiverApp();
                      // case 'Donor':
                      //   return DonorHome();
                      default:
                        return const LoginScreen();
                    }
                  }
                  return const LoginScreen();
                }
                return const Center(child: CircularProgressIndicator());
              },
            );
          }
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
