import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator for getting current location
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:e_nurture/src/geolocator/map_screen.dart'; // Import the MapScreen

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedFilter = 'Relevance'; // Default sort option
  List<Map<String, dynamic>> _searchResults = []; // This will be populated from Firestore

  // Store the user's current position
  Position? _currentPosition;

  // Use ValueNotifier for better state management
  final ValueNotifier<List<Map<String, dynamic>>> _searchNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    // Automatically focus on the search bar when the page is entered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });

    // Get the user's current location
    _getCurrentLocation();
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

  // Fetch caregivers data from Firestore
  Stream<List<Map<String, dynamic>>> _fetchCaregivers() {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    return _firestore.collection('users')
      .where('role', isEqualTo: 'Childcare Giver') // Filter for Childcare Giver role
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          return {
            'name': doc['name'],
            'age': doc['age'],
            'bio': doc['bio'],
            'latitude': doc['latitude'],
            'longitude': doc['longitude'],
            'phone': doc['phone'],
            'rate': doc['rate'],
            'service': doc['service'] ?? '',
            'address': doc['address'] ?? '',
            'role': doc['role'],
          };
        }).toList();
      });
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
    if (_selectedFilter == 'Distance' && _currentPosition != null) {
      results.sort((a, b) {
        double distanceA = _calculateDistance(a['latitude'], a['longitude']);
        double distanceB = _calculateDistance(b['latitude'], b['longitude']);
        return distanceA.compareTo(distanceB);
      });
    }
    // Reset sorting for other filters
    else if (_selectedFilter == 'Relevance') {
      // You can implement your custom sorting logic for "Relevance"
      results.sort((a, b) => a['name'].compareTo(b['name'])); // Just an example, sorting by name
    }
    // Add sorting for other filters like "Rating", "Price", etc., here

    // Update the notifier to trigger a rebuild
    _searchNotifier.value = results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Caregivers'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search for caregivers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                // Filter search results as the user types
              },
            ),
          ),
          // Filters and Sort Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showFilters,
                    child: const Text('Filters'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    items: const [
                      DropdownMenuItem(
                        value: 'Relevance',
                        child: Text('Relevance'),
                      ),
                      DropdownMenuItem(
                        value: 'Rating',
                        child: Text('Rating'),
                      ),
                      DropdownMenuItem(
                        value: 'Price',
                        child: Text('Price'),
                      ),
                      DropdownMenuItem(
                        value: 'Distance',
                        child: Text('Distance'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Search Results
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _fetchCaregivers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final searchResults = snapshot.data ?? [];

                // Sort the results based on selected filter
                _sortSearchResults(searchResults);

                return ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: _searchNotifier,
                  builder: (context, updatedResults, child) {
                    return updatedResults.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: updatedResults.length,
                            itemBuilder: (context, index) {
                              final caregiver = updatedResults[index];
                              return _buildCaregiverCard(caregiver);
                            },
                          );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Caregiver Card Widget
  Widget _buildCaregiverCard(Map<String, dynamic> caregiver) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(caregiver['image'] ?? 'assets/default_image.jpg'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${caregiver['name']}, ${caregiver['age']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text('${caregiver['rate']}'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Phone: ${caregiver['phone']}'),
            Text('Service: ${caregiver['service']}'),
            Text('Address: ${caregiver['address']}'),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to booking screen
                  },
                  child: const Text('Book Now'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to caregiver profile
                  },
                  child: const Text('View Profile'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to MapScreen with only the selected caregiver's data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(caregivers: [caregiver]),
                      ),
                    );
                  },
                  child: const Text('View on Map'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Empty State Widget
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
            'Try adjusting your filters!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showFilters,
            child: const Text('Adjust Filters'),
          ),
        ],
      ),
    );
  }

  // Show Filters Dialog
  void _showFilters() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filters'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('Location'),
              _buildFilterOption('Availability'),
              _buildFilterOption('Price Range'),
              _buildFilterOption('Certifications'),
              _buildFilterOption('Service'),
              _buildFilterOption('Ratings'),
              _buildFilterOption('Languages'),
              _buildFilterOption('Special Skills'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Apply filters
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  // Filter Option Widget
  Widget _buildFilterOption(String filter) {
    return ListTile(
      title: Text(filter),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () {
        // Navigate to filter-specific screen
      },
    );
  }
}
