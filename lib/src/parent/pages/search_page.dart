import 'package:flutter/material.dart';
import 'package:e_nurture/src/geolocator/map_screen.dart'; // Import the MapScreen here
import 'package:geolocator/geolocator.dart'; // Import geolocator for getting current location

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedFilter = 'Relevance'; // Default sort option
  List<Map<String, dynamic>> _searchResults = []; // Example search results

  @override
  void initState() {
    super.initState();
    // Automatically focus on the search bar when the page is entered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
    // Example data for search results
    _searchResults = [
      {
        'name': 'Atiqah',
        'age': 32,
        'rating': 5.0,
        'hourlyRate': 25,
        'certifications': ['First Aid'],
        'service': '3 years with newborns',
        'availability': 'Available Tomorrow',
        'distance': '4 miles away',
        'image': 'assets/caregiver2.jpg',
        'latitude': 3.1971901241624305,  // Add latitude
        'longitude':  101.73444153683393,  // Add longitude
      },
      {
        'name': 'Sarah',
        'age': 36,
        'rating': 4.5,
        'hourlyRate': 20,
        'certifications': ['CPR', 'First Aid'],
        'service': '5 years with toddlers',
        'availability': 'Available Today',
        'distance': '2 miles away',
        'image': 'assets/caregiver1.jpg',
        'latitude': 3.227522695048218,  // Add latitude
        'longitude':  101.72566637963965,  // Add longitude
      },
      {
        'name': 'John',
        'age': 28,
        'rating': 5.0,
        'hourlyRate': 25,
        'certifications': ['First Aid'],
        'service': '3 years with newborns',
        'availability': 'Available Tomorrow',
        'distance': '1 mile away',
        'image': 'assets/caregiver2.jpg',
        'latitude': 3.2317263893115546,  // Add latitude
        'longitude': 101.70450631492854,  // Add longitude
      },
    ];
  }

  // Get current location
  Future<Position> _getCurrentLocation() async {
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
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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
                // Perform search as the user types
                setState(() {
                  _searchResults = _searchResults
                      .where((caregiver) => caregiver['name']
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                });
                _sortSearchResults();  // Sort after the search is performed
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
                        _sortSearchResults(); // Sort after changing filter
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
            child: _searchResults.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final caregiver = _searchResults[index];
                      return _buildCaregiverCard(caregiver);
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
                  backgroundImage: AssetImage(caregiver['image']),
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
                        Text('${caregiver['rating']}'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('\$${caregiver['hourlyRate']}/hour'),
            Text('Certifications: ${caregiver['certifications'].join(', ')}'),
            Text('Service: ${caregiver['service']}'),
            Text('Availability: ${caregiver['availability']}'),
            Text('Distance: ${caregiver['distance']}'),
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

  // Sort Search Results based on location
  Future<void> _sortSearchResults() async {
    // Get current location
    Position currentPosition = await _getCurrentLocation();

    // Calculate the distance for each caregiver and store it in a temporary field
    for (var caregiver in _searchResults) {
      double distanceInMeters = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        caregiver['latitude'],
        caregiver['longitude'],
      );
      caregiver['distanceInMeters'] = distanceInMeters;
    }

    // Sort the search results based on distance (ascending order)
    _searchResults.sort((a, b) {
      return a['distanceInMeters'].compareTo(b['distanceInMeters']);
    });

    // Trigger UI update by calling setState after sorting
    setState(() {});
  }
}