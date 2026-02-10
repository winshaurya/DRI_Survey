import 'package:flutter_test/flutter_test.dart';
import 'package:dri_survey/models/survey_models.dart';

void main() {
  group('Survey Model - Unit Tests for Data Model Operations', () {
    test('fromMap should create Survey from map - Testing deserialization', () {
      print('🧪 Testing Survey.fromMap with complete map data');
      final map = {
        'id': 1,
        'survey_date': '2023-01-01',
        'village_name': 'Test Village',
        'created_at': '2023-01-01T00:00:00Z',
        'updated_at': '2023-01-01T00:00:00Z',
        'synced': 1,
      };
      print('📊 Input map: $map');
      final survey = Survey.fromMap(map);
      print('📊 Created Survey: id=${survey.id}, date=${survey.surveyDate}, village=${survey.villageName}, synced=${survey.synced}');
      expect(survey.id, 1);
      expect(survey.surveyDate, '2023-01-01');
      expect(survey.villageName, 'Test Village');
      expect(survey.synced, true);
      print('✅ Test passed: Survey correctly deserialized from map');
    });

    test('toMap should convert Survey to map - Testing serialization', () {
      print('🧪 Testing Survey.toMap with complete survey object');
      final survey = Survey(
        id: 1,
        surveyDate: '2023-01-01',
        villageName: 'Test Village',
        createdAt: '2023-01-01T00:00:00Z',
        updatedAt: '2023-01-01T00:00:00Z',
        synced: true,
      );
      print('📊 Survey object: id=${survey.id}, date=${survey.surveyDate}, village=${survey.villageName}');
      final map = survey.toMap();
      print('📊 Serialized map: $map');
      expect(map['id'], 1);
      expect(map['survey_date'], '2023-01-01');
      expect(map['village_name'], 'Test Village');
      expect(map['synced'], 1);
      print('✅ Test passed: Survey correctly serialized to map');
    });

    test('copyWith should create copy with changes - Testing immutability', () {
      print('🧪 Testing Survey.copyWith for creating modified copies');
      final survey = Survey(
        surveyDate: '2023-01-01',
        createdAt: '2023-01-01T00:00:00Z',
        updatedAt: '2023-01-01T00:00:00Z',
        synced: false,
      );
      print('📊 Original survey: date=${survey.surveyDate}, synced=${survey.synced}');
      final copy = survey.copyWith(villageName: 'New Village', synced: true);
      print('📊 Modified copy: village=${copy.villageName}, synced=${copy.synced}');
      expect(copy.villageName, 'New Village');
      expect(copy.synced, true);
      expect(copy.surveyDate, survey.surveyDate); // Unchanged field
      print('✅ Test passed: copyWith creates correct modified copy');
    });

    test('Survey equality should work correctly - Testing Equatable implementation', () {
      print('🧪 Testing Survey equality using Equatable');
      final survey1 = Survey(
        id: 1,
        surveyDate: '2023-01-01',
        createdAt: '2023-01-01T00:00:00Z',
        updatedAt: '2023-01-01T00:00:00Z',
        synced: true,
      );
      final survey2 = Survey(
        id: 1,
        surveyDate: '2023-01-01',
        createdAt: '2023-01-01T00:00:00Z',
        updatedAt: '2023-01-01T00:00:00Z',
        synced: true,
      );
      final survey3 = Survey(
        id: 2,
        surveyDate: '2023-01-01',
        createdAt: '2023-01-01T00:00:00Z',
        updatedAt: '2023-01-01T00:00:00Z',
        synced: true,
      );
      print('📊 Survey1 and Survey2 have identical properties');
      print('📊 Survey3 has different id');
      expect(survey1, equals(survey2));
      expect(survey1, isNot(equals(survey3)));
      print('✅ Test passed: Equality works correctly based on properties');
    });
  });
}