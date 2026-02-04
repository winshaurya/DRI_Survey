/// Utility class for handling boolean conversions between SQLite INTEGER (0/1)
/// and human-readable strings for display in UI components.
/// 
/// SQLite stores booleans as INTEGER (0 = false, 1 = true), while UI needs
/// formatted strings like "Yes"/"No" or "Available"/"Not Available".
class BoolHelper {
  /// Converts INTEGER (0/1) or String ('0'/'1') to human-readable string.
  /// 
  /// Examples:
  /// ```dart
  /// BoolHelper.format(1); // "Yes"
  /// BoolHelper.format(0); // "No"
  /// BoolHelper.format('1'); // "Yes"
  /// BoolHelper.format(true); // "Yes"
  /// BoolHelper.format(null); // "N/A"
  /// BoolHelper.format(1, trueLabel: 'Available'); // "Available"
  /// ```
  static String format(
    dynamic value, {
    String trueLabel = 'Yes',
    String falseLabel = 'No',
    String nullLabel = 'N/A',
  }) {
    if (value == null) return nullLabel;
    
    // Handle INTEGER
    if (value == 1 || value == '1' || value == true) {
      return trueLabel;
    }
    
    if (value == 0 || value == '0' || value == false) {
      return falseLabel;
    }
    
    // Handle string values (case-insensitive)
    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'yes' || lower == 'true' || lower == 'available') {
        return trueLabel;
      }
      if (lower == 'no' || lower == 'false' || lower == 'unavailable') {
        return falseLabel;
      }
    }
    
    return nullLabel;
  }

  /// Converts user input string to INTEGER for SQLite storage.
  /// 
  /// Examples:
  /// ```dart
  /// BoolHelper.parse('yes'); // 1
  /// BoolHelper.parse('no'); // 0
  /// BoolHelper.parse('YES'); // 1 (case-insensitive)
  /// BoolHelper.parse('1'); // 1
  /// BoolHelper.parse('true'); // 1
  /// BoolHelper.parse(null); // 0 (defaults to false)
  /// ```
  static int parse(String? value) {
    if (value == null || value.isEmpty) return 0;
    
    final lower = value.toLowerCase().trim();
    
    // Truthy values
    if (lower == 'yes' || 
        lower == '1' || 
        lower == 'true' || 
        lower == 'available' ||
        lower == 'fit' ||
        lower == 'regularly') {
      return 1;
    }
    
    // Falsy values (explicit check for clarity)
    if (lower == 'no' || 
        lower == '0' || 
        lower == 'false' || 
        lower == 'unavailable' ||
        lower == 'unfit' ||
        lower == 'never') {
      return 0;
    }
    
    // Default to false for unrecognized values
    return 0;
  }

  /// Converts boolean to INTEGER for SQLite.
  /// 
  /// Examples:
  /// ```dart
  /// BoolHelper.toInt(true); // 1
  /// BoolHelper.toInt(false); // 0
  /// BoolHelper.toInt(null); // 0
  /// ```
  static int toInt(bool? value) {
    return (value == true) ? 1 : 0;
  }

  /// Converts INTEGER to boolean.
  /// 
  /// Examples:
  /// ```dart
  /// BoolHelper.toBool(1); // true
  /// BoolHelper.toBool(0); // false
  /// BoolHelper.toBool('1'); // true
  /// BoolHelper.toBool(null); // false
  /// ```
  static bool toBool(dynamic value) {
    if (value == null) return false;
    
    if (value == 1 || value == '1' || value == true) {
      return true;
    }
    
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'yes' || lower == 'true' || lower == '1';
    }
    
    return false;
  }

  /// Formats a list of boolean values with custom labels.
  /// Useful for displaying multiple yes/no fields in a single widget.
  /// 
  /// Example:
  /// ```dart
  /// final facilities = {
  ///   'Toilet': 1,
  ///   'Drainage': 0,
  ///   'Solar': 1,
  /// };
  /// BoolHelper.formatMap(facilities); 
  /// // Returns: 'Toilet: Yes, Drainage: No, Solar: Yes'
  /// ```
  static String formatMap(
    Map<String, dynamic> values, {
    String separator = ', ',
    String trueLabel = 'Yes',
    String falseLabel = 'No',
  }) {
    return values.entries
        .map((e) => '${e.key}: ${format(e.value, trueLabel: trueLabel, falseLabel: falseLabel)}')
        .join(separator);
  }
}
