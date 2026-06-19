import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  // JTI Polije
  // static const double targetLatitude = -8.1575886;
  // static const double targetLongitude = 113.722782;

  // Manual Coordinates
  static const double targetLatitude = -8.344704;
  static const double targetLongitude = 113.567177;
  
  static const double maxRadius = 50.0;

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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
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

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng',
      );
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'epresensi_app/1.0',
          'Accept-Language': 'id-ID', // Bahasa Indonesia
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['display_name'] != null) {
          return data['display_name'].toString();
        }
      }
      return 'Alamat tidak ditemukan';
    } catch (e) {
      return 'Gagal memuat alamat';
    }
  }
}
