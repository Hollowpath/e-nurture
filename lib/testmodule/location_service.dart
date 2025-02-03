import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled. Please enable them in your device settings.');
    }

    // Check for location permissions
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permission denied. Please grant permission in your device settings.');
    } else if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permission permanently denied. You can enable it in the app settings.');
    }

    // Get the current position if permission granted
    try {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      return Future.error('Failed to get location. Please check your GPS settings.');
    }
  }
}
