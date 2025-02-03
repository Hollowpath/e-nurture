import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/parent_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ParentBookingListPage extends StatefulWidget {
  const ParentBookingListPage({super.key});

  @override
  BookingListPageState createState() => BookingListPageState();
}

class BookingListPageState extends State<ParentBookingListPage> with SingleTickerProviderStateMixin {
  String _selectedFilter = 'All'; // Filter option for booked caregivers
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final user = FirebaseAuth.instance.currentUser;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _showFilterOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Bookings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('All'),
              _buildFilterOption('Pending'),
              _buildFilterOption('Accepted'),
              _buildFilterOption('Canceled'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String filter) {
    return ListTile(
      title: Text(filter),
      trailing: _selectedFilter == filter ? const Icon(Icons.check) : null,
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking List'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Search List'),
            Tab(text: 'Booked List'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search caregivers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Search List Tab
                _buildSearchList(),
                // Booked List Tab
                _buildBookedList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to booking screen or caregiver details.
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchList() {
    final Stream<QuerySnapshot<Map<String, dynamic>>> caregiverStream = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: "Childcare Giver")
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: caregiverStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final docs = snapshot.data?.docs ?? [];

        // Filter caregivers based on the search query
        final filteredDocs = docs.where((doc) {
          final name = (doc.data()['name'] ?? '').toString().toLowerCase();
          return name.contains(_searchQuery.toLowerCase());
        }).toList();

        if (filteredDocs.isEmpty) {
          return _buildEmptyState('No caregivers found.');
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final data = filteredDocs[index].data();
            return ParentCard(
              caregiverId: data['caregiverID'] ?? 'Unnamed',
              name: data['name'] ?? 'Unnamed',
              age: data['age'] ?? 0,
              rating: data['rating'] != null ? (data['rating'] as num).toDouble() : 0.0,
              hourlyRate: data['rate'] != null ? (data['rate'] as num).toInt() : 20,
              certifications: data['certifications'] != null
                  ? List<String>.from(data['certifications'])
                  : const ['None'],
              service: data['service'] ?? 'N/A',
              availability: data['availability'] ?? 'N/A',
              distance: data['distance'] ?? 'N/A',
              image: data['profileImageUrl'] ?? 'assets/images/caregiver.png',
            );
          },
        );
      },
    );
  }

  Widget _buildBookedList() {
    final Stream<QuerySnapshot<Map<String, dynamic>>> bookedCaregiverStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .collection('bookings')
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: bookedCaregiverStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final docs = snapshot.data?.docs ?? [];

        // Filter bookings based on the selected filter
        final filteredDocs = docs.where((doc) {
          final status = doc.data()['status'] ?? '';
          return _selectedFilter == 'All' || status == _selectedFilter;
        }).toList();

        if (filteredDocs.isEmpty) {
          return _buildEmptyState('No bookings found.');
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final booking = filteredDocs[index].data();
            return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(booking['caregiverID'])
                  .get(),
              builder: (context, caregiverSnapshot) {
                if (caregiverSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    title: Text('Loading...'),
                  );
                }
                if (caregiverSnapshot.hasError || !caregiverSnapshot.hasData) {
                  return const ListTile(
                    title: Text('Error loading caregiver details.'),
                  );
                }

                final caregiver = caregiverSnapshot.data!.data()!;
                return ParentCard(
                  caregiverId: caregiver['caregiverID'] ?? 'Unnamed',
                  name: caregiver['name'] ?? 'Unnamed',
                  age: caregiver['age'] ?? 0,
                  rating: caregiver['rating'] != null ? (caregiver['rating'] as num).toDouble() : 0.0,
                  hourlyRate: caregiver['rate'] != null ? (caregiver['rate'] as num).toInt() : 20,
                  certifications: caregiver['certifications'] != null
                      ? List<String>.from(caregiver['certifications'])
                      : const ['None'],
                  service: caregiver['service'] ?? 'N/A',
                  availability: caregiver['availability'] ?? 'N/A',
                  distance: caregiver['distance'] ?? 'N/A',
                  image: caregiver['profileImageUrl'] ?? 'assets/images/caregiver.png',
                  isBooked: true, // Set this to true for Booked List
                );
              },
            );
          },
        );
      },
    );
  }
}