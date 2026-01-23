// Temporarily disabled native location services for minimal APK build
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<bool> checkLocationPermission() async {
    // Mock implementation - location services disabled
    print('Location services temporarily disabled for minimal APK build');
    return false;
  }

  static Future<Map<String, dynamic>?> getCurrentPosition() async {
    // Mock implementation - return null to indicate location unavailable
    print('Location services temporarily disabled for minimal APK build');
    return null;
  }

  static Future<Map<String, String>?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    // Mock implementation - return null to indicate geocoding unavailable
    print('Geocoding services temporarily disabled for minimal APK build');
    return null;
  }

  static Future<Map<String, dynamic>?> getCompleteLocationData() async {
    // Mock implementation - return sample data for testing
    print('Location services temporarily disabled for minimal APK build');
    print('Returning mock location data for testing purposes');

    // Return mock data to allow the app to function
    return {
      'latitude': 28.6139,  // Delhi coordinates as example
      'longitude': 77.2090,
      'accuracy': 10.0,
      'timestamp': DateTime.now().toIso8601String(),
      'village': 'Sample Village',
      'district': 'Sample District',
      'state': 'Sample State',
      'pincode': '110001',
      'country': 'India',
    };
  }
}
