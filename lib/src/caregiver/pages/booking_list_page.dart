import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/caregiver_card.dart';

class CaregiverBookingList extends StatelessWidget {
  const CaregiverBookingList({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('You must be logged in to view bookings.'),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pending Bookings
            _buildBookingList(user.uid, 'Pending'),
            // Accepted Bookings
            _buildBookingList(user.uid, 'Accepted'),
            // Cancelled Bookings
            _buildBookingList(user.uid, 'Cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(String caregiverId, String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(caregiverId)
          .collection('pendingBookings')
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No bookings found.'));
        }

        final bookings = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index].data() as Map<String, dynamic>;
            final parentId = booking['parentID'];
            final bookingId = bookings[index].id;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(parentId)
                  .get(),
              builder: (context, parentSnapshot) {
                if (parentSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (parentSnapshot.hasError || !parentSnapshot.hasData) {
                  return const Text('Error loading parent details.');
                }

                final parent = parentSnapshot.data!.data() as Map<String, dynamic>;

                return CaregiverCard(
                  bookingId: bookingId,
                  date: booking['selectedDays'].join(', '),
                  time: '${booking['startTime']} - ${booking['endTime']}',
                  parentName: parent['name'] ?? 'Unknown',
                  children: booking['childQuantity'],
                  location: booking['location'],
                  status: booking['status'],
                  onAccept: () => _updateBookingStatus(bookingId, caregiverId, 'Accepted'),
                  onReject: () => _updateBookingStatus(bookingId, caregiverId, 'Cancelled'),
                  onViewDetails: () {
                    // Navigate to booking details
                  },
                  onMessageParent: () {
                    // Navigate to message parent
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _updateBookingStatus(String bookingId, String caregiverId, String status) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(caregiverId)
        .collection('pendingBookings')
        .doc(bookingId)
        .update({'status': status});

    // Optionally, update the parent's bookings collection
    final bookingSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(caregiverId)
        .collection('pendingBookings')
        .doc(bookingId)
        .get();

    final parentId = bookingSnapshot.data()?['parentID'];
    if (parentId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(parentId)
          .collection('bookings')
          .doc(bookingId)
          .update({'status': status});
    }
  }
}