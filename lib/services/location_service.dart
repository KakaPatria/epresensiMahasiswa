import 'package:geolocator/geolocator.dart';

class LocationService {
  static const double targetLatitude = -8.344704;
  static const double targetLongitude = 113.567177;
  static const double maxRadius = 100.0;

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (e) {
      return null;
    }
  }

  bool isWithinRadius(double currentLat, double currentLng) {
    double distanceInMeters = Geolocator.distanceBetween(
      targetLatitude,
      targetLongitude,
      currentLat,
      currentLng,
    );
    return distanceInMeters <= maxRadius;
  }

  double calculateDistance(double currentLat, double currentLng) {
    return Geolocator.distanceBetween(
      targetLatitude,
      targetLongitude,
      currentLat,
      currentLng,
    );
  }
}
