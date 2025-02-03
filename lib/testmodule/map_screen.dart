import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final List<Map<String, dynamic>> caregivers; // Pass caregivers data to map screen

  MapScreen({required this.caregivers});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  // Get the first caregiver's location for initial camera position
  LatLng _getInitialCameraPosition() {
    if (widget.caregivers.isNotEmpty) {
      return LatLng(widget.caregivers[0]['latitude'], widget.caregivers[0]['longitude']);
    } else {
      return LatLng(37.4219999, -122.0840575); // Default location if no caregivers
    }
  }

  // Set of markers for caregivers
  Set<Marker> _createMarkers() {
    Set<Marker> markers = {};
    for (var caregiver in widget.caregivers) {
      markers.add(
        Marker(
          markerId: MarkerId(caregiver['name']),
          position: LatLng(caregiver['latitude'], caregiver['longitude']),
          infoWindow: InfoWindow(
            title: caregiver['name'],
            snippet: 'Rating: ${caregiver['rating']}',
          ),
          onTap: () {
            // Move camera to the marker when it's tapped
            mapController.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(caregiver['latitude'], caregiver['longitude']),
              ),
            );
          },
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Caregivers' Locations")),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _getInitialCameraPosition(), // Dynamically set initial position
          zoom: 14.0,
        ),
        markers: _createMarkers(), // Set the markers to display caregivers
      ),
    );
  }
}
