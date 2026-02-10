import 'package:flutter_test/flutter_test.dart';
import 'package:dri_survey/utils/bool_helper.dart';

void main() {
  group('BoolHelper - Unit Tests for Boolean Formatting and Conversion', () {
    test('format should return Yes for 1 - Testing integer true value', () {
      print('🧪 Testing BoolHelper.format with integer 1');
      final result = BoolHelper.format(1);
      print('📊 Input: 1, Expected: Yes, Actual: $result');
      expect(result, 'Yes');
      print('✅ Test passed: Integer 1 correctly formatted to Yes');
    });

    test('format should return No for 0 - Testing integer false value', () {
      print('🧪 Testing BoolHelper.format with integer 0');
      final result = BoolHelper.format(0);
      print('📊 Input: 0, Expected: No, Actual: $result');
      expect(result, 'No');
      print('✅ Test passed: Integer 0 correctly formatted to No');
    });

    test('format should return N/A for null - Testing null handling', () {
      print('🧪 Testing BoolHelper.format with null value');
      final result = BoolHelper.format(null);
      print('📊 Input: null, Expected: N/A, Actual: $result');
      expect(result, 'N/A');
      print('✅ Test passed: Null value correctly formatted to N/A');
    });

    test('format should handle custom labels - Testing customization', () {
      print('🧪 Testing BoolHelper.format with custom labels');
      final trueResult = BoolHelper.format(1, trueLabel: 'Available', falseLabel: 'Not Available');
      final falseResult = BoolHelper.format(0, trueLabel: 'Available', falseLabel: 'Not Available');
      print('📊 Input: 1 with custom labels, Expected: Available, Actual: $trueResult');
      print('📊 Input: 0 with custom labels, Expected: Not Available, Actual: $falseResult');
      expect(trueResult, 'Available');
      expect(falseResult, 'Not Available');
      print('✅ Test passed: Custom labels work correctly');
    });

    test('format should handle string inputs - Testing string parsing', () {
      print('🧪 Testing BoolHelper.format with string inputs');
      final yesResult = BoolHelper.format('1');
      final noResult = BoolHelper.format('0');
      final yesStringResult = BoolHelper.format('yes');
      final noStringResult = BoolHelper.format('no');
      print('📊 String inputs tested: "1", "0", "yes", "no"');
      expect(yesResult, 'Yes');
      expect(noResult, 'No');
      expect(yesStringResult, 'Yes');
      expect(noStringResult, 'No');
      print('✅ Test passed: String inputs correctly parsed and formatted');
    });

    test('format should handle boolean inputs - Testing direct boolean values', () {
      print('🧪 Testing BoolHelper.format with boolean inputs');
      final trueResult = BoolHelper.format(true);
      final falseResult = BoolHelper.format(false);
      print('📊 Input: true, Expected: Yes, Actual: $trueResult');
      print('📊 Input: false, Expected: No, Actual: $falseResult');
      expect(trueResult, 'Yes');
      expect(falseResult, 'No');
      print('✅ Test passed: Boolean inputs correctly formatted');
    });
  });
}