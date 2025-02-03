import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/parent_card.dart';

class ParentBookingListPage extends StatefulWidget {
  const ParentBookingListPage({super.key});

  @override
  _BookingListPageState createState() => _BookingListPageState();
}

class _BookingListPageState extends State<ParentBookingListPage> {
  String _selectedFilter = 'All'; // Filter option (if needed later)
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Update search query when text changes.
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  // Show filter options dialog (if you wish to add additional filtering later)
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
              _buildFilterOption('Upcoming'),
              _buildFilterOption('Completed'),
              _buildFilterOption('Canceled'),
            ],
          ),
        );
      },
    );
  }

  // Filter option widget.
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

  // Empty state widget in case there are no matching caregivers.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No caregivers found.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Stream of users with role "Childcare Giver"
    final Stream<QuerySnapshot<Map<String, dynamic>>> caregiverStream = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: "Childcare Giver")
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking List'),
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
          // Booking/Caregiver List via StreamBuilder
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
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
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data = filteredDocs[index].data();
                    return ParentCard(
                      // Map the Firestore fields to the ParentCard widget.
                      // Replace these with your actual field names.
                      name: data['name'] ?? 'Unnamed',
                      age: data['age'] ?? 0,
                      rating: data['rating'] != null ? (data['rating'] as num).toDouble() : 0.0,
                      hourlyRate: data['rate'] ?? 20,
                      certifications: data['certifications'] != null
                          ? List<String>.from(data['certifications'])
                          : const ['Failure', 'SkibidiRizz'],
                      service: data['service'] ?? 'N/A',
                      availability: data['availability'] ?? 'N/A',
                      distance: data['distance'] ?? 'N/A',
                      image: data['profileImageUrl'] ?? 'assets/images/caregiver.png',
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Call-to-Action Button for New Bookings (if needed)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to booking screen or caregiver details.
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
