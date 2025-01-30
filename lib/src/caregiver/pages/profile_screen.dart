import 'package:flutter/material.dart';

class CaregiverProfileScreen extends StatelessWidget {
  const CaregiverProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            _buildProfilePicture(),
            const SizedBox(height: 20),

            // Personal Information
            _buildPersonalInformation(),
            const SizedBox(height: 20),

            // Certifications and Training
            _buildCertifications(),
            const SizedBox(height: 20),

            // Availability
            _buildAvailability(),
            const SizedBox(height: 20),

            // Rates and Services
            _buildRatesAndServices(),
            const SizedBox(height: 20),

            // Ratings and Reviews
            _buildRatingsAndReviews(),
            const SizedBox(height: 20),

            // Earnings and Payment Information
            _buildEarningsAndPayments(),
            const SizedBox(height: 20),

            // Emergency Contact Information
            _buildEmergencyContact(),
            const SizedBox(height: 20),

            // Settings and Preferences
            _buildSettings(),
            const SizedBox(height: 20),

            // Logout and Account Management
            _buildLogoutAndAccountManagement(),
          ],
        ),
      ),
    );
  }

  // Profile Picture Widget
  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/caregiver.jpg'), // Add caregiver image
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Handle profile picture edit
              },
            ),
          ),
        ],
      ),
    );
  }

  // Personal Information Widget
  Widget _buildPersonalInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              title: Text('Name'),
              subtitle: Text('Sarah Smith'),
              trailing: Icon(Icons.edit),
            ),
            const ListTile(
              title: Text('Age'),
              subtitle: Text('36'),
              trailing: Icon(Icons.edit),
            ),
            const ListTile(
              title: Text('Email'),
              subtitle: Text('sarah@example.com'),
              trailing: Icon(Icons.edit),
            ),
            const ListTile(
              title: Text('Phone'),
              subtitle: Text('+1 123-456-7890'),
              trailing: Icon(Icons.edit),
            ),
            const ListTile(
              title: Text('Bio'),
              subtitle: Text('Experienced with toddlers and special needs children.'),
              trailing: Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }

  // Certifications and Training Widget
  Widget _buildCertifications() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Certifications and Training',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              title: Text('CPR Certified'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
            const ListTile(
              title: Text('First Aid Certified'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle upload new certification
              },
              child: const Text('Upload New Certification'),
            ),
          ],
        ),
      ),
    );
  }

  // Availability Widget
  Widget _buildAvailability() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Availability',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              title: Text('Calendar View'),
              trailing: Icon(Icons.calendar_today),
            ),
            SwitchListTile(
              title: const Text('Available for Last-Minute Bookings'),
              value: true, // Example value
              onChanged: (value) {
                // Handle availability toggle
              },
            ),
          ],
        ),
      ),
    );
  }

  // Rates and Services Widget
  Widget _buildRatesAndServices() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rates and Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              title: Text('Hourly Rate'),
              subtitle: Text('\$20'),
              trailing: Icon(Icons.edit),
            ),
            const ListTile(
              title: Text('Services Offered'),
              subtitle: Text('Tutoring, Overnight Care'),
              trailing: Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }

  // Ratings and Reviews Widget
  Widget _buildRatingsAndReviews() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ratings and Reviews',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              title: Text('Overall Rating'),
              subtitle: Text('★★★★☆ 4.5/5'),
            ),
            const ListTile(
              title: Text('Number of Reviews'),
              subtitle: Text('25 Reviews'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to all reviews screen
              },
              child: const Text('View All Reviews'),
            ),
          ],
        ),
      ),
    );
  }

  // Earnings and Payment Information Widget
  Widget _buildEarningsAndPayments() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Earnings and Payments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              title: Text('This Week'),
              subtitle: Text('\$200'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to payment history screen
              },
              child: const Text('View Payment History'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to update payment method screen
              },
              child: const Text('Update Payment Method'),
            ),
          ],
        ),
      ),
    );
  }

  // Emergency Contact Information Widget
  Widget _buildEmergencyContact() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Contact',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const ListTile(
              title: Text('Name'),
              subtitle: Text('John Doe'),
              trailing: Icon(Icons.edit),
            ),
            const ListTile(
              title: Text('Relationship'),
              subtitle: Text('Spouse'),
              trailing: Icon(Icons.edit),
            ),
            const ListTile(
              title: Text('Phone'),
              subtitle: Text('+1 987-654-3210'),
              trailing: Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }

  // Settings and Preferences Widget
  Widget _buildSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings and Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              title: Text('Language Preferences'),
              subtitle: Text('English'),
              trailing: Icon(Icons.edit),
            ),
            const ListTile(
              title: Text('Privacy Settings'),
              trailing: Icon(Icons.edit),
            ),
          ],
        ),
      ),
    );
  }

  // Logout and Account Management Widget
  Widget _buildLogoutAndAccountManagement() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            // Handle logout
          },
          child: const Text('Logout'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            // Handle delete account
          },
          child: const Text(
            'Delete Account',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}