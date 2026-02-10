import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dri_survey/services/data_export_service.dart';
import 'package:dri_survey/services/database_service.dart';
import 'package:dri_survey/services/excel_service.dart';

// Generate mocks
@GenerateMocks([DatabaseService, ExcelService])
import 'data_export_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late DataExportService dataExportService;
  late MockDatabaseService mockDatabaseService;
  late MockExcelService mockExcelService;

  setUp(() {
    // Since it's singleton, we can't inject mocks easily
    // For testing, we test the static methods that exist
  });

  group('DataExportService', () {
    test('exportAllSurveysToExcel should handle file system access error', () async {
      // Since it's a singleton with file system dependencies, we test error handling
      // In a real scenario, we'd use integration tests for this
      expect(() async => await DataExportService().exportAllSurveysToExcel(), throwsA(isA<Exception>()));
    });

    test('exportCompleteSurveyData should handle file system access error', () async {
      const phoneNumber = '+1234567890';
      expect(() async => await DataExportService().exportCompleteSurveyData(phoneNumber), throwsA(isA<Exception>()));
    });

    test('exportCompleteVillageSurveyData should handle file system access error', () async {
      const sessionId = 'session-1';
      expect(() async => await DataExportService().exportCompleteVillageSurveyData(sessionId), throwsA(isA<Exception>()));
    });

    // Note: generateSurveySummaryReport and exportDataAsJSON require file system access
    // and database calls, which are hard to mock in unit tests.
    // Integration tests would be more appropriate for these.
  });
}