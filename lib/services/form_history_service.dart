import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'database_service.dart';
import 'supabase_service.dart';

class FormHistoryService {
  static final FormHistoryService _instance = FormHistoryService._internal();
  factory FormHistoryService() => _instance;
  FormHistoryService._internal();

  final DatabaseService _dbService = DatabaseService();
  final SupabaseService _supabaseService = SupabaseService.instance;

  // Save form data as a new version in history
  Future<void> saveFormVersion({
    required String sessionId,
    required String formType, // 'village' or 'family'
    required Map<String, dynamic> formData,
    String? editedBy,
    String? editReason,
    bool isAutoSave = false,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();

      // Get current version number
      final currentVersion = await _getNextVersionNumber(sessionId, formType);

      // Prepare history data
      final editor = editedBy ?? _supabaseService.currentUser?.email ?? 'unknown';
      final historyData = {
        'session_id': sessionId,
        'version': currentVersion,
        'created_at': now,
        'edited_by': editor,
        'edit_reason': editReason,
        'is_auto_save': isAutoSave ? 1 : 0,
        'form_data': jsonEncode(formData),
        'changes_summary': _generateChangesSummary(formData),
      };

      if (kIsWeb) {
        // For web, use Supabase
        final tableName = formType == 'village' ? 'village_form_history' : 'family_form_history';
        await _supabaseService.client.from(tableName).insert(historyData);
      } else {
        // For mobile, use SQLite
        final tableName = formType == 'village' ? 'village_form_history' : 'family_form_history';
        await _dbService.saveData(tableName, historyData);
      }

      // Update current version in sessions table
      await _updateCurrentVersion(sessionId, formType, currentVersion);

    } catch (e) {
      rethrow;
    }
  }

  // Get all versions for a form
  Future<List<Map<String, dynamic>>> getFormHistory({
    required String sessionId,
    required String formType,
  }) async {
    try {
      if (kIsWeb) {
        final tableName = formType == 'village' ? 'village_form_history' : 'family_form_history';
        final response = await _supabaseService.client
            .from(tableName)
            .select('*')
            .eq('session_id', sessionId)
            .order('version', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      } else {
        final tableName = formType == 'village' ? 'village_form_history' : 'family_form_history';
        final data = await _dbService.getData(tableName, sessionId);
        // Sort by version descending
        data.sort((a, b) => (b['version'] as int).compareTo(a['version'] as int));
        return data;
      }
    } catch (e) {
      return [];
    }
  }

  // Get specific version of form data
  Future<Map<String, dynamic>?> getFormVersion({
    required String sessionId,
    required String formType,
    required int version,
  }) async {
    try {
      if (kIsWeb) {
        final tableName = formType == 'village' ? 'village_form_history' : 'family_form_history';
        final response = await _supabaseService.client
            .from(tableName)
            .select('*')
            .eq('session_id', sessionId)
            .eq('version', version)
            .limit(1);
        final data = List<Map<String, dynamic>>.from(response);
        if (data.isNotEmpty) {
          final record = data.first;
          return {
            ...record,
            'form_data': jsonDecode(record['form_data']?.toString() ?? '{}'),
          };
        }
      } else {
        final db = await _dbService.database;
        final tableName = formType == 'village' ? 'village_form_history' : 'family_form_history';
        final results = await db.query(
          tableName,
          where: 'session_id = ? AND version = ?',
          whereArgs: [sessionId, version],
          limit: 1,
        );
        if (results.isNotEmpty) {
          final record = results.first;
          return {
            ...record,
            'form_data': jsonDecode(record['form_data']?.toString() ?? '{}'),
          };
        }
      }
      return null;
    } catch (e) {
      print('Error getting form version: $e');
      return null;
    }
  }

  // Get latest version of form data
  Future<Map<String, dynamic>?> getLatestFormVersion({
    required String sessionId,
    required String formType,
  }) async {
    try {
      final history = await getFormHistory(sessionId: sessionId, formType: formType);
      if (history.isNotEmpty) {
        final latest = history.first;
        return {
          ...latest,
          'form_data': jsonDecode(latest['form_data'] ?? '{}'),
        };
      }
      return null;
    } catch (e) {
      print('Error getting latest form version: $e');
      return null;
    }
  }

  // Restore form to a specific version (creates new version)
  Future<void> restoreFormVersion({
    required String sessionId,
    required String formType,
    required int versionToRestore,
    String? restoredBy,
  }) async {
    try {
      final versionData = await getFormVersion(
        sessionId: sessionId,
        formType: formType,
        version: versionToRestore,
      );

      if (versionData != null) {
        final formData = versionData['form_data'] as Map<String, dynamic>;
        await saveFormVersion(
          sessionId: sessionId,
          formType: formType,
          formData: formData,
          editedBy: restoredBy,
          editReason: 'Restored from version $versionToRestore',
        );
      }
    } catch (e) {
      print('Error restoring form version: $e');
      rethrow;
    }
  }

  // Delete a specific version (admin function)
  Future<void> deleteFormVersion({
    required String sessionId,
    required String formType,
    required int version,
  }) async {
    try {
      if (kIsWeb) {
        final tableName = formType == 'village' ? 'village_form_history' : 'family_form_history';
        await _supabaseService.client
            .from(tableName)
            .delete()
            .eq('session_id', sessionId)
            .eq('version', version);
      } else {
        final db = await _dbService.database;
        final tableName = formType == 'village' ? 'village_form_history' : 'family_form_history';
        await db.delete(
          tableName,
          where: 'session_id = ? AND version = ?',
          whereArgs: [sessionId, version],
        );
      }
    } catch (e) {
      print('Error deleting form version: $e');
      rethrow;
    }
  }

  // Get version comparison
  Future<Map<String, dynamic>> compareVersions({
    required String sessionId,
    required String formType,
    required int version1,
    required int version2,
  }) async {
    try {
      final v1 = await getFormVersion(sessionId: sessionId, formType: formType, version: version1);
      final v2 = await getFormVersion(sessionId: sessionId, formType: formType, version: version2);

      if (v1 == null || v2 == null) {
        return {'error': 'One or both versions not found'};
      }

      final data1 = v1['form_data'] as Map<String, dynamic>;
      final data2 = v2['form_data'] as Map<String, dynamic>;

      final differences = _compareFormData(data1, data2);

      return {
        'version1': v1,
        'version2': v2,
        'differences': differences,
      };
    } catch (e) {
      print('Error comparing versions: $e');
      return {'error': e.toString()};
    }
  }

  // Private helper methods
  Future<int> _getNextVersionNumber(String sessionId, String formType) async {
    try {
      final history = await getFormHistory(sessionId: sessionId, formType: formType);
      if (history.isEmpty) {
        return 1;
      }
      final maxVersion = history.map((h) => h['version'] as int).reduce((a, b) => a > b ? a : b);
      return maxVersion + 1;
    } catch (e) {
      print('Error getting next version number: $e');
      return 1;
    }
  }

  Future<void> _updateCurrentVersion(String sessionId, String formType, int version) async {
    try {
      final updateData = {
        'current_version': version,
        'last_edited_at': DateTime.now().toIso8601String(),
      };

      if (kIsWeb) {
        final tableName = formType == 'village' ? 'village_survey_sessions' : 'family_survey_sessions';
        final idField = formType == 'village' ? 'session_id' : 'phone_number';
        await _supabaseService.client
            .from(tableName)
            .update(updateData)
            .eq(idField, sessionId);
      } else {
        final db = await _dbService.database;
        final tableName = formType == 'village' ? 'village_survey_sessions' : 'family_survey_sessions';
        final idField = formType == 'village' ? 'session_id' : 'phone_number';
        await db.update(
          tableName,
          updateData,
          where: '$idField = ?',
          whereArgs: [sessionId],
        );
      }
    } catch (e) {
      print('Error updating current version: $e');
    }
  }

  String _generateChangesSummary(Map<String, dynamic> formData) {
    // Simple summary generation - can be enhanced
    final fields = formData.keys.length;
    return 'Updated $fields fields';
  }

  List<Map<String, dynamic>> _compareFormData(Map<String, dynamic> data1, Map<String, dynamic> data2) {
    final differences = <Map<String, dynamic>>[];

    final allKeys = {...data1.keys, ...data2.keys};

    for (final key in allKeys) {
      final value1 = data1[key];
      final value2 = data2[key];

      if (value1 != value2) {
        differences.add({
          'field': key,
          'old_value': value1,
          'new_value': value2,
        });
      }
    }

    return differences;
  }
}