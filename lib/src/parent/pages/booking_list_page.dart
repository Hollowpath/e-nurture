import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../widgets/parent_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator for getting current location

class ParentBookingListPage extends StatefulWidget {
  const ParentBookingListPage({super.key});

  @override
  BookingListPageState createState() => BookingListPageState();
}

class BookingListPageState extends State<ParentBookingListPage> with SingleTickerProviderStateMixin {
  String _selectedFilter = 'All'; // Filter option for booked caregivers
  String _selectedSort = 'Relevance'; // Sort option for caregivers
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final user = FirebaseAuth.instance.currentUser;
  late TabController _tabController;

  // Store the user's current position
  Position? _currentPosition;

  // Use ValueNotifier for better state management
  final ValueNotifier<List<Map<String, dynamic>>> _searchNotifier = ValueNotifier([]);
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _tabController = TabController(length: 2, vsync: this);

    // Get the user's current location
    _getCurrentLocation();
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

  // Get current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // Check for location permissions
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permission denied');
    } else if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permission permanently denied');
    }

    // Get the current position
    _currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {}); // Update the UI with the new position
  }

  // Calculate distance between the current location and the caregiver
  double _calculateDistance(double lat, double lon) {
    if (_currentPosition == null) return double.infinity;

    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lon,
    );
  }

  // Sort search results by proximity or other selected filter
  void _sortSearchResults(List<Map<String, dynamic>> results) {
    if (_selectedSort == 'Distance' && _currentPosition != null) {
      results.sort((a, b) {
        double distanceA = _calculateDistance(a['latitude'], a['longitude']);
        double distanceB = _calculateDistance(b['latitude'], b['longitude']);
        return distanceA.compareTo(distanceB);
      });
    } else if (_selectedSort == 'Alphabet') {
      results.sort((a, b) => a['name'].compareTo(b['name']));
    } else if (_selectedSort == 'Price') {
      results.sort((a, b) => a['hourlyRate'].compareTo(b['hourlyRate']));
    } else if (_selectedSort == 'Relevance') {
      // You can implement your custom sorting logic for "Relevance"
      results.sort((a, b) => a['name'].compareTo(b['name'])); // Just an example, sorting by name
    }

    // Update the notifier to trigger a rebuild
    _searchNotifier.value = results;
  }

  void _showFilterOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter and Sort Bookings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Filter by:'),
              _buildFilterOption('All'),
              _buildFilterOption('Pending'),
              _buildFilterOption('Accepted'),
              _buildFilterOption('Canceled'),
              const SizedBox(height: 20),
              const Text('Sort by:'),
              _buildSortOption('Alphabet'),
              _buildSortOption('Distance'),
              _buildSortOption('Price'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String filter) {
    return RadioListTile<String>(
      title: Text(filter),
      value: filter,
      groupValue: _selectedFilter,
      onChanged: (value) {
        setState(() {
          _selectedFilter = value!;
          _applyFilters();
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildSortOption(String sort) {
    return RadioListTile<String>(
      title: Text(sort),
      value: sort,
      groupValue: _selectedSort,
      onChanged: (value) {
        setState(() {
          _selectedSort = value!;
          _sortSearchResults(_searchResults);
        });
        Navigator.of(context).pop();
      },
    );
  }

  void _applyFilters() {
    // Implement your filtering logic here based on _selectedFilter
    // For example, filter _searchResults based on the selected filter
    List<Map<String, dynamic>> filteredResults = _searchResults.where((result) {
      if (_selectedFilter == 'All') return true;
      return result['status'] == _selectedFilter;
    }).toList();

    // After filtering, sort the results
    _sortSearchResults(filteredResults);
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Navigate to booking screen or caregiver details.
      //   },
      //   child: const Icon(Icons.add),
      // ),
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

        // Convert Firestore documents to a list of maps
        _searchResults = filteredDocs.map((doc) {
          final data = doc.data();
          return {
            'caregiverID': doc.id, // Include the document ID as caregiverID
            'name': data['name'] ?? 'Unnamed',
            'age': data['age'] ?? 0,
            'rating': data['rating'] != null ? (data['rating'] as num).toDouble() : 0.0,
            'hourlyRate': data['rate'] != null ? (data['rate'] as num).toInt() : 20,
            'certifications': data['certifications'] != null
                ? List<String>.from(data['certifications'])
                : const ['None'],
            'service': data['service'] ?? 'N/A',
            'availability': data['availability'] ?? 'N/A',
            'latitude': data['latitude'] ?? 0.0,
            'longitude': data['longitude'] ?? 0.0,
            'image': data['image'] ?? 'assets/images/caregiver.png',
          };
        }).toList();

        // Sort the results based on selected filter
        _sortSearchResults(_searchResults);

        return ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: _searchNotifier,
          builder: (context, updatedResults, child) {
            return updatedResults.isEmpty
                ? _buildEmptyState('No caregivers found.')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: updatedResults.length,
                    itemBuilder: (context, index) {
                      final caregiver = updatedResults[index];
                      return ParentCard(
                        caregiverId: caregiver['caregiverID'] ?? 'Unnamed',
                        name: caregiver['name'] ?? 'Unnamed',
                        age: caregiver['age'] ?? 0,
                        rating: caregiver['rating'] ?? 0.0,
                        hourlyRate: caregiver['hourlyRate'] ?? 20,
                        certifications: caregiver['certifications'] ?? const ['None'],
                        service: caregiver['service'] ?? 'N/A',
                        availability: caregiver['availability'] ?? 'N/A',
                        distance: '${_calculateDistance(caregiver['latitude'], caregiver['longitude']).toStringAsFixed(2)} meters away',
                        latitude: caregiver['latitude'] ?? 0.0,
                        longitude: caregiver['longitude'] ?? 0.0,
                        image: caregiver['image'] ?? 'assets/images/caregiver.png',
                      );
                    },
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
          final name = (doc.data()['name'] ?? '').toString().toLowerCase();
          return (_selectedFilter == 'All' || status == _selectedFilter) && name.contains(_searchQuery.toLowerCase());
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
                  distance: '${_calculateDistance(caregiver['latitude'], caregiver['longitude']).toStringAsFixed(2)} meters away',
                  latitude: caregiver['latitude'] ?? 0.0,
                  longitude: caregiver['longitude'] ?? 0.0,
                  image: caregiver['image'] ?? 'assets/images/caregiver.png',
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