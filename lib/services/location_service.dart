import 'package:location/location.dart';

class LocationService {
  static final Location _location = Location();

  static Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }

    return true;
  }

  static Future<Map<String, dynamic>?> getCurrentPosition() async {
    try {
      if (!await checkLocationPermission()) return null;

      LocationData locationData = await _location.getLocation();
      return {
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'accuracy': locationData.accuracy,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, String>?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    // For now, return basic location info
    // TODO: Implement reverse geocoding when needed
    return {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'coordinates': '$latitude, $longitude',
    };
  }

  static Future<Map<String, dynamic>?> getCompleteLocationData() async {
    try {
      if (!await checkLocationPermission()) return null;

      LocationData locationData = await _location.getLocation();

      return {
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'accuracy': locationData.accuracy ?? 0.0,
        'timestamp': DateTime.now().toIso8601String(),
        'village': '', // Will be filled by reverse geocoding if implemented
        'subLocality': '', // Will be filled by reverse geocoding if implemented
        'subAdministrativeArea': '', // Will be filled by reverse geocoding if implemented
        'administrativeArea': '', // Will be filled by reverse geocoding if implemented
        'postalCode': '', // Will be filled by reverse geocoding if implemented
        'country': 'India', // Default for India
      };
    } catch (e) {
      return null;
    }
  }
}
