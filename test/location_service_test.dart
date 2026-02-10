import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:location/location.dart';
import 'package:dri_survey/services/location_service.dart';

// Generate mocks
@GenerateMocks([Location])
import 'location_service_test.mocks.dart';

void main() {
  late MockLocation mockLocation;

  setUp(() {
    mockLocation = MockLocation();
    // Since LocationService uses static Location, hard to inject
    // For testing, we can test the methods that don't depend on static
  });

  group('LocationService', () {
    test('getAddressFromCoordinates should return coordinates', () async {
      const latitude = 12.34;
      const longitude = 56.78;
      final result = await LocationService.getAddressFromCoordinates(latitude, longitude);
      expect(result, isNotNull);
      expect(result!['latitude'], latitude.toString());
      expect(result['longitude'], longitude.toString());
    });

    // Note: Testing checkLocationPermission, getCurrentPosition, getCompleteLocationData
    // requires mocking the static Location instance, which is not straightforward.
    // In a real scenario, we might refactor to allow dependency injection.
  });
}