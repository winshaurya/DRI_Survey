import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';
import 'supabase_service.dart';

class FamilySyncService {
  static final FamilySyncService _instance = FamilySyncService._internal();
  static FamilySyncService get instance => _instance;

  final DatabaseService _databaseService = DatabaseService();
  final SupabaseService _supabaseService = SupabaseService.instance;

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _syncTimer;
  bool _isOnline = false;
  bool _connectivityInitialized = false;

  // Sync queue for offline data
  final List<Map<String, dynamic>> _syncQueue = [];
  bool _isProcessingQueue = false;

  // Sync status tracking per phone number
  final Map<String, Map<String, dynamic>> _syncStatus = {};

  // Timeout management
  final Map<String, Timer> _pageSyncTimeouts = {};
  static const Duration _pageSyncTimeout = Duration(minutes: 2); // Stop trying after 2 minutes per page

  FamilySyncService._internal() {
    _ensureConnectivityMonitoringInitialized();
    loadSyncQueue();
  }

  void _ensureConnectivityMonitoringInitialized() {
    if (_connectivityInitialized) return;
    _connectivityInitialized = true;
    _initializeConnectivityMonitoring();
  }

  Future<void> _initializeConnectivityMonitoring() async {
    final initialResult = await Connectivity().checkConnectivity();
    _isOnline = initialResult != ConnectivityResult.none;

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        final wasOnline = _isOnline;
        _isOnline = result != ConnectivityResult.none;

        if (!wasOnline && _isOnline) {
          // Network came back online, start processing queue
          _processSyncQueue();
        }
      },
    );

    if (_isOnline) {
      _processSyncQueue();
    }
  }

  /// Initialize survey session for page 0 (location page)
  /// Creates session in both local and Supabase databases
  /// Ensures RLS compliance by including surveyor_email
  Future<bool> initializeSurveySession({
    required String phoneNumber,
    required Map<String, dynamic> sessionData,
  }) async {
    try {
      // Ensure surveyor_email is included for RLS
      final currentUser = _supabaseService.currentUser;
      if (currentUser == null) {
        debugPrint('No authenticated user for RLS compliance');
        return false;
      }

      final surveyorEmail = currentUser.email;
      if (surveyorEmail == null) {
        debugPrint('No email available for RLS compliance');
        return false;
      }

      // First save locally with surveyor_email
      await _databaseService.saveData('family_survey_sessions', {
        'phone_number': phoneNumber,
        'surveyor_email': surveyorEmail,
        ...sessionData,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Initialize sync status for this phone number
      _syncStatus[phoneNumber] = {
        'session_created': true,
        'pages_synced': <int>{},
        'last_sync_attempt': DateTime.now(),
      };

      // Try to sync to Supabase immediately if online
      if (_isOnline) {
        try {
          await _supabaseService.client.from('family_survey_sessions').upsert({
            'phone_number': phoneNumber,
            'surveyor_email': surveyorEmail,
            ...sessionData,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'created_by': currentUser.id,
            'updated_by': currentUser.id,
          });
          _syncStatus[phoneNumber]?['session_synced'] = true;
          debugPrint('Session synced to Supabase successfully for $phoneNumber');
        } catch (e) {
          debugPrint('Failed to sync session to Supabase: $e');
          _syncStatus[phoneNumber]?['session_synced'] = false;
          // Queue for later sync
          await _queueSyncOperation('sync_session', {
            'phone_number': phoneNumber,
            'data': sessionData,
            'surveyor_email': surveyorEmail,
          });
        }
      } else {
        // Queue for when online
        await _queueSyncOperation('sync_session', {
          'phone_number': phoneNumber,
          'data': sessionData,
          'surveyor_email': surveyorEmail,
        });
      }

      return true;
    } catch (e) {
      debugPrint('Failed to initialize survey session: $e');
      return false;
    }
  }

  /// Save page data locally first, then trigger background Supabase sync
  Future<bool> savePageData({
    required String phoneNumber,
    required int page,
    required Map<String, dynamic> pageData,
  }) async {
    try {
      // Save locally first
      final success = await _savePageDataLocally(phoneNumber, page, pageData);
      if (!success) {
        debugPrint('Failed to save page $page locally for $phoneNumber');
        return false;
      }

      // Update sync status
      _syncStatus[phoneNumber] ??= {
        'pages_synced': <int>{},
        'last_sync_attempt': DateTime.now(),
      };
      (_syncStatus[phoneNumber]?['pages_synced'] as Set<int>?)?.add(page);

      // Trigger background Supabase sync for this page (non-blocking)
      _syncPageToSupabase(phoneNumber, page, pageData).catchError((e) {
        debugPrint('Background sync failed for page $page of $phoneNumber: $e');
      });

      return true;
    } catch (e) {
      debugPrint('Failed to save page $page for $phoneNumber: $e');
      return false;
    }
  }

  Future<bool> _savePageDataLocally(String phoneNumber, int page, Map<String, dynamic> data) async {
    try {
      switch (page) {
        case 1: // Family members
          await _databaseService.deleteByPhone('family_members', phoneNumber);
          if (data['family_members'] != null) {
            int srNo = 0;
            for (final member in data['family_members']) {
              srNo++;
              await _databaseService.saveData('family_members', {
                'phone_number': phoneNumber,
                'sr_no': member['sr_no'] ?? srNo,
                'name': member['name'],
                'fathers_name': member['fathers_name'],
                'mothers_name': member['mothers_name'],
                'relationship_with_head': member['relationship_with_head'],
                'age': member['age'],
                'sex': member['sex'],
                'physically_fit': member['physically_fit'],
                'physically_fit_cause': member['physically_fit_cause'],
                'educational_qualification': member['educational_qualification'],
                'inclination_self_employment': member['inclination_self_employment'],
                'occupation': member['occupation'],
                'days_employed': member['days_employed'],
                'income': member['income'],
                'awareness_about_village': member['awareness_about_village'],
                'participate_gram_sabha': member['participate_gram_sabha'],
                'insured': member['insured'],
                'insurance_company': member['insurance_company'],
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
                'is_deleted': 0,
              });
            }
          }
          break;

        case 2: // Social Consciousness
        case 3:
        case 4:
          await _databaseService.deleteByPhone('social_consciousness', phoneNumber);
          await _databaseService.deleteByPhone('tribal_questions', phoneNumber);
          await _databaseService.saveData('social_consciousness', {
            'phone_number': phoneNumber,
            ...data,
          });
          if (data['tribal_questions'] != null) {
            await _databaseService.saveData('tribal_questions', {
              'phone_number': phoneNumber,
              ...data['tribal_questions'],
            });
          }
          break;

        case 5: // Land Holding
          await _databaseService.deleteByPhone('land_holding', phoneNumber);
          await _databaseService.saveData('land_holding', {
            'phone_number': phoneNumber,
            'irrigated_area': data['irrigated_area'],
            'cultivable_area': data['cultivable_area'],
            'unirrigated_area': data['unirrigated_area'],
            'barren_land': data['barren_land'],
            'mango_trees': data['mango_trees'],
            'guava_trees': data['guava_trees'],
            'lemon_trees': data['lemon_trees'],
            'pomegranate_trees': data['pomegranate_trees'],
            'other_fruit_trees_name': data['other_fruit_trees_name'],
            'other_fruit_trees_count': data['other_fruit_trees_count'],
          });
          break;

        case 6: // Irrigation
          await _databaseService.deleteByPhone('irrigation_facilities', phoneNumber);
          await _databaseService.saveData('irrigation_facilities', {
            'phone_number': phoneNumber,
            ...data,
          });
          break;

        case 7: // Crop Productivity
          await _databaseService.deleteByPhone('crop_productivity', phoneNumber);
          if (data['crop_productivity'] != null) {
            int srNo = 0;
            for (final crop in data['crop_productivity']) {
              srNo++;
              await _databaseService.saveData('crop_productivity', {
                'phone_number': phoneNumber,
                'sr_no': crop['sr_no'] ?? srNo,
                'crop_name': crop['crop_name'],
                'area_hectares': crop['area_hectares'],
                'productivity_quintal_per_hectare': crop['productivity_quintal_per_hectare'],
                'total_production_quintal': crop['total_production_quintal'],
                'quantity_consumed_quintal': crop['quantity_consumed_quintal'],
                'quantity_sold_quintal': crop['quantity_sold_quintal'],
              });
            }
          }
          break;

        case 8: // Fertilizer Usage
          await _databaseService.deleteByPhone('fertilizer_usage', phoneNumber);
          await _databaseService.saveData('fertilizer_usage', {
            'phone_number': phoneNumber,
            ...data,
          });
          break;

        case 9: // Animals
          await _databaseService.deleteByPhone('animals', phoneNumber);
          if (data['animals'] != null) {
            int srNo = 0;
            for (final animal in data['animals']) {
              srNo++;
              await _databaseService.saveData('animals', {
                'phone_number': phoneNumber,
                'sr_no': animal['sr_no'] ?? srNo,
                'animal_type': animal['animal_type'],
                'number_of_animals': animal['number_of_animals'],
                'breed': animal['breed'],
                'production_per_animal': animal['production_per_animal'],
                'quantity_sold': animal['quantity_sold'],
              });
            }
          }
          break;

        case 10: // Agricultural Equipment
          await _databaseService.deleteByPhone('agricultural_equipment', phoneNumber);
          await _databaseService.saveData('agricultural_equipment', {
            'phone_number': phoneNumber,
            ...data,
          });
          break;

        case 11: // Entertainment Facilities
          await _databaseService.deleteByPhone('entertainment_facilities', phoneNumber);
          await _databaseService.saveData('entertainment_facilities', {
            'phone_number': phoneNumber,
            ...data,
          });
          break;

        case 12: // Transport Facilities
          await _databaseService.deleteByPhone('transport_facilities', phoneNumber);
          await _databaseService.saveData('transport_facilities', {
            'phone_number': phoneNumber,
            ...data,
          });
          break;

        case 13: // Drinking Water Sources
          await _databaseService.deleteByPhone('drinking_water_sources', phoneNumber);
          await _databaseService.saveData('drinking_water_sources', {
            'phone_number': phoneNumber,
            ...data,
          });
          break;

        case 14: // Medical Treatment
          await _databaseService.deleteByPhone('medical_treatment', phoneNumber);
          await _databaseService.saveData('medical_treatment', {
            'phone_number': phoneNumber,
            ...data,
          });
          break;

        case 15: // Disputes
          await _databaseService.deleteByPhone('disputes', phoneNumber);
          await _databaseService.saveData('disputes', {
            'phone_number': phoneNumber,
            ...data,
          });
          break;

        case 16: // House Conditions & Facilities
          await _databaseService.deleteByPhone('house_conditions', phoneNumber);
          await _databaseService.deleteByPhone('house_facilities', phoneNumber);
          await _databaseService.deleteByPhone('tulsi_plants', phoneNumber);
          await _databaseService.deleteByPhone('nutritional_garden', phoneNumber);

          await _databaseService.saveData('house_conditions', {
            'phone_number': phoneNumber,
            'katcha': data['katcha_house'] ?? false,
            'pakka': data['pakka_house'] ?? false,
            'katcha_pakka': data['katcha_pakka_house'] ?? false,
            'hut': data['hut_house'] ?? false,
            'toilet_in_use': data['toilet_in_use'],
            'toilet_condition': data['toilet_condition'],
          });

          await _databaseService.saveData('house_facilities', {
            'phone_number': phoneNumber,
            'toilet': data['toilet'] ?? false,
            'drainage': data['drainage'] ?? false,
            'soak_pit': data['soak_pit'] ?? false,
            'cattle_shed': data['cattle_shed'] ?? false,
            'compost_pit': data['compost_pit'] ?? false,
            'nadep': data['nadep'] ?? false,
            'lpg_gas': data['lpg_gas'] ?? false,
            'biogas': data['biogas'] ?? false,
            'solar_cooking': data['solar_cooking'] ?? false,
            'electric_connection': data['electric_connection'] ?? false,
            'nutritional_garden_available': data['nutritional_garden'] ?? false,
            'tulsi_plants_available': data['tulsi_plants'],
          });

          if (data['tulsi_plants'] != null) {
            await _databaseService.saveData('tulsi_plants', {
              'phone_number': phoneNumber,
              'has_plants': data['tulsi_plants'],
              'plant_count': data['tulsi_plant_count'],
            });
          }

          if (data['nutritional_garden'] != null) {
            await _databaseService.saveData('nutritional_garden', {
              'phone_number': phoneNumber,
              'has_garden': data['nutritional_garden'],
              'garden_size': data['nutritional_garden_size'],
              'vegetables_grown': data['nutritional_garden_vegetables'],
            });
          }
          break;

        case 17: // Diseases
          await _databaseService.deleteByPhone('diseases', phoneNumber);
          if (data['diseases'] != null) {
            int srNo = 0;
            for (final disease in data['diseases']) {
              srNo++;
              await _databaseService.saveData('diseases', {
                'phone_number': phoneNumber,
                'sr_no': disease['sr_no'] ?? srNo,
                'family_member_name': disease['family_member_name'] ?? disease['name'],
                'disease_name': disease['disease_name'],
                'suffering_since': disease['suffering_since'],
                'treatment_taken': disease['treatment_taken'],
                'treatment_from_when': disease['treatment_from_when'],
                'treatment_from_where': disease['treatment_from_where'],
                'treatment_taken_from': disease['treatment_taken_from'],
              });
            }
          }
          break;

        // Add remaining pages as needed...

        default:
          debugPrint('Page $page not implemented yet');
          return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error saving page $page locally: $e');
      return false;
    }
  }

  Future<void> _syncPageToSupabase(String phoneNumber, int page, Map<String, dynamic> data) async {
    if (!_isOnline || _supabaseService.currentUser == null) {
      // Queue for later
      await _queueSyncOperation('sync_page', {
        'phone_number': phoneNumber,
        'page': page,
        'data': data,
      });
      return;
    }

    // Ensure JWT is available for RLS
    final jwt = _supabaseService.currentUser?.id;
    if (jwt == null) {
      debugPrint('No JWT available for RLS, queuing operation');
      await _queueSyncOperation('sync_page', {
        'phone_number': phoneNumber,
        'page': page,
        'data': data,
      });
      return;
    }

    // Set timeout for this page sync
    final timeoutKey = '$phoneNumber:$page';
    _pageSyncTimeouts[timeoutKey]?.cancel();
    _pageSyncTimeouts[timeoutKey] = Timer(_pageSyncTimeout, () {
      debugPrint('Sync timeout for page $page of $phoneNumber');
      _pageSyncTimeouts.remove(timeoutKey);
    });

    try {
      // Sync logic based on page - matching Supabase schema exactly
      switch (page) {
        case 1: // Family members
          if (data['family_members'] != null) {
            // Delete existing records first
            await _supabaseService.client
                .from('family_members')
                .delete()
                .eq('phone_number', phoneNumber);

            // Insert new records
            for (final member in data['family_members']) {
              await _supabaseService.client.from('family_members').insert({
                'phone_number': phoneNumber,
                'sr_no': member['sr_no'],
                'name': member['name'],
                'fathers_name': member['fathers_name'],
                'mothers_name': member['mothers_name'],
                'relationship_with_head': member['relationship_with_head'],
                'age': member['age'],
                'sex': member['sex'],
                'physically_fit': member['physically_fit'],
                'physically_fit_cause': member['physically_fit_cause'],
                'educational_qualification': member['educational_qualification'],
                'inclination_self_employment': member['inclination_self_employment'],
                'occupation': member['occupation'],
                'days_employed': member['days_employed'],
                'income': member['income'],
                'awareness_about_village': member['awareness_about_village'],
                'participate_gram_sabha': member['participate_gram_sabha'],
                'insured': member['insured'],
                'insurance_company': member['insurance_company'],
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
                'is_deleted': 0,
              });
            }
          }
          break;

        case 2: // Social Consciousness
        case 3:
        case 4:
          // Delete existing records
          await _supabaseService.client
              .from('social_consciousness')
              .delete()
              .eq('phone_number', phoneNumber);

          await _supabaseService.client
              .from('tribal_questions')
              .delete()
              .eq('phone_number', phoneNumber);

          // Insert social consciousness
          await _supabaseService.client.from('social_consciousness').insert({
            'phone_number': phoneNumber,
            'clothes_frequency': data['clothes_frequency'],
            'clothes_other_specify': data['clothes_other_specify'],
            'food_waste_exists': data['food_waste_exists'],
            'food_waste_amount': data['food_waste_amount'],
            'waste_disposal': data['waste_disposal'],
            'waste_disposal_other': data['waste_disposal_other'],
            'separate_waste': data['separate_waste'],
            'compost_pit': data['compost_pit'],
            'recycle_used_items': data['recycle_used_items'],
            'led_lights': data['led_lights'],
            'turn_off_devices': data['turn_off_devices'],
            'fix_leaks': data['fix_leaks'],
            'avoid_plastics': data['avoid_plastics'],
            'family_prayers': data['family_prayers'],
            'family_meditation': data['family_meditation'],
            'meditation_members': data['meditation_members'],
            'family_yoga': data['family_yoga'],
            'yoga_members': data['yoga_members'],
            'community_activities': data['community_activities'],
            'spiritual_discourses': data['spiritual_discourses'],
            'discourses_members': data['discourses_members'],
            'personal_happiness': data['personal_happiness'],
            'family_happiness': data['family_happiness'],
            'happiness_family_who': data['happiness_family_who'],
            'financial_problems': data['financial_problems'],
            'family_disputes': data['family_disputes'],
            'illness_issues': data['illness_issues'],
            'unhappiness_reason': data['unhappiness_reason'],
            'addiction_smoke': data['addiction_smoke'],
            'addiction_drink': data['addiction_drink'],
            'addiction_gutka': data['addiction_gutka'],
            'addiction_gamble': data['addiction_gamble'],
            'addiction_tobacco': data['addiction_tobacco'],
            'addiction_details': data['addiction_details'],
            'created_at': DateTime.now().toIso8601String(),
          });

          // Insert tribal questions if present
          if (data['tribal_questions'] != null) {
            await _supabaseService.client.from('tribal_questions').insert({
              'phone_number': phoneNumber,
              'deity_name': data['tribal_questions']['deity_name'],
              'festival_name': data['tribal_questions']['festival_name'],
              'dance_name': data['tribal_questions']['dance_name'],
              'language': data['tribal_questions']['language'],
              'created_at': DateTime.now().toIso8601String(),
            });
          }
          break;

        case 5: // Land holding
          await _supabaseService.client
              .from('land_holding')
              .delete()
              .eq('phone_number', phoneNumber);

          await _supabaseService.client.from('land_holding').insert({
            'phone_number': phoneNumber,
            'irrigated_area': data['irrigated_area'],
            'cultivable_area': data['cultivable_area'],
            'unirrigated_area': data['unirrigated_area'],
            'barren_land': data['barren_land'],
            'mango_trees': data['mango_trees'],
            'guava_trees': data['guava_trees'],
            'lemon_trees': data['lemon_trees'],
            'pomegranate_trees': data['pomegranate_trees'],
            'other_fruit_trees_name': data['other_fruit_trees_name'],
            'other_fruit_trees_count': data['other_fruit_trees_count'],
            'created_at': DateTime.now().toIso8601String(),
          });
          break;

        case 6: // Irrigation
          await _supabaseService.client
              .from('irrigation_facilities')
              .delete()
              .eq('phone_number', phoneNumber);

          await _supabaseService.client.from('irrigation_facilities').insert({
            'phone_number': phoneNumber,
            'primary_source': data['primary_source'],
            'canal': data['canal'],
            'tube_well': data['tube_well'],
            'river': data['river'],
            'pond': data['pond'],
            'well': data['well'],
            'hand_pump': data['hand_pump'],
            'submersible': data['submersible'],
            'rainwater_harvesting': data['rainwater_harvesting'],
            'check_dam': data['check_dam'],
            'other_sources': data['other_sources'],
            'created_at': DateTime.now().toIso8601String(),
          });
          break;

        case 7: // Crop productivity
          if (data['crop_productivity'] != null) {
            await _supabaseService.client
                .from('crop_productivity')
                .delete()
                .eq('phone_number', phoneNumber);

            for (final crop in data['crop_productivity']) {
              await _supabaseService.client.from('crop_productivity').insert({
                'phone_number': phoneNumber,
                'sr_no': crop['sr_no'],
                'season': crop['season'],
                'crop_name': crop['crop_name'],
                'area_hectares': crop['area_hectares'],
                'productivity_quintal_per_hectare': crop['productivity_quintal_per_hectare'],
                'total_production_quintal': crop['total_production_quintal'],
                'quantity_consumed_quintal': crop['quantity_consumed_quintal'],
                'quantity_sold_quintal': crop['quantity_sold_quintal'],
                'created_at': DateTime.now().toIso8601String(),
              });
            }
          }
          break;

        case 8: // Fertilizer Usage
          await _supabaseService.client
              .from('fertilizer_usage')
              .delete()
              .eq('phone_number', phoneNumber);

          await _supabaseService.client.from('fertilizer_usage').insert({
            'phone_number': phoneNumber,
            'urea_fertilizer': data['urea_fertilizer'],
            'organic_fertilizer': data['organic_fertilizer'],
            'fertilizer_types': data['fertilizer_types'],
            'fertilizer_expenditure': data['fertilizer_expenditure'],
            'created_at': DateTime.now().toIso8601String(),
          });
          break;

        case 9: // Animals
          if (data['animals'] != null) {
            await _supabaseService.client
                .from('animals')
                .delete()
                .eq('phone_number', phoneNumber);

            for (final animal in data['animals']) {
              await _supabaseService.client.from('animals').insert({
                'phone_number': phoneNumber,
                'sr_no': animal['sr_no'],
                'animal_type': animal['animal_type'],
                'number_of_animals': animal['number_of_animals'],
                'breed': animal['breed'],
                'production_per_animal': animal['production_per_animal'],
                'quantity_sold': animal['quantity_sold'],
                'created_at': DateTime.now().toIso8601String(),
              });
            }
          }
          break;

        case 10: // Agricultural Equipment
          await _supabaseService.client
              .from('agricultural_equipment')
              .delete()
              .eq('phone_number', phoneNumber);

          await _supabaseService.client.from('agricultural_equipment').insert({
            'phone_number': phoneNumber,
            'tractor': data['tractor'],
            'tractor_condition': data['tractor_condition'],
            'thresher': data['thresher'],
            'thresher_condition': data['thresher_condition'],
            'seed_drill': data['seed_drill'],
            'seed_drill_condition': data['seed_drill_condition'],
            'sprayer': data['sprayer'],
            'sprayer_condition': data['sprayer_condition'],
            'duster': data['duster'],
            'duster_condition': data['duster_condition'],
            'diesel_engine': data['diesel_engine'],
            'diesel_engine_condition': data['diesel_engine_condition'],
            'other_equipment': data['other_equipment'],
            'created_at': DateTime.now().toIso8601String(),
          });
          break;

        case 11: // Entertainment Facilities
          await _supabaseService.client
              .from('entertainment_facilities')
              .delete()
              .eq('phone_number', phoneNumber);

          await _supabaseService.client.from('entertainment_facilities').insert({
            'phone_number': phoneNumber,
            'smart_mobile': data['smart_mobile'],
            'smart_mobile_count': data['smart_mobile_count'],
            'analog_mobile': data['analog_mobile'],
            'analog_mobile_count': data['analog_mobile_count'],
            'television': data['television'],
            'radio': data['radio'],
            'games': data['games'],
            'other_entertainment': data['other_entertainment'],
            'other_specify': data['other_specify'],
            'created_at': DateTime.now().toIso8601String(),
          });
          break;

        case 12: // Transport Facilities
          await _supabaseService.client
              .from('transport_facilities')
              .delete()
              .eq('phone_number', phoneNumber);

          await _supabaseService.client.from('transport_facilities').insert({
            'phone_number': phoneNumber,
            'car_jeep': data['car_jeep'],
            'motorcycle_scooter': data['motorcycle_scooter'],
            'e_rickshaw': data['e_rickshaw'],
            'cycle': data['cycle'],
            'pickup_truck': data['pickup_truck'],
            'bullock_cart': data['bullock_cart'],
            'created_at': DateTime.now().toIso8601String(),
          });
          break;

        case 13: // Drinking Water Sources
          await _supabaseService.client
              .from('drinking_water_sources')
              .delete()
              .eq('phone_number', phoneNumber);

          await _supabaseService.client.from('drinking_water_sources').insert({
            'phone_number': phoneNumber,
            'hand_pumps': data['hand_pumps'],
            'hand_pumps_distance': data['hand_pumps_distance'],
            'hand_pumps_quality': data['hand_pumps_quality'],
            'well': data['well'],
            'well_distance': data['well_distance'],
            'well_quality': data['well_quality'],
            'tubewell': data['tubewell'],
            'tubewell_distance': data['tubewell_distance'],
            'tubewell_quality': data['tubewell_quality'],
            'nal_jaal': data['nal_jaal'],
            'nal_jaal_quality': data['nal_jaal_quality'],
            'other_source': data['other_source'],
            'other_distance': data['other_distance'],
            'other_sources_quality': data['other_sources_quality'],
            'created_at': DateTime.now().toIso8601String(),
          });
          break;

        case 14: // Medical Treatment
          await _supabaseService.client
              .from('medical_treatment')
              .delete()
              .eq('phone_number', phoneNumber);

          await _supabaseService.client.from('medical_treatment').insert({
            'phone_number': phoneNumber,
            'allopathic': data['allopathic'],
            'ayurvedic': data['ayurvedic'],
            'homeopathy': data['homeopathy'],
            'traditional': data['traditional'],
            'other_treatment': data['other_treatment'],
            'preferred_treatment': data['preferred_treatment'],
            'created_at': DateTime.now().toIso8601String(),
          });
          break;

        case 15: // Disputes
          await _supabaseService.client
              .from('disputes')
              .delete()
              .eq('phone_number', phoneNumber);

          await _supabaseService.client.from('disputes').insert({
            'phone_number': phoneNumber,
            'family_disputes': data['family_disputes'],
            'family_registered': data['family_registered'],
            'family_period': data['family_period'],
            'revenue_disputes': data['revenue_disputes'],
            'revenue_registered': data['revenue_registered'],
            'revenue_period': data['revenue_period'],
            'criminal_disputes': data['criminal_disputes'],
            'criminal_registered': data['criminal_registered'],
            'criminal_period': data['criminal_period'],
            'other_disputes': data['other_disputes'],
            'other_description': data['other_description'],
            'other_registered': data['other_registered'],
            'other_period': data['other_period'],
            'created_at': DateTime.now().toIso8601String(),
          });
          break;

        case 16: // House Conditions & Facilities
          await _supabaseService.client
              .from('house_conditions')
              .delete()
              .eq('phone_number', phoneNumber);

          await _supabaseService.client
              .from('house_facilities')
              .delete()
              .eq('phone_number', phoneNumber);

          await _supabaseService.client
              .from('tulsi_plants')
              .delete()
              .eq('phone_number', phoneNumber);

          await _supabaseService.client
              .from('nutritional_garden')
              .delete()
              .eq('phone_number', phoneNumber);

          // Insert house conditions
          await _supabaseService.client.from('house_conditions').insert({
            'phone_number': phoneNumber,
            'katcha': data['katcha_house'] ?? false,
            'pakka': data['pakka_house'] ?? false,
            'katcha_pakka': data['katcha_pakka_house'] ?? false,
            'hut': data['hut_house'] ?? false,
            'toilet_in_use': data['toilet_in_use'],
            'toilet_condition': data['toilet_condition'],
            'created_at': DateTime.now().toIso8601String(),
          });

          // Insert house facilities
          await _supabaseService.client.from('house_facilities').insert({
            'phone_number': phoneNumber,
            'toilet': data['toilet'] ?? false,
            'drainage': data['drainage'] ?? false,
            'soak_pit': data['soak_pit'] ?? false,
            'cattle_shed': data['cattle_shed'] ?? false,
            'compost_pit': data['compost_pit'] ?? false,
            'nadep': data['nadep'] ?? false,
            'lpg_gas': data['lpg_gas'] ?? false,
            'biogas': data['biogas'] ?? false,
            'solar_cooking': data['solar_cooking'] ?? false,
            'electric_connection': data['electric_connection'] ?? false,
            'nutritional_garden_available': data['nutritional_garden'] ?? false,
            'tulsi_plants_available': data['tulsi_plants'],
            'created_at': DateTime.now().toIso8601String(),
          });

          // Insert tulsi plants if present
          if (data['tulsi_plants'] != null) {
            await _supabaseService.client.from('tulsi_plants').insert({
              'phone_number': phoneNumber,
              'has_plants': data['tulsi_plants'],
              'plant_count': data['tulsi_plant_count'],
              'created_at': DateTime.now().toIso8601String(),
            });
          }

          // Insert nutritional garden if present
          if (data['nutritional_garden'] != null) {
            await _supabaseService.client.from('nutritional_garden').insert({
              'phone_number': phoneNumber,
              'has_garden': data['nutritional_garden'],
              'garden_size': data['nutritional_garden_size'],
              'vegetables_grown': data['nutritional_garden_vegetables'],
              'created_at': DateTime.now().toIso8601String(),
            });
          }
          break;

        case 17: // Diseases
          if (data['diseases'] != null) {
            await _supabaseService.client
                .from('diseases')
                .delete()
                .eq('phone_number', phoneNumber);

            for (final disease in data['diseases']) {
              await _supabaseService.client.from('diseases').insert({
                'phone_number': phoneNumber,
                'sr_no': disease['sr_no'],
                'family_member_name': disease['family_member_name'] ?? disease['name'],
                'disease_name': disease['disease_name'],
                'suffering_since': disease['suffering_since'],
                'treatment_taken': disease['treatment_taken'],
                'treatment_from_when': disease['treatment_from_when'],
                'treatment_from_where': disease['treatment_from_where'],
                'treatment_taken_from': disease['treatment_taken_from'],
                'created_at': DateTime.now().toIso8601String(),
              });
            }
          }
          break;

        // Add remaining pages as needed...

        default:
          debugPrint('Supabase sync not implemented for page $page yet');
      }

      // Mark as synced
      _syncStatus[phoneNumber] ??= {'pages_synced': <int>{}};
      (_syncStatus[phoneNumber]?['pages_synced'] as Set<int>?)?.add(page);

    } catch (e) {
      debugPrint('Failed to sync page $page to Supabase: $e');
      // Queue for retry
      await _queueSyncOperation('sync_page', {
        'phone_number': phoneNumber,
        'page': page,
        'data': data,
      });
    } finally {
      _pageSyncTimeouts[timeoutKey]?.cancel();
      _pageSyncTimeouts.remove(timeoutKey);
    }
  }

  Future<void> _queueSyncOperation(String operation, Map<String, dynamic> data) async {
    _syncQueue.add({
      'operation': operation,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });

    await _saveSyncQueue();

    if (_isOnline) {
      await _processSyncQueue();
    }
  }

  Future<void> _processSyncQueue() async {
    if (_isProcessingQueue || !_isOnline || _syncQueue.isEmpty) return;

    _isProcessingQueue = true;

    try {
      final queueCopy = List<Map<String, dynamic>>.from(_syncQueue);
      final successfulOperations = <int>[];

      for (int i = 0; i < queueCopy.length; i++) {
        final operation = queueCopy[i];
        try {
          await _executeQueuedOperation(operation);
          successfulOperations.add(i);
        } catch (e) {
          debugPrint('Failed to execute queued operation: $e');
          operation['retry_count'] = (operation['retry_count'] ?? 0) + 1;

          // Remove if max retries exceeded
          if (operation['retry_count'] >= 3) {
            successfulOperations.add(i); // Remove permanently failed
          }
        }
      }

      // Remove processed operations
      successfulOperations.sort((a, b) => b.compareTo(a));
      for (final index in successfulOperations) {
        _syncQueue.removeAt(index);
      }

      await _saveSyncQueue();

    } finally {
      _isProcessingQueue = false;
    }
  }

  Future<void> _executeQueuedOperation(Map<String, dynamic> operation) async {
    final opType = operation['operation'];
    final data = operation['data'];

    switch (opType) {
      case 'sync_session':
        await _supabaseService.client.from('family_survey_sessions').upsert({
          ...data['data'],
          'phone_number': data['phone_number'],
          'surveyor_email': data['surveyor_email'],
          'updated_at': DateTime.now().toIso8601String(),
        });
        break;

      case 'sync_page':
        await _syncPageToSupabase(data['phone_number'], data['page'], data['data']);
        break;
    }
  }

  Future<void> _saveSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('family_sync_queue', jsonEncode(_syncQueue));
      debugPrint('Family sync queue saved with ${_syncQueue.length} operations');
    } catch (e) {
      debugPrint('Failed to save family sync queue: $e');
    }
  }

  Future<void> loadSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString('family_sync_queue');
      if (queueJson != null && queueJson.isNotEmpty) {
        final decoded = jsonDecode(queueJson);
        if (decoded is List) {
          _syncQueue
            ..clear()
            ..addAll(decoded.whereType<Map>().map((item) =>
                item.map((k, v) => MapEntry(k.toString(), v))));
        }
      }
      debugPrint('Family sync queue loaded with ${_syncQueue.length} operations');
    } catch (e) {
      debugPrint('Failed to load family sync queue: $e');
    }
  }

  Future<void> forceSyncAllPending() async {
    if (!_isOnline) return;

    await _processSyncQueue();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    for (final timer in _pageSyncTimeouts.values) {
      timer.cancel();
    }
    _pageSyncTimeouts.clear();
  }
}