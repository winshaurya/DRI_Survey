import 'dart:math';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sync_service.dart';
import 'hardcoded_remote_columns.dart';
import 'hardcoded_primary_keys.dart';

typedef SyncErrorCallback = void Function(String message, {bool persistent});

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  static SupabaseService get instance => _instance;


  SupabaseService._internal() {
    _initializePersistentSession();
  }

  SupabaseClient get client => Supabase.instance.client;

  // Persistent session management
  static const String _jwtKey = 'supabase_jwt';
  static const String _refreshTokenKey = 'supabase_refresh_token';
  static const String _expiresAtKey = 'supabase_expires_at';

  Future<void> _initializePersistentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString(_jwtKey);
      final refreshToken = prefs.getString(_refreshTokenKey);
      final expiresAtStr = prefs.getString(_expiresAtKey);

      if (jwt != null && refreshToken != null && expiresAtStr != null) {
        final expiresAt = DateTime.parse(expiresAtStr);
        if (expiresAt.isAfter(DateTime.now())) {
          // Restore session
          await Supabase.instance.client.auth.setSession(jwt);
          debugPrint('Restored persistent Supabase session');
        } else {
          // Clear expired session
          await _clearStoredSession();
        }
      }
    } catch (e) {
      debugPrint('Failed to restore persistent session: $e');
    }
  }


  Future<void> _clearStoredSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_jwtKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_expiresAtKey);
      debugPrint('Cleared stored Supabase session');
    } catch (e) {
      debugPrint('Failed to clear stored session: $e');
    }
  }

  // Retry configuration
  static const int _maxRetryAttempts = 4;
  static const int _initialBackoffMs = 500;
  static const int _maxBackoffMs = 8000;

  // Error escalation
  final List<Map<String, dynamic>> _persistentSyncErrors = [];
  SyncErrorCallback? onSyncError;

  /// CRITICAL: Error escalation mechanism for sync operations
  /// All sync errors must be escalated through this method to ensure:
  /// - User visibility of sync failures
  /// - Persistent logging for offline recovery
  /// - Structured error handling across all sync operations
  /// 
  /// @param message: Descriptive error message
  /// @param persistent: If true, error is saved to SharedPreferences for recovery
  void _escalateError(String message, {bool persistent = false}) {
    // Escalate error to user via callback, persistent log, or UI
    if (onSyncError != null) {
      onSyncError!(message, persistent: persistent);
    }
    if (persistent) {
      _persistentSyncErrors.add({
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _savePersistentSyncErrors();
    }
  }

  Future<void> _savePersistentSyncErrors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('supabase_persistent_sync_errors', jsonEncode(_persistentSyncErrors));
    } catch (_) {}
  }

  /// Public method for testing error escalation (used in unit tests)
  @visibleForTesting
  void testEscalateError(String message, {bool persistent = false}) {
    _escalateError(message, persistent: persistent);
  }

  // Boolean normalization rules:
  // We always store boolean-like values as integers 0/1 in Supabase to keep a consistent representation.
  // Removed the per-field boolean whitelist for simplicity and to avoid inconsistent storage formats.
  // Remote table columns are cached and used to filter upsert payloads to known columns only.
  final Map<String, Set<String>> _remoteTableColumnsCache = {};
  final Map<String, DateTime> _tableCacheFetchedAt = {};
  final Duration _tableCacheTtl = Duration(minutes: 10);

  Future<void> initialize() async {
    // Supabase is already initialized in main.dart
    // This method is kept for compatibility
    return;
  }

  Future<T> _withRetry<T>(Future<T> Function() action, {String? operation}) async {
    int attempt = 0;
    int delayMs = _initialBackoffMs;
    final rng = Random();

    while (true) {
      try {
        return await action();
      } catch (e) {
        attempt++;
        if (attempt >= _maxRetryAttempts) {
          final errMsg = 'Operation failed after $_maxRetryAttempts attempts: $e';
          _escalateError(errMsg, persistent: true);
          rethrow;
        }
        final jitter = rng.nextInt(250);
        await Future.delayed(Duration(milliseconds: delayMs + jitter));
        delayMs = (delayMs * 2).clamp(_initialBackoffMs, _maxBackoffMs);
        final retryMsg = 'Retry $attempt for ${operation ?? 'operation'} after error: $e';
        _escalateError(retryMsg);
      }
    }
  }

  // detect whether a key refers to a phone number field
  bool _isPhoneKey(String key) {
    final lower = key.toLowerCase();
    return lower.contains('phone');
  }

  // normalize phone number text: strip non-digits and convert to int when possible
  dynamic _normalizePhoneNumber(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    var str = value.toString().trim();
    if (str.isEmpty) return null;
    // remove everything except digits
    final digits = str.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      // couldn't extract digits; return original trimmed string
      return str;
    }
    return int.tryParse(digits) ?? digits;
  }

  // shorthand for callers that just need the normalized phone key
  dynamic _phoneKey(dynamic phone) => _normalizePhoneNumber(phone);

  dynamic _normalizeValue(String key, dynamic value) {
    if (value == null) return null;

    // Always normalize boolean values to integer 0/1 for consistency
    if (value is bool) return value ? 1 : 0;

    if (value is num) return value;

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      final lower = trimmed.toLowerCase();

      // Recognize common boolean-like strings and convert to 0/1
      if (lower == 'true' || lower == 'yes' || lower == '1') return 1;
      if (lower == 'false' || lower == 'no' || lower == '0') return 0;

      if (_shouldParseNumber(key) && _isNumericString(trimmed)) {
        return _parseNumber(trimmed);
      }

      return trimmed;
    }

    return value;
  }

  bool _isNumericString(String value) {
    return double.tryParse(value) != null;
  }

  bool _shouldParseNumber(String key) {
    final lower = key.toLowerCase();
    return lower.contains('count') ||
        lower.contains('number') ||
        lower.contains('total') ||
        lower.contains('age') ||
        lower.contains('area') ||
        lower.contains('income') ||
        lower.contains('lat') ||
        lower.contains('long') ||
        lower.contains('distance') ||
        lower.contains('sr_no') ||
        lower.contains('population') ||
        lower.contains('members') ||
        lower.contains('years') ||
        lower.contains('height') ||
        lower.contains('weight') ||
        lower.contains('percentage') ||
        lower.contains('amount') ||
        lower.contains('quantity') ||
        lower.contains('duration') ||
        lower.contains('rate') ||
        lower.contains('size');
  }

  num _parseNumber(String value) {
    if (value.contains('.')) {
      return double.tryParse(value) ?? 0.0;
    }
    return int.tryParse(value) ?? 0;
  }

  Map<String, dynamic> _normalizeMap(Map<String, dynamic> data) {
    final normalized = <String, dynamic>{};
    for (final entry in data.entries) {
      normalized[entry.key] = _normalizeValue(entry.key, entry.value);
    }
    return normalized;
  }

  Future<Set<String>> _getRemoteTableColumns(String table) async {
    // Do NOT perform any runtime schema discovery. Always consult the
    // hardcoded columns map. If the table is not present in the map, return
    // an empty set and escalate so maintainers can update the hardcoded map.
    try {
      if (kHardcodedRemoteTableColumns.containsKey(table)) {
        final cols = kHardcodedRemoteTableColumns[table]!.toSet();
        _remoteTableColumnsCache[table] = cols;
        _tableCacheFetchedAt[table] = DateTime.now();
        return cols;
      }
      // Table not in hardcoded map — escalate so developers can add it.
      _escalateError('Table "$table" not found in hardcoded remote columns map', persistent: true);
      return <String>{};
    } catch (e) {
      _escalateError('Error retrieving hardcoded columns for $table: $e', persistent: true);
      return <String>{};
    }
  }

  dynamic _filterPayloadToColumns(String table, dynamic data, Set<String> columns) {
    // If we couldn't fetch columns, fall back to original payload
    if (columns.isEmpty) {
      // Attempt to map common local/UI keys to expected remote column names
      // to avoid PostgREST errors when the table is empty and schema cache
      // could not be discovered via a sample row.
      try {
        if (data is Map || data is List) {
          return _mapKnownAliasesToRemote(table, data);
        }
      } catch (_) {
        return data;
      }
      return data;
    }

    if (data is List) {
      final filteredList = <Map<String, dynamic>>[];
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          filteredList.add(Map<String, dynamic>.fromEntries(item.entries.where((e) => columns.contains(e.key))));
        }
      }
      return filteredList;
    }

    if (data is Map<String, dynamic>) {
      return Map<String, dynamic>.fromEntries(data.entries.where((e) => columns.contains(e.key)));
    }

    if (data is Map) {
      final casted = <String, dynamic>{};
      for (final entry in data.entries) {
        final key = entry.key.toString();
        if (columns.contains(key)) casted[key] = entry.value;
      }
      return casted;
    }

    return data;
  }

  // When remote column list cannot be determined, translate common local
  // field aliases to the expected remote column names for known tables.
  dynamic _mapKnownAliasesToRemote(String table, dynamic data) {
    Map<String, String> aliases = {};

    switch (table) {
      case 'crop_productivity':
        aliases = {
          'name': 'crop_name',
          'area': 'area_hectares',
          'productivity': 'productivity_quintal_per_hectare',
          'total_production': 'total_production_quintal',
          'sold': 'quantity_sold_quintal',
          'quantity_consumed': 'quantity_consumed_quintal',
          'srno': 'sr_no',
          'id': 'sr_no',
        };
        break;
      case 'animals':
        aliases = {'type': 'animal_type', 'count': 'number_of_animals', 'srno': 'sr_no', 'id': 'sr_no'};
        break;
      case 'family_members':
        aliases = {'srno': 'sr_no', 'father_name': 'fathers_name', 'mother_name': 'mothers_name'};
        break;
      default:
        aliases = {};
    }

    if (data is Map) {
      final mapped = <String, dynamic>{};
      for (final e in data.entries) {
        final key = e.key.toString();
        final mappedKey = aliases.containsKey(key) ? aliases[key]! : key;
        mapped[mappedKey] = e.value;
      }
      return mapped;
    }

    if (data is List) {
      final list = <Map<String, dynamic>>[];
      for (final item in data) {
        if (item is Map) {
          final mapped = <String, dynamic>{};
          for (final e in item.entries) {
            final key = e.key.toString();
            final mappedKey = aliases.containsKey(key) ? aliases[key]! : key;
            mapped[mappedKey] = e.value;
          }
          list.add(mapped);
        }
      }
      return list;
    }

    return data;
  }

  // Resolve known table name aliases when the local table name differs from
  // the remote table (e.g. legacy names vs merged tables). Update this map
  // when new mappings are discovered from server errors.
  String _resolveTableName(String table) {
    const aliases = <String, String>{
      'government_schemes': 'merged_govt_schemes',
      'government_scheme': 'merged_govt_schemes',
      'vb_g_ram_g_beneficiary': 'vb_gram',
      'swachh_bharat': 'swachh_bharat_mission',
    };
    return aliases[table] ?? table;
  }

  List<Map<String, dynamic>> _normalizeList(List<dynamic> data) {
    final normalized = <Map<String, dynamic>>[];
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        normalized.add(_normalizeMap(item));
      } else if (item is Map) {
        final casted = <String, dynamic>{};
        for (final entry in item.entries) {
          casted[entry.key.toString()] = entry.value;
        }
        normalized.add(_normalizeMap(casted));
      }
    }
    return normalized;
  }

  Future<void> _upsertWithRetry(String table, dynamic data) async {
    if (data == null) return;
    if (data is List && data.isEmpty) return;

    // Allow mapping of local table names to remote names (aliases)
    final resolvedTable = _resolveTableName(table);

    debugPrint('[Supabase Sync] _upsertWithRetry start for $table -> $resolvedTable; payloadType=${data.runtimeType}');

    // Fetch and cache remote table columns for the resolved table
    final columns = await _getRemoteTableColumns(resolvedTable);
    var filtered = _filterPayloadToColumns(resolvedTable, data, columns);

    // Normalize values (booleans -> 0/1, strings -> trimmed, numbers parsed when applicable)
    if (filtered is List) {
      final normalizedList = <Map<String, dynamic>>[];
      for (final item in filtered) {
        if (item is Map<String, dynamic>) {
          normalizedList.add(_normalizeMap(item));
        } else if (item is Map) {
          final casted = <String, dynamic>{};
          for (final entry in item.entries) {
            casted[entry.key.toString()] = entry.value;
          }
          normalizedList.add(_normalizeMap(casted));
        }
      }
      filtered = normalizedList;
    } else if (filtered is Map<String, dynamic>) {
      filtered = _normalizeMap(filtered);
    } else if (filtered is Map) {
      final casted = <String, dynamic>{};
      for (final entry in filtered.entries) {
        casted[entry.key.toString()] = entry.value;
      }
      filtered = _normalizeMap(casted);
    }

    // Remove server-managed fields that should be created by the DB.
    final serverGeneratedKeys = {
      'created_at',
      'updated_at',
      'created_by',
      'updated_by',
      'last_edited_at',
    };
    if (filtered is List) {
      for (final item in filtered) {
        if (item is Map<String, dynamic>) {
          for (final k in serverGeneratedKeys) {
            item.remove(k);
          }
        }
      }
    } else if (filtered is Map<String, dynamic>) {
      for (final k in serverGeneratedKeys) {
        filtered.remove(k);
      }
    }

    // If the table has an sr_no column, ensure every list row has a non-null sr_no
    if (filtered is List && columns.contains('sr_no')) {
      int auto = 1;
      for (final item in filtered) {
        if (item is Map<String, dynamic>) {
          if (item['sr_no'] == null) {
            item['sr_no'] = auto;
          }
          auto++;
        }
      }
    }

    // determine conflict target for upsert to satisfy PK requirements
    String? conflictTarget;
    // Prefer authoritative PK map if available
    final pkCols = kHardcodedRemotePrimaryKeys[resolvedTable];
    if (pkCols != null && pkCols.isNotEmpty) {
      conflictTarget = pkCols.join(',');
    } else {
      // try using cached column list first, fall back to payload keys if empty
      Set<String> detectCols = columns;
      if (detectCols.isEmpty) {
        if (filtered is Map<String, dynamic>) {
          detectCols = filtered.keys.toSet();
        } else if (filtered is List && filtered.isNotEmpty && filtered.first is Map) {
          detectCols = (filtered.first as Map<String, dynamic>).keys.toSet();
        }
      }
      if (detectCols.contains('phone_number')) {
        conflictTarget = detectCols.contains('sr_no') ? 'phone_number,sr_no' : 'phone_number';
      }
    }
    if (conflictTarget == null && resolvedTable == 'family_survey_sessions') {
      debugPrint('Upsert $resolvedTable without conflict target, payload=$filtered');
    }

    // Prepare a safe payload snapshot for logging in case of failure
    String _payloadSnapshot(dynamic p) {
      try {
        return jsonEncode(p);
      } catch (_) {
        return p.toString();
      }
    }

    await _withRetry(() async {
      dynamic res;
      try {
        if (conflictTarget != null) {
          res = await client.from(resolvedTable).upsert(filtered, onConflict: conflictTarget).select();
        } else {
          res = await client.from(resolvedTable).upsert(filtered).select();
        }
      } catch (e) {
        final es = e.toString();
        if (conflictTarget != null && (es.contains('ON CONFLICT') || es.contains('no unique or exclusion constraint') || es.contains('42P10'))) {
          debugPrint('[Supabase Sync] onConflict failed for $resolvedTable with target $conflictTarget; retrying without onConflict: $e');
          // Retry without onConflict
          res = await client.from(resolvedTable).upsert(filtered).select();
        } else {
          // Log payload for diagnostics before rethrowing
          final payloadStr = _payloadSnapshot(filtered);
          final msg = '[Supabase Sync] Upsert exception for $resolvedTable: $e; payload=$payloadStr';
          _escalateError(msg, persistent: true);
          rethrow;
        }
      }

      final dynamic dyn = res;
      debugPrint('[Supabase Sync] Raw upsert response for $resolvedTable: $dyn');
      try {
        debugPrint('[Supabase Sync] Auth session present: ${client.auth.currentSession != null}');
        debugPrint('[Supabase Sync] Access token present: ${client.auth.currentSession?.accessToken != null}');
      } catch (_) {}

      dynamic respError;
      dynamic respData;
      dynamic respStatus;

      if (dyn is Map) {
        respError = dyn['error'] ?? dyn['error_description'];
        respData = dyn['data'] ?? dyn['body'] ?? dyn;
        respStatus = dyn['status'];
      } else {
        respError = null;
        respData = dyn;
        respStatus = null;
      }

      if (respError != null) {
        final payloadStr = _payloadSnapshot(filtered);
        final msg = '[Supabase Sync] upsert error for $resolvedTable: ${respError?.message ?? respError}; payload=$payloadStr';
        _escalateError(msg, persistent: true);
        throw Exception(msg);
      }

      if (respData == null || (respData is List && respData.isEmpty) || (respData is Map && respData.isEmpty)) {
        // Treat empty responses as failure so the caller can retry and keep the
        // table in 'failed' status. We rely on Supabase returning the
        // representation when `.select()` is used; an empty body likely means
        // the row did not persist (or RLS blocked it).
        final payloadStr = _payloadSnapshot(filtered);
        final msg = '[Supabase Sync] upsert returned empty data for $resolvedTable; status=$respStatus; data=$respData; payload=$payloadStr';
        _escalateError(msg, persistent: true);
        throw Exception(msg);
      }

      debugPrint('[Supabase Sync] upsert success for $resolvedTable; data=$respData; status=$respStatus');
      return res;
    }, operation: 'upsert $resolvedTable');
  }

  /// Public wrapper so other services (e.g., SyncService) can reuse the
  /// normalized, column-filtered upsert logic with retries.
  Future<void> upsertNormalized(String table, dynamic data) async {
    await _upsertWithRetry(table, data);
  }

  Future<Map<String, String>> validateSchema(List<String> tableNames) async {
    final errors = <String, String>{};

    // Validation now runs against the hardcoded map only. No network calls
    // are performed — missing tables are reported as errors so the map can
    // be updated.
    for (final table in tableNames) {
      if (!kHardcodedRemoteTableColumns.containsKey(table)) {
        final msg = 'Table "$table" not present in hardcoded remote columns map';
        errors[table] = msg;
        _escalateError('Schema validation: $msg', persistent: true);
      }
    }

    return errors;
  }

  // Authentication methods
  Future<void> signInWithPhone(String phoneNumber) async {
    await client.auth.signInWithOtp(
      phone: phoneNumber,
    );
  }

  Future<AuthResponse> verifyOTP(String phoneNumber, String otp) async {
    return await client.auth.verifyOTP(
      phone: phoneNumber,
      token: otp,
      type: OtpType.sms,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser {
    try {
      return Supabase.instance.client.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  // Check if user is online
  Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Sync family survey data to Supabase (legacy method - kept for compatibility)
  Future<bool> syncFamilySurveyToSupabase(String phoneNumber, Map<String, dynamic> surveyData) async {
    final trackingMap = <String, bool>{};
    return await syncFamilySurveyToSupabaseWithTracking(phoneNumber, surveyData, trackingMap);
  }

  /// Helper to upsert a minimal session row directly to Supabase.
  ///
  /// This is used on page‑0 "Next" click to ensure a remote session always
  /// exists as soon as the user provides a phone number.  The calling code can
  /// supply any additional fields that should be present in the session row.
  ///
  /// The phone number is normalised to an integer when possible to match the
  /// remote schema's primary key.  Errors are simply printed and escalated via
  /// [_escalateError] so they don't crash the UI.
  /// Ensure a session record exists in the remote family_survey_sessions table.
  ///
  /// Returns `true` if the row was actually sent immediately, `false` if the
  /// operation was queued or failed.
  Future<bool> ensureFamilySessionExists(String phoneNumber, {Map<String, dynamic>? extra}) async {
    final key = _phoneKey(phoneNumber) ?? phoneNumber;

    // Attempt immediate upsert regardless of connectivity/auth state. If it
    // fails (network, RLS, auth), fall back to queuing a high-priority retry.
    final payload = <String, dynamic>{
      'phone_number': key,
      'status': 'in_progress',
      'surveyor_email': currentUser?.email ?? 'anonymous',
      if (extra != null) ...extra,
    };

    try {
      await client.from('family_survey_sessions').upsert(_normalizeMap(payload));
      debugPrint('[SupabaseService] ensured remote session for $key (immediate attempt)');
      return true;
    } catch (e) {
      _escalateError('Immediate ensureFamilySession failed: $e', persistent: true);
      debugPrint('[SupabaseService] immediate upsert failed for $key: $e — queuing high-priority retry');
      try {
        await SyncService.instance.queueSyncOperation(
          'ensure_family_session',
          {
            'phone_number': key,
            'extra': extra ?? {},
          },
          highPriority: true,
        );
      } catch (q) {
        _escalateError('Failed to queue ensure_family_session: $q', persistent: true);
      }
      return false;
    }
  }

  // Sync family survey data to Supabase with error tracking
  /// CRITICAL: Parallel sync execution to prevent partial failures
  /// All table syncs run concurrently to avoid cascading failures where
  /// one table failure blocks others. Errors are collected and escalated
  /// without stopping other sync operations.
  /// 
  /// @param phoneNumber: Survey session identifier
  /// @param surveyData: Complete survey data payload
  /// @param tableSyncStatus: Tracks success/failure per table
  /// @return: Overall success status (true if all tables synced successfully)
  Future<bool> syncFamilySurveyToSupabaseWithTracking(
    String phoneNumber, 
    Map<String, dynamic> surveyData,
    Map<String, bool> tableSyncStatus,
  ) async {
    bool overallSuccess = true;

    try {
      // Get current user email for audit trail
      final userEmail = currentUser?.email ?? surveyData['surveyor_email'];
      debugPrint('[Supabase Sync] Authenticated user email: \\${currentUser?.email}');
      debugPrint('[Supabase Sync] surveyData["surveyor_email"]: \\${surveyData['surveyor_email']}');

      // the village‑style generic sync handles session + children together
      try {
        await syncFamilySurveyGeneric(phoneNumber, surveyData);
        // if generic succeeds mark all known tables as synced
        const allTables = [
          'family_survey_sessions',
          'family_members','land_holding','irrigation_facilities','crop_productivity',
          'fertilizer_usage','animals','agricultural_equipment','entertainment_facilities',
          'transport_facilities','drinking_water_sources','medical_treatment','disputes',
          'house_conditions','house_facilities','diseases','children_data',
          'malnourished_children_data','child_diseases','folklore_medicine',
          'health_programmes','malnutrition_data','migration_data','training_data',
          'shg_members','fpo_members','bank_accounts','social_consciousness',
          'tribal_questions','tulsi_plants','nutritional_garden',
        ];
        for (var t in allTables) {
          tableSyncStatus[t] = true;
        }
      } catch (e) {
        overallSuccess = false;
        final errMsg = 'Failed to sync family survey generically: $e';
        _escalateError(errMsg, persistent: true);
        // propagate so callers (SyncService) know to retry/queue
        rethrow;
      }

      // if we reach here but overallSuccess is false (shouldn't happen because
      // we rethrow), throw a generic error
      if (!overallSuccess) {
        throw Exception('Family survey sync encountered errors');
      }
      return overallSuccess;

    } catch (e) {
      final errMsg = 'CRITICAL: Failed to sync family survey to Supabase: $e';
      _escalateError(errMsg, persistent: true);
      return false;
    }
  }


  Future<void> syncVillagePageToSupabase(String sessionId, int page, Map<String, dynamic> data) async {
    if (sessionId.isEmpty) return;

    switch (page) {
      case 0:
        await saveVillageData('village_survey_sessions', data);
        break;
      case 1:
        await saveVillageData('village_infrastructure', data);
        break;
      case 2:
        await saveVillageData('village_infrastructure_details', data);
        break;
      case 3:
        await saveVillageData('village_educational_facilities', data);
        break;
      case 4:
        await saveVillageData('village_drainage_waste', data);
        break;
      case 5:
        await saveVillageData('village_irrigation_facilities', data);
        break;
      case 6:
        await saveVillageData('village_seed_clubs', data);
        break;
      case 7:
        await saveVillageData('village_signboards', data);
        break;
      case 8:
        final entries = data['map_entries'];
        if (entries is List) {
          for (final entry in entries) {
            if (entry is Map<String, dynamic>) {
              await saveVillageData('village_social_maps', entry);
            } else if (entry is Map) {
              await saveVillageData('village_social_maps', entry.map((k, v) => MapEntry(k.toString(), v)));
            }
          }
        } else {
          await saveVillageData('village_social_maps', data);
        }
        break;
      case 9:
        await saveVillageData('village_survey_details', data);
        break;
      case 10:
        final points = data['map_points'];
        if (points is List) {
          for (final point in points) {
            if (point is Map<String, dynamic>) {
              await saveVillageData('village_map_points', point);
            } else if (point is Map) {
              await saveVillageData('village_map_points', point.map((k, v) => MapEntry(k.toString(), v)));
            }
          }
        } else {
          await saveVillageData('village_map_points', data);
        }
        break;
      case 11:
        await saveVillageData('village_forest_maps', data);
        break;
      case 12:
        await saveVillageData('village_biodiversity_register', data);
        break;
      case 13:
        await saveVillageData('village_cadastral_maps', data);
        break;
      case 14:
        await saveVillageData('village_transport_facilities', data);
        break;
      default:
        break;
    }
  }

// Helper methods for syncing family survey tables
  Future<void> _syncFamilyMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('family_members', rows);
  }

  Future<void> _syncLandHolding(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final allowedKeys = <String>{
      'id',
      'created_at',
      'irrigated_area',
      'cultivable_area',
      'unirrigated_area',
      'barren_land',
      'mango_trees',
      'guava_trees',
      'lemon_trees',
      'banana_plants',
      'papaya_trees',
      'pomegranate_trees',
      'other_fruit_trees_name',
      'other_fruit_trees_count',
      'other_orchard_plants',
    };
    final filtered = <String, dynamic>{
      for (final entry in data.entries)
        if (allowedKeys.contains(entry.key)) entry.key: entry.value,
    };
    await _upsertWithRetry('land_holding', _normalizeMap({...filtered, 'phone_number': phoneNumber}));
  }

  Future<void> _syncIrrigationFacilities(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('irrigation_facilities', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncCropProductivity(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('crop_productivity', rows);
  }

  Future<void> _syncFertilizerUsage(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('fertilizer_usage', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncAnimals(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('animals', rows);
  }

  Future<void> _syncAgriculturalEquipment(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('agricultural_equipment', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncEntertainmentFacilities(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('entertainment_facilities', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }


  // Parallel sync for government schemes with error tracking
  Future<void> _syncGovernmentSchemesParallel(
    String phoneNumber, 
    Map<String, dynamic> surveyData,
    Map<String, bool> tableSyncStatus,
  ) async {
    final syncTasks = <Future<void>>[];

    // Helper to wrap sync with tracking
    Future<void> syncWithTracking(String tableName, Future<void> Function() syncFn) async {
      try {
        await syncFn();
        tableSyncStatus[tableName] = true;
      } catch (e) {
        tableSyncStatus[tableName] = false;
        final errMsg = 'Failed to sync $tableName: $e';
        _escalateError(errMsg, persistent: true);
      }
    }

    // Sync all government scheme tables in parallel
    syncTasks.add(syncWithTracking('aadhaar_info', () => _syncAadhaarInfo(phoneNumber, surveyData['aadhaar_info'])));
    syncTasks.add(syncWithTracking('aadhaar_scheme_members', () => _syncAadhaarSchemeMembers(phoneNumber, surveyData['aadhaar_scheme_members'])));
    syncTasks.add(syncWithTracking('ayushman_card', () => _syncAyushmanCard(phoneNumber, surveyData['ayushman_card'])));
    syncTasks.add(syncWithTracking('ayushman_scheme_members', () => _syncAyushmanSchemeMembers(phoneNumber, surveyData['ayushman_scheme_members'])));
    syncTasks.add(syncWithTracking('family_id', () => _syncFamilyId(phoneNumber, surveyData['family_id'])));
    syncTasks.add(syncWithTracking('family_id_scheme_members', () => _syncFamilyIdSchemeMembers(phoneNumber, surveyData['family_id_scheme_members'])));
    syncTasks.add(syncWithTracking('ration_card', () => _syncRationCard(phoneNumber, surveyData['ration_card'])));
    syncTasks.add(syncWithTracking('ration_scheme_members', () => _syncRationSchemeMembers(phoneNumber, surveyData['ration_scheme_members'])));
    syncTasks.add(syncWithTracking('samagra_id', () => _syncSamagraId(phoneNumber, surveyData['samagra_id'])));
    syncTasks.add(syncWithTracking('samagra_scheme_members', () => _syncSamagraSchemeMembers(phoneNumber, surveyData['samagra_scheme_members'])));
    syncTasks.add(syncWithTracking('tribal_card', () => _syncTribalCard(phoneNumber, surveyData['tribal_card'])));
    syncTasks.add(syncWithTracking('tribal_scheme_members', () => _syncTribalSchemeMembers(phoneNumber, surveyData['tribal_scheme_members'])));
    syncTasks.add(syncWithTracking('handicapped_allowance', () => _syncHandicappedAllowance(phoneNumber, surveyData['handicapped_allowance'])));
    syncTasks.add(syncWithTracking('handicapped_scheme_members', () => _syncHandicappedSchemeMembers(phoneNumber, surveyData['handicapped_scheme_members'])));
    syncTasks.add(syncWithTracking('pension_allowance', () => _syncPensionAllowance(phoneNumber, surveyData['pension_allowance'])));
    syncTasks.add(syncWithTracking('pension_scheme_members', () => _syncPensionSchemeMembers(phoneNumber, surveyData['pension_scheme_members'])));
    syncTasks.add(syncWithTracking('widow_allowance', () => _syncWidowAllowance(phoneNumber, surveyData['widow_allowance'])));
    syncTasks.add(syncWithTracking('widow_scheme_members', () => _syncWidowSchemeMembers(phoneNumber, surveyData['widow_scheme_members'])));
    syncTasks.add(syncWithTracking('vb_gram', () => _syncVbGram(phoneNumber, surveyData['vb_gram'])));
    syncTasks.add(syncWithTracking('vb_gram_members', () => _syncVbGramMembers(phoneNumber, surveyData['vb_gram_members'])));
    syncTasks.add(syncWithTracking('pm_kisan_nidhi', () => _syncPmKisanNidhi(phoneNumber, surveyData['pm_kisan_nidhi'])));
    syncTasks.add(syncWithTracking('pm_kisan_members', () => _syncPmKisanMembers(phoneNumber, surveyData['pm_kisan_members'])));
    syncTasks.add(syncWithTracking('pm_kisan_samman_nidhi', () => _syncPmKisanSammanNidhi(phoneNumber, surveyData['pm_kisan_samman_nidhi'])));
    syncTasks.add(syncWithTracking('pm_kisan_samman_members', () => _syncPmKisanSammanMembers(phoneNumber, surveyData['pm_kisan_samman_members'])));
    syncTasks.add(syncWithTracking('kisan_credit_card', () => _syncKisanCreditCard(phoneNumber, surveyData['kisan_credit_card'])));
    syncTasks.add(syncWithTracking('kisan_credit_card_members', () => _syncKisanCreditCardMembers(phoneNumber, surveyData['kisan_credit_card_members'] ?? surveyData['kisan_credit_card']?['members'])));
    syncTasks.add(syncWithTracking('swachh_bharat_mission', () => _syncSwachhBharatMission(phoneNumber, surveyData['swachh_bharat_mission'] ?? surveyData['swachh_bharat'])));
    syncTasks.add(syncWithTracking('swachh_bharat_mission_members', () => _syncSwachhBharatMissionMembers(phoneNumber, surveyData['swachh_bharat_mission_members'] ?? surveyData['swachh_bharat_mission']?['members'] ?? surveyData['swachh_bharat']?['members'])));
    syncTasks.add(syncWithTracking('fasal_bima', () => _syncFasalBima(phoneNumber, surveyData['fasal_bima'])));
    syncTasks.add(syncWithTracking('fasal_bima_members', () => _syncFasalBimaMembers(phoneNumber, surveyData['fasal_bima_members'] ?? surveyData['fasal_bima']?['members'])));
    syncTasks.add(syncWithTracking('merged_govt_schemes', () => _syncMergedGovtSchemes(phoneNumber, surveyData['merged_govt_schemes'])));

    // Execute all in parallel
    await Future.wait(syncTasks, eagerError: false);
  }

  Future<void> _syncChildrenData(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('children_data', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncMalnourishedChildrenData(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('malnourished_children_data', rows);
  }

  Future<void> _syncChildDiseases(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('child_diseases', rows);
  }

  Future<void> _syncMalnutritionData(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('malnutrition_data', rows);
  }

  Future<void> _syncMigration(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('migration_data', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncTraining(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('training_data', rows);
  }

  /// Sync training_needs (per-family-member training requests)
  Future<void> _syncTrainingNeeds(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    // Build rows ensuring phone_number + sr_no composite key
    final rows = <Map<String, dynamic>>[];
    for (final item in data) {
      if (item is Map) {
        final row = <String, dynamic>{
          'phone_number': phoneNumber,
          'sr_no': item['sr_no'],
          // prefer explicit boolean/int fields; normalize later
          'wants_training': item['wants_training'] ?? item['wants_training_flag'] ?? item['wants_training_text'],
          // single free-text preferred training field per requested schema
          'preferred_training': item['preferred_training'] ?? item['preferred_training_type'] ?? item['preferred_type'] ?? item['preferred_training_text'],
          'created_at': item['created_at'] ?? DateTime.now().toIso8601String(),
        };
        rows.add(_normalizeMap(row));
      }
    }
    if (rows.isEmpty) return;
    await _upsertWithRetry('training_needs', rows);
  }

  Future<void> _syncSelfHelpGroups(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('shg_members', rows);
  }

  Future<void> _syncFpoMembership(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('fpo_members', rows);
  }

  Future<void> _syncBankAccounts(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('bank_accounts', rows);
  }

  Future<void> _syncSocialConsciousness(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('social_consciousness', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncTribalQuestions(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('tribal_questions', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncFolkloreMedicine(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('folklore_medicine', rows);
  }

  Future<void> _syncHealthProgrammes(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('health_programmes', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }


  // Government scheme helper methods
  Future<void> _syncAadhaarInfo(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('aadhaar_info', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncAadhaarSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('aadhaar_scheme_members', rows);
  }

  Future<void> _syncAyushmanCard(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('ayushman_card', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncAyushmanSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('ayushman_scheme_members', rows);
  }

  Future<void> _syncFamilyId(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('family_id', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncFamilyIdSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('family_id_scheme_members', rows);
  }

  Future<void> _syncRationCard(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('ration_card', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncRationSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('ration_scheme_members', rows);
  }

  Future<void> _syncSamagraId(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('samagra_id', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncSamagraSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('samagra_scheme_members', rows);
  }

  Future<void> _syncTribalCard(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('tribal_card', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncTribalSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('tribal_scheme_members', rows);
  }

  Future<void> _syncHandicappedAllowance(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('handicapped_allowance', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncHandicappedSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('handicapped_scheme_members', rows);
  }

  Future<void> _syncPensionAllowance(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('pension_allowance', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncPensionSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('pension_scheme_members', rows);
  }

  Future<void> _syncWidowAllowance(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('widow_allowance', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncWidowSchemeMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) => {...item, 'phone_number': phoneNumber}).toList(),
    );
    await _upsertWithRetry('widow_scheme_members', rows);
  }

  Future<void> _syncVbGram(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('vb_gram', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncVbGramMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) {
        final memberName = item['member_name'] ?? item['name'] ?? item['family_member_name'];
        return {
          'phone_number': phoneNumber,
          'sr_no': item['sr_no'],
          'member_name': memberName,
          'name_included': item['name_included'],
          'details_correct': item['details_correct'],
          'incorrect_details': item['incorrect_details'],
          'received': item['received'],
          'days': item['days'],
          'membership_details': item['membership_details'],
        };
      }).toList(),
    );
    await _upsertWithRetry('vb_gram_members', rows);
  }

  Future<void> _syncPmKisanNidhi(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('pm_kisan_nidhi', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncPmKisanMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) {
        final memberName = item['member_name'] ?? item['name'] ?? item['family_member_name'];
        return {
          'phone_number': phoneNumber,
          'sr_no': item['sr_no'],
          'member_name': memberName,
          'account_number': item['account_number'],
          'benefits_received': item['benefits_received'] ?? item['received'],
          'name_included': item['name_included'],
          'details_correct': item['details_correct'],
          'incorrect_details': item['incorrect_details'],
          'received': item['received'],
          'days': item['days'],
        };
      }).toList(),
    );
    await _upsertWithRetry('pm_kisan_members', rows);
  }

  Future<void> _syncPmKisanSammanNidhi(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    await _upsertWithRetry('pm_kisan_samman_nidhi', _normalizeMap({...data, 'phone_number': phoneNumber}));
  }

  Future<void> _syncPmKisanSammanMembers(String phoneNumber, List<dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final rows = _normalizeList(
      data.map((item) {
        final memberName = item['member_name'] ?? item['name'] ?? item['family_member_name'];
        return {
          'phone_number': phoneNumber,
          'sr_no': item['sr_no'],
          'member_name': memberName,
          'account_number': item['account_number'],
          'benefits_received': item['benefits_received'] ?? item['received'],
          'name_included': item['name_included'],
          'details_correct': item['details_correct'],
          'incorrect_details': item['incorrect_details'],
          'received': item['received'],
          'days': item['days'],
        };
      }).toList(),
    );
    await _upsertWithRetry('pm_kisan_samman_members', rows);
  }

  Future<void> _syncMergedGovtSchemes(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final schemeData = data['scheme_data'] ?? (data is Map<String, dynamic> ? data : null);
    await _upsertWithRetry(
      'merged_govt_schemes',
      _normalizeMap({
        'phone_number': phoneNumber,
        'scheme_data': schemeData,
      }),
    );
  }

  Future<void> _syncKisanCreditCard(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final payload = <String, dynamic>{
      'phone_number': phoneNumber,
      'has_card': data['has_card'] ?? data['is_beneficiary'],
      'card_number': data['card_number'],
      'credit_limit': data['credit_limit'],
      'outstanding_amount': data['outstanding_amount'],
    };
    await _upsertWithRetry('kisan_credit_card', _normalizeMap(payload));
  }

  Future<void> _syncKisanCreditCardMembers(String phoneNumber, dynamic data) async {
    final rowsInput = data is List ? data : const [];
    if (rowsInput.isEmpty) return;
    final rows = _normalizeList(
      rowsInput.map((item) {
        final memberName = item['member_name'] ?? item['name'] ?? item['family_member_name'];
        return {
          'phone_number': phoneNumber,
          'sr_no': item['sr_no'],
          'member_name': memberName,
          'name_included': item['name_included'],
          'details_correct': item['details_correct'],
          'incorrect_details': item['incorrect_details'],
          'received': item['received'],
          'days': item['days'],
        };
      }).toList(),
    );
    await _upsertWithRetry('kisan_credit_card_members', rows);
  }

  Future<void> _syncSwachhBharatMission(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final payload = <String, dynamic>{
      'phone_number': phoneNumber,
      'has_toilet': data['has_toilet'] ?? data['is_beneficiary'],
      'toilet_type': data['toilet_type'],
      'construction_year': data['construction_year'],
      'subsidy_received': data['subsidy_received'],
    };
    await _upsertWithRetry('swachh_bharat_mission', _normalizeMap(payload));
  }

  Future<void> _syncSwachhBharatMissionMembers(String phoneNumber, dynamic data) async {
    final rowsInput = data is List ? data : const [];
    if (rowsInput.isEmpty) return;
    final rows = _normalizeList(
      rowsInput.map((item) {
        final memberName = item['member_name'] ?? item['name'] ?? item['family_member_name'];
        return {
          'phone_number': phoneNumber,
          'sr_no': item['sr_no'],
          'member_name': memberName,
          'name_included': item['name_included'],
          'details_correct': item['details_correct'],
          'incorrect_details': item['incorrect_details'],
          'received': item['received'],
          'days': item['days'],
        };
      }).toList(),
    );
    await _upsertWithRetry('swachh_bharat_mission_members', rows);
  }

  Future<void> _syncFasalBima(String phoneNumber, Map<String, dynamic>? data) async {
    if (data == null || data.isEmpty) return;
    final payload = <String, dynamic>{
      'phone_number': phoneNumber,
      'has_insurance': data['has_insurance'] ?? data['is_beneficiary'],
      'insurance_type': data['insurance_type'],
      'crop_insured': data['crop_insured'],
      'premium_amount': data['premium_amount'],
      'claim_received': data['claim_received'],
    };
    await _upsertWithRetry('fasal_bima', _normalizeMap(payload));
  }

  Future<void> _syncFasalBimaMembers(String phoneNumber, dynamic data) async {
    final rowsInput = data is List ? data : const [];
    if (rowsInput.isEmpty) return;
    final rows = _normalizeList(
      rowsInput.map((item) {
        final memberName = item['member_name'] ?? item['name'] ?? item['family_member_name'];
        return {
          'phone_number': phoneNumber,
          'sr_no': item['sr_no'],
          'member_name': memberName,
          'name_included': item['name_included'],
          'details_correct': item['details_correct'],
          'incorrect_details': item['incorrect_details'],
          'received': item['received'],
          'days': item['days'],
        };
      }).toList(),
    );
    await _upsertWithRetry('fasal_bima_members', rows);
  }

  // Extract and sync tulsi_plants from house_facilities
  Future<void> _syncTulsiPlants(String phoneNumber, dynamic data) async {
    if (data == null) return;

    Map<String, dynamic>? tulsiRow;
    if (data is List && data.isNotEmpty) {
      tulsiRow = Map<String, dynamic>.from(data.first as Map);
    } else if (data is Map<String, dynamic>) {
      tulsiRow = data;
    } else if (data is Map) {
      tulsiRow = Map<String, dynamic>.from(data);
    }

    if (tulsiRow == null || tulsiRow.isEmpty) return;

    final tulsiData = {
      'phone_number': phoneNumber,
      'has_plants': tulsiRow['has_plants'] ?? tulsiRow['tulsi_plants_available'] ?? tulsiRow['tulsi_plants'] ?? 'no',
      'plant_count': tulsiRow['plant_count'] ?? tulsiRow['tulsi_plant_count'] ?? tulsiRow['tulsi_plants_count'] ?? 0,
    };

    await _upsertWithRetry('tulsi_plants', _normalizeMap(tulsiData));
  }

  // Extract and sync nutritional_garden from house_facilities
  Future<void> _syncNutritionalGarden(String phoneNumber, dynamic data) async {
    if (data == null) return;

    Map<String, dynamic>? gardenRow;
    if (data is List && data.isNotEmpty) {
      gardenRow = Map<String, dynamic>.from(data.first as Map);
    } else if (data is Map<String, dynamic>) {
      gardenRow = data;
    } else if (data is Map) {
      gardenRow = Map<String, dynamic>.from(data);
    }

    if (gardenRow == null || gardenRow.isEmpty) return;

    final gardenData = {
      'phone_number': phoneNumber,
      'has_garden': gardenRow['has_garden'] ?? gardenRow['nutritional_garden_available'] ?? gardenRow['nutritional_garden'] ?? 'no',
      'garden_size': gardenRow['garden_size'] ?? gardenRow['nutritional_garden_size'] ?? 0.0,
      'vegetables_grown': gardenRow['vegetables_grown'] ?? gardenRow['nutritional_garden_vegetables'] ?? '',
    };

    await _upsertWithRetry('nutritional_garden', _normalizeMap(gardenData));
  }

  // Village survey helper methods
  // Get survey statistics for dashboard
  Future<Map<String, dynamic>> getSurveyStatistics() async {
    try {
      // Use a stable column to count surveys. `phone_number` is the primary
      // key for family_survey_sessions in the Supabase schema; fall back to
      // `id` if not present.
      final cols = await _getRemoteTableColumns('family_survey_sessions');
      final countSelect = cols.contains('phone_number') ? 'phone_number' : (cols.contains('id') ? 'id' : '*');

      final surveyCount = await _withRetry(
        () => client.from('family_survey_sessions').select(countSelect),
        operation: 'stats total surveys',
      ).then((data) => data.length);

      final todaySurveys = await _withRetry(
        () => client
            .from('family_survey_sessions')
            .select(countSelect)
            .gte('created_at', DateTime.now().toIso8601String().split('T')[0]),
        operation: 'stats today surveys',
      ).then((data) => data.length);

      return {
        'total_surveys': surveyCount,
        'today_surveys': todaySurveys,
      };
    } catch (e) {
      return {'total_surveys': 0, 'today_surveys': 0};
    }
  }

  // Get surveys for current user
  Future<List<Map<String, dynamic>>> getUserSurveys() async {
    if (currentUser == null) return [];

    try {
      return await client
          .from('surveys')
          .select('*')
          .eq('user_id', currentUser!.id)
          .order('created_at', ascending: false);
    } catch (e) {
      return [];
    }
  }

  // Save village data to Supabase (generic method used by screens)
  Future<void> saveVillageData(String tableName, Map<String, dynamic> data) async {
    try {
      final payload = Map<String, dynamic>.from(data);

      // Add surveyor_email from authenticated user if not already present
      if (!payload.containsKey('surveyor_email')) {
        payload['surveyor_email'] = currentUser?.email ?? 'anonymous';
      }

      if (tableName == 'village_survey_sessions') {
        payload.remove('page_completion_status');
        payload.remove('sync_pending');
        payload.remove('sync_status');
      }
      if (!payload.containsKey('session_id')) {
        final errMsg = 'WARNING: session_id missing in payload for $tableName!';
        _escalateError(errMsg, persistent: true);
      } else {
        debugPrint('[Supabase Sync] Upserting $tableName with session_id=${payload['session_id']}');
      }

      // Strip any deprecated accuracy fields before sending to Supabase.
      // Remote schema columns `accuracy` / `location_accuracy` were removed.
      payload.remove('accuracy');
      payload.remove('location_accuracy');

      debugPrint('[Supabase Sync] Payload: ' + payload.toString());
      debugPrint('[Supabase Sync] Authenticated user email: \\${currentUser?.email}');
      debugPrint('[Supabase Sync] payload["surveyor_email"]: \\${payload['surveyor_email']}');
      await _upsertWithRetry(tableName, _normalizeMap(payload));
    } catch (e) {
      final errMsg = 'ERROR saving $tableName: $e';
      _escalateError(errMsg, persistent: true);
      throw Exception('Failed to save village data to $tableName: $e');
    }
  }

  // Save family survey data to Supabase using village-style protocol
  Future<void> saveFamilyData(String tableName, Map<String, dynamic> data) async {
    try {
      final payload = Map<String, dynamic>.from(data);

      // Add surveyor_email if not present
      if (!payload.containsKey('surveyor_email') && currentUser?.email != null) {
        payload['surveyor_email'] = currentUser!.email;
      }

      if (tableName == 'family_survey_sessions') {
        // drop transient fields if inserted locally
        payload.remove('page_completion_status');
        payload.remove('sync_pending');
        payload.remove('sync_status');
        // Do not send timestamp columns that have DB defaults; let DB set them.
        payload.remove('created_at');
        payload.remove('updated_at');
      }

      if (!payload.containsKey('phone_number')) {
        final errMsg = 'WARNING: phone_number missing in payload for $tableName!';
        _escalateError(errMsg, persistent: true);
      } else {
        debugPrint('[Supabase Sync] Upserting $tableName with phone_number=${payload['phone_number']}');
      }

      // Strip any deprecated accuracy fields before sending to Supabase.
      // Remote schema columns `accuracy` / `location_accuracy` were removed.
      payload.remove('accuracy');
      payload.remove('location_accuracy');

      debugPrint('[Supabase Sync] Payload: ' + payload.toString());
      debugPrint('[Supabase Sync] Authenticated user email: ${currentUser?.email}');
      debugPrint('[Supabase Sync] payload["surveyor_email"]: ${payload['surveyor_email']}');
      await _upsertWithRetry(tableName, _normalizeMap(payload));
    } catch (e) {
      final errMsg = 'ERROR saving $tableName: $e';
      _escalateError(errMsg, persistent: true);
      throw Exception('Failed to save family data to $tableName: $e');
    }
  }

  /// Generic family survey sync that mirrors [syncVillageSurveyToSupabase].
  ///
  /// Splits the input into a main session row and a list of child table
  /// entries, upserting each individually using [saveFamilyData]. This is the
  /// same protocol used by the village flow and ensures identical behaviour
  /// for phone‑number key, logging and filtering.
  Future<void> syncFamilySurveyGeneric(String phoneNumber, Map<String, dynamic> data) async {
    // normalize phone key once
    final phoneKey = _phoneKey(phoneNumber) ?? phoneNumber;

    // copy payload and strip child tables
    final mainTableData = Map<String, dynamic>.from(data);

    const childTables = [
      'family_members',
      'land_holding',
      'irrigation_facilities',
      'crop_productivity',
      'fertilizer_usage',
      'animals',
      'agricultural_equipment',
      'entertainment_facilities',
      'transport_facilities',
      'drinking_water_sources',
      'medical_treatment',
      'disputes',
      'house_conditions',
      'house_facilities',
      'diseases',
      'children_data',
      'malnourished_children_data',
      'child_diseases',
      'folklore_medicine',
      'health_programmes',
      'malnutrition_data',
      'migration_data',
      'training_data',
      'shg_members',
      'fpo_members',
      'bank_accounts',
      'kisan_credit_card',
      'kisan_credit_card_members',
      'swachh_bharat_mission',
      'swachh_bharat_mission_members',
      'fasal_bima',
      'fasal_bima_members',
      'social_consciousness',
      'tribal_questions',
      'tulsi_plants',
      'nutritional_garden',
      // government schemes are handled separately by _syncGovernmentSchemesParallel
    ];

    for (var t in childTables) {
      mainTableData.remove(t);
    }

    // ensure phone in main
    mainTableData['phone_number'] = phoneKey;

    await saveFamilyData('family_survey_sessions', mainTableData);

    for (var t in childTables) {
      if (!data.containsKey(t)) continue;
      final tableData = data[t];
      if (tableData is List) {
        for (var item in tableData) {
          final mapItem = Map<String, dynamic>.from(item);
          mapItem['phone_number'] = phoneKey;
          await saveFamilyData(t, mapItem);
        }
      } else if (tableData is Map<String, dynamic>) {
        final mapItem = Map<String, dynamic>.from(tableData);
        mapItem['phone_number'] = phoneKey;
        await saveFamilyData(t, mapItem);
      }
    }

    // government scheme tables (non‑childTables) are handled in parallel
    try {
      await _syncGovernmentSchemesParallel(phoneKey, data, {});
    } catch (_) {
      // errors already escalated inside helper
    }
  }

  Future<void> syncVillageSurveyToSupabase(String sessionId, Map<String, dynamic> data) async {
    // Extract main session data
    final mainTableData = Map<String, dynamic>.from(data);
    
    // List of child tables to separate from main data
    final childTables = [
      'village_population', 'village_farm_families', 'village_housing',
      'village_agricultural_implements', 'village_crop_productivity', 'village_animals',
      'village_irrigation_facilities', 'village_drinking_water',
      'village_entertainment', 'village_medical_treatment', 'village_disputes',
      'village_educational_facilities', 'village_social_consciousness',
      'village_children_data', 'village_malnutrition_data', 'village_bpl_families',
      'village_kitchen_gardens', 'village_seed_clubs', 'village_biodiversity_register',
      'village_traditional_occupations', 'village_drainage_waste', 'village_signboards',
      'village_infrastructure', 'village_infrastructure_details', 'village_survey_details',
      'village_map_points', 'village_forest_maps', 'village_cadastral_maps',
      'village_unemployment', 'village_social_maps', 'village_transport_facilities'
    ];
    
    // Remove child data from main session payload
    for (var table in childTables) {
      mainTableData.remove(table);
    }
    
    // Sync main session
    await saveVillageData('village_survey_sessions', mainTableData);
    
    // Sync child tables
    for (var table in childTables) {
      if (data.containsKey(table)) {
        final tableData = data[table];
        
        if (tableData is List) {
           for (var item in tableData) {
             // Ensure session_id is present (it should be from local DB)
              final mapItem = Map<String, dynamic>.from(item);
              if (!mapItem.containsKey('session_id')) {
                mapItem['session_id'] = sessionId;
              }
              await saveVillageData(table, mapItem);
           }
        } else if (tableData is Map<String, dynamic>) {
           final mapItem = Map<String, dynamic>.from(tableData);
           if (!mapItem.containsKey('session_id')) {
             mapItem['session_id'] = sessionId;
           }
           await saveVillageData(table, mapItem);
        }
      }
    }
  }
}
