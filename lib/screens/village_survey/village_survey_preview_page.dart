import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/village_survey_provider.dart';
import '../../services/database_service.dart';
import '../../services/data_export_service.dart';

class VillageSurveyPreviewPage extends ConsumerStatefulWidget {
  final String shineCode;
  final bool fromHistory;
  final bool showSubmitButton;

  const VillageSurveyPreviewPage({
    super.key,
    required this.shineCode,
    this.fromHistory = false,
    this.showSubmitButton = false,
  });

  @override
  ConsumerState<VillageSurveyPreviewPage> createState() => _VillageSurveyPreviewPageState();
}

class _VillageSurveyPreviewPageState extends ConsumerState<VillageSurveyPreviewPage> {
  Map<String, dynamic> _surveyData = {};
  String? _sessionId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllSurveyData();
  }

  Future<void> _loadAllSurveyData() async {
    setState(() => _isLoading = true);
    
    try {
      final db = DatabaseService();
      final Map<String, dynamic> allData = {};

      // Load session data by shine_code
      final session = await db.getVillageSurveyByShineCode(widget.shineCode);
      if (session != null) {
        allData.addAll(session);
        _sessionId = session['session_id'] as String?;
      }

      if (_sessionId != null) {
        // Load infrastructure
        final infrastructure = await db.getVillageData('village_infrastructure', _sessionId!);
        if (infrastructure.isNotEmpty) {
          allData['infrastructure'] = infrastructure.first;
        }

        // Load infrastructure details
        final infraDetails = await db.getVillageData('village_infrastructure_details', _sessionId!);
        if (infraDetails.isNotEmpty) {
          allData['infrastructure_details'] = infraDetails.first;
        }

        // Load educational facilities
        final educational = await db.getVillageData('village_educational_facilities', _sessionId!);
        if (educational.isNotEmpty) {
          allData['educational'] = educational.first;
        }

        // Load drainage waste
        final drainage = await db.getVillageData('village_drainage_waste', _sessionId!);
        if (drainage.isNotEmpty) {
          allData['drainage'] = drainage.first;
        }

        // Load irrigation
        final irrigation = await db.getVillageData('village_irrigation_facilities', _sessionId!);
        if (irrigation.isNotEmpty) {
          allData['irrigation'] = irrigation.first;
        }

        // Load seed clubs
        final seedClubs = await db.getVillageData('village_seed_clubs', _sessionId!);
        if (seedClubs.isNotEmpty) {
          allData['seed_clubs'] = seedClubs.first;
        }

        // Load biodiversity
        final biodiversity = await db.getVillageData('village_biodiversity_register', _sessionId!);
        if (biodiversity.isNotEmpty) {
          allData['biodiversity'] = biodiversity.first;
        }

        // Load social map
        final socialMap = await db.getVillageData('village_social_maps', _sessionId!);
        if (socialMap.isNotEmpty) {
          allData['social_map'] = socialMap.first;
        }

        // Load traditional occupations
        final traditional = await db.getVillageData('village_traditional_occupations', _sessionId!);
        if (traditional.isNotEmpty) {
          allData['traditional'] = traditional;
        }

        // Load additional village tables
        final surveyDetails = await db.getVillageData('village_survey_details', _sessionId!);
        if (surveyDetails.isNotEmpty) allData['survey_details'] = surveyDetails.first;
        
        final population = await db.getVillageData('village_population', _sessionId!);
        if (population.isNotEmpty) allData['population'] = population.first;
        
        final farmFamilies = await db.getVillageData('village_farm_families', _sessionId!);
        if (farmFamilies.isNotEmpty) allData['farm_families'] = farmFamilies.first;
        
        final housing = await db.getVillageData('village_housing', _sessionId!);
        if (housing.isNotEmpty) allData['housing'] = housing.first;
        
        final agriImplements = await db.getVillageData('village_agricultural_implements', _sessionId!);
        if (agriImplements.isNotEmpty) allData['agricultural_implements'] = agriImplements.first;
        
        final crops = await db.getVillageData('village_crop_productivity', _sessionId!);
        if (crops.isNotEmpty) allData['crops'] = crops;
        
        final animals = await db.getVillageData('village_animals', _sessionId!);
        if (animals.isNotEmpty) allData['animals'] = animals;
        
        final water = await db.getVillageData('village_drinking_water', _sessionId!);
        if (water.isNotEmpty) allData['water'] = water.first;
        
        final transport = await db.getVillageData('village_transport_facilities', _sessionId!);
        if (transport.isNotEmpty) allData['transport'] = transport.first;
        
        final entertainment = await db.getVillageData('village_entertainment', _sessionId!);
        if (entertainment.isNotEmpty) allData['entertainment'] = entertainment.first;
        
        final medical = await db.getVillageData('village_medical_treatment', _sessionId!);
        if (medical.isNotEmpty) allData['medical'] = medical.first;
        
        final disputes = await db.getVillageData('village_disputes', _sessionId!);
        if (disputes.isNotEmpty) allData['disputes'] = disputes.first;
        
        final social = await db.getVillageData('village_social_consciousness', _sessionId!);
        if (social.isNotEmpty) allData['social'] = social.first;
        
        final children = await db.getVillageData('village_children_data', _sessionId!);
        if (children.isNotEmpty) allData['children'] = children.first;
        
        final malnutrition = await db.getVillageData('village_malnutrition_data', _sessionId!);
        if (malnutrition.isNotEmpty) allData['malnutrition'] = malnutrition;
        
        final bpl = await db.getVillageData('village_bpl_families', _sessionId!);
        if (bpl.isNotEmpty) allData['bpl'] = bpl.first;
        
        final kitchenGardens = await db.getVillageData('village_kitchen_gardens', _sessionId!);
        if (kitchenGardens.isNotEmpty) allData['kitchen_gardens'] = kitchenGardens.first;
        
        final unemployment = await db.getVillageData('village_unemployment', _sessionId!);
        if (unemployment.isNotEmpty) allData['unemployment'] = unemployment.first;
        
        // Load signboards
        final signboards = await db.getVillageData('village_signboards', _sessionId!);
        if (signboards.isNotEmpty) allData['signboards'] = signboards.first;
        
        // Load forest maps
        final forestMaps = await db.getVillageData('village_forest_maps', _sessionId!);
        if (forestMaps.isNotEmpty) allData['forest_maps'] = forestMaps.first;
        
        // Load cadastral maps
        final cadastralMaps = await db.getVillageData('village_cadastral_maps', _sessionId!);
        if (cadastralMaps.isNotEmpty) allData['cadastral_maps'] = cadastralMaps.first;
        
        // Load map points
        final mapPoints = await db.getVillageData('village_map_points', _sessionId!);
        if (mapPoints.isNotEmpty) allData['map_points'] = mapPoints;
      }

      setState(() {
        _surveyData = allData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading village survey data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Village Survey Preview')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Village Survey Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export to Excel',
            onPressed: _exportToExcel,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            
            // Action Buttons
            if (widget.fromHistory || widget.showSubmitButton)
              _buildActionButtons(),
            
            const SizedBox(height: 24),

            // Data Sections
            _buildSection('Basic Information', _buildBasicInfo(), Icons.info),
            _buildSectionIfHasData('Population & Demographics', _buildPopulation(), Icons.people, _surveyData['population']),
            _buildSectionIfHasData('Farm Families', _buildFarmFamilies(), Icons.agriculture, _surveyData['farm_families']),
            _buildSectionIfHasData('Housing Details', _buildHousing(), Icons.home_work, _surveyData['housing']),
            _buildSectionIfHasData('Infrastructure - Roads & Lanes', _buildInfrastructure(), Icons.engineering, _surveyData['infrastructure']),
            _buildSectionIfHasData('Infrastructure Availability', _buildInfrastructureDetails(), Icons.business, _surveyData['infrastructure_details']),
            _buildSectionIfHasData('Educational Facilities', _buildEducational(), Icons.school, _surveyData['educational']),
            _buildSectionIfHasData('Drainage & Waste Management', _buildDrainage(), Icons.water_drop, _surveyData['drainage']),
            _buildSectionIfHasData('Irrigation Facilities', _buildIrrigation(), Icons.agriculture, _surveyData['irrigation']),
            _buildSectionIfHasData('Seed Clubs', _buildSeedClubs(), Icons.grass, _surveyData['seed_clubs']),
            _buildSectionIfHasData('Kitchen Gardens', _buildKitchenGardens(), Icons.yard, _surveyData['kitchen_gardens']),
            _buildSectionIfHasData('Biodiversity Register', _buildBiodiversity(), Icons.eco, _surveyData['biodiversity']),
            _buildSectionIfHasData('Crops Productivity', _buildCrops(), Icons.grass, _surveyData['crops']),
            _buildSectionIfHasData('Animals/Livestock', _buildAnimals(), Icons.pets, _surveyData['animals']),
            _buildSectionIfHasData('Agricultural Implements', _buildAgriculturalImplements(), Icons.build, _surveyData['agricultural_implements']),
            _buildSectionIfHasData('Drinking Water Sources', _buildWater(), Icons.water, _surveyData['water']),
            _buildSectionIfHasData('Transport Facilities', _buildTransport(), Icons.directions_car, _surveyData['transport']),
            _buildSectionIfHasData('Entertainment Facilities', _buildEntertainment(), Icons.tv, _surveyData['entertainment']),
            _buildSectionIfHasData('Medical Treatment', _buildMedical(), Icons.local_hospital, _surveyData['medical']),
            _buildSectionIfHasData('Disputes', _buildDisputes(), Icons.gavel, _surveyData['disputes']),
            _buildSectionIfHasData('Social Consciousness', _buildSocialConsciousness(), Icons.psychology, _surveyData['social']),
            _buildSectionIfHasData('Social Map', _buildSocialMap(), Icons.map, _surveyData['social_map']),
            _buildSectionIfHasData('Signboards & Information', _buildSignboards(), Icons.signpost, _surveyData['signboards']),
            _buildSectionIfHasData('Detailed Map Points', _buildMapPoints(), Icons.location_on, _surveyData['map_points']),
            _buildSectionIfHasData('Cadastral Maps', _buildCadastralMaps(), Icons.map_outlined, _surveyData['cadastral_maps']),
            _buildSectionIfHasData('Forest Maps', _buildForestMaps(), Icons.forest, _surveyData['forest_maps']),
            _buildSectionIfHasData('Traditional Occupations', _buildTraditional(), Icons.work, _surveyData['traditional']),
            _buildSectionIfHasData('Children Data', _buildChildren(), Icons.child_care, _surveyData['children']),
            _buildSectionIfHasData('Malnutrition Data', _buildMalnutrition(), Icons.medical_services, _surveyData['malnutrition']),
            _buildSectionIfHasData('BPL Families', _buildBPL(), Icons.volunteer_activism, _surveyData['bpl']),
            _buildSectionIfHasData('Unemployment', _buildUnemployment(), Icons.work_off, _surveyData['unemployment']),
            _buildSectionIfHasData('Survey Details & Biodiversity', _buildSurveyDetails(), Icons.description, _surveyData['survey_details']),

            const SizedBox(height: 24),
            
            // Bottom Submit Button
            if (widget.showSubmitButton)
              _buildBottomSubmit(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final villageName = _surveyData['village_name'] ?? 'N/A';
    final shineCode = widget.shineCode;
    final createdDate = _surveyData['created_at'];
    String formattedDate = 'N/A';
    
    if (createdDate != null) {
      try {
        final date = DateTime.parse(createdDate);
        formattedDate = DateFormat('MMMM d, yyyy').format(date);
      } catch (_) {}
    }

    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              villageName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.qr_code, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('SHINE Code: $shineCode', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('Date: $formattedDate', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            if (widget.fromHistory)
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Survey'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _editSurvey,
                ),
              ),
            if (widget.fromHistory && widget.showSubmitButton)
              const SizedBox(width: 16),
            if (widget.showSubmitButton)
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Submit & Complete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _submitSurvey,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Excel Export Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.file_download),
            label: const Text('Export to Excel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _exportToExcel,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget content, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ExpansionTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: false,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionIfHasData(String title, Widget content, IconData icon, dynamic sectionData) {
    if (!_hasSectionData(sectionData)) {
      return const SizedBox.shrink();
    }
    return _buildSection(title, content, icon);
  }

  bool _hasSectionData(dynamic sectionData) {
    if (sectionData == null) return false;
    if (sectionData is Map) {
      if (sectionData.isEmpty) return false;
      return sectionData.values.any(_hasValue);
    }
    if (sectionData is List) {
      return sectionData.isNotEmpty;
    }
    return _hasValue(sectionData);
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('SHINE Code', widget.shineCode),
        _buildDataRow('Village Name', _surveyData['village_name']),
        _buildDataRow('Village Code', _surveyData['village_code']),
        _buildDataRow('Gram Panchayat', _surveyData['gram_panchayat']),
        _buildDataRow('Block', _surveyData['block']),
        _buildDataRow('Panchayat', _surveyData['panchayat']),
        _buildDataRow('Tehsil', _surveyData['tehsil']),
        _buildDataRow('State', _surveyData['state']),
        _buildDataRow('District', _surveyData['district']),
        _buildDataRow('LDG Code', _surveyData['ldg_code']),
        _buildDataRow('Latitude', _surveyData['latitude']),
        _buildDataRow('Longitude', _surveyData['longitude']),
        _buildDataRow('Survey Date', _surveyData['survey_date']),
        _buildDataRow('Status', _surveyData['status']),
      ],
    );
  }

  Widget _buildPopulation() {
    final pop = _surveyData['population'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Total Population', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[800])),
        const SizedBox(height: 8),
        _buildDataRow('Total Population', pop['total_population']),
        _buildDataRow('Male Population', pop['male_population']),
        _buildDataRow('Female Population', pop['female_population']),
        _buildDataRow('Other Population', pop['other_population']),
        const Divider(height: 24),
        Text('Age Groups', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[800])),
        const SizedBox(height: 8),
        _buildDataRow('Children (0-5)', pop['children_0_5']),
        _buildDataRow('Children (6-14)', pop['children_6_14']),
        _buildDataRow('Youth (15-24)', pop['youth_15_24']),
        _buildDataRow('Adults (25-59)', pop['adults_25_59']),
        _buildDataRow('Seniors (60+)', pop['seniors_60_plus']),
        const Divider(height: 24),
        Text('Education Levels', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[800])),
        const SizedBox(height: 8),
        _buildDataRow('Illiterate Population', pop['illiterate_population']),
        _buildDataRow('Primary Educated', pop['primary_educated']),
        _buildDataRow('Secondary Educated', pop['secondary_educated']),
        _buildDataRow('Higher Educated', pop['higher_educated']),
        const Divider(height: 24),
        Text('Caste Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[800])),
        const SizedBox(height: 8),
        _buildDataRow('SC Population', pop['sc_population']),
        _buildDataRow('ST Population', pop['st_population']),
        _buildDataRow('OBC Population', pop['obc_population']),
        _buildDataRow('General Population', pop['general_population']),
        const Divider(height: 24),
        Text('Employment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[800])),
        const SizedBox(height: 8),
        _buildDataRow('Working Population', pop['working_population']),
        _buildDataRow('Unemployed Population', pop['unemployed_population']),
      ],
    );
  }

  Widget _buildFarmFamilies() {
    final farm = _surveyData['farm_families'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Total Farm Families', farm['total_farm_families']),
        _buildDataRow('Big Farmers', farm['big_farmers']),
        _buildDataRow('Small Farmers', farm['small_farmers']),
        _buildDataRow('Marginal Farmers', farm['marginal_farmers']),
        _buildDataRow('Landless Farmers', farm['landless_farmers']),
      ],
    );
  }

  Widget _buildHousing() {
    final housing = _surveyData['housing'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('House Types', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown[800])),
        const SizedBox(height: 8),
        _buildDataRow('Katcha Houses', housing['katcha_houses']),
        _buildDataRow('Pakka Houses', housing['pakka_houses']),
        _buildDataRow('Katcha-Pakka Houses', housing['katcha_pakka_houses']),
        _buildDataRow('Hut Houses', housing['hut_houses']),
        const Divider(height: 24),
        Text('Facilities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown[800])),
        const SizedBox(height: 8),
        _buildDataRow('Houses with Toilet', housing['houses_with_toilet']),
        _buildDataRow('Functional Toilets', housing['functional_toilets']),
        _buildDataRow('Houses with Drainage', housing['houses_with_drainage']),
        _buildDataRow('Houses with Soak Pit', housing['houses_with_soak_pit']),
        _buildDataRow('Houses with Cattle Shed', housing['houses_with_cattle_shed']),
        _buildDataRow('Houses with Compost Pit', housing['houses_with_compost_pit']),
        _buildDataRow('Houses with Nadep', housing['houses_with_nadep']),
        _buildDataRow('Houses with LPG', housing['houses_with_lpg']),
        _buildDataRow('Houses with Biogas', housing['houses_with_biogas']),
        _buildDataRow('Houses with Solar', housing['houses_with_solar']),
        _buildDataRow('Houses with Electricity', housing['houses_with_electricity']),
      ],
    );
  }

  Widget _buildAgriculturalImplements() {
    final impl = _surveyData['agricultural_implements'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Tractor Available', impl['tractor_available']),
        _buildDataRow('Thresher Available', impl['thresher_available']),
        _buildDataRow('Seed Drill Available', impl['seed_drill_available']),
        _buildDataRow('Sprayer Available', impl['sprayer_available']),
        _buildDataRow('Duster Available', impl['duster_available']),
        _buildDataRow('Diesel Engine Available', impl['diesel_engine_available']),
        _buildDataRow('Other Implements', impl['other_implements']),
      ],
    );
  }

  Widget _buildCrops() {
    final crops = _surveyData['crops'] as List<dynamic>? ?? [];
    
    if (crops.isEmpty) {
      return const Text('No crops recorded', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return Column(
      children: crops.asMap().entries.map((entry) {
        final index = entry.key;
        final crop = entry.value as Map<String, dynamic>;
        return Card(
          color: Colors.green[50],
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  crop['crop_name'] ?? 'Crop ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                ),
                const Divider(height: 16),
                _buildDataRow('Sr. No', crop['sr_no']),
                _buildDataRow('Area (Hectares)', crop['area_hectares']),
                _buildDataRow('Productivity (Q/Ha)', crop['productivity_quintal_per_hectare']),
                _buildDataRow('Total Production (Q)', crop['total_production_quintal']),
                _buildDataRow('Quantity Consumed (Q)', crop['quantity_consumed_quintal']),
                _buildDataRow('Quantity Sold (Q)', crop['quantity_sold_quintal']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnimals() {
    final animals = _surveyData['animals'] as List<dynamic>? ?? [];
    
    if (animals.isEmpty) {
      return const Text('No animals recorded', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return Column(
      children: animals.map((animal) {
        final a = animal as Map<String, dynamic>;
        return Card(
          color: Colors.brown[50],
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a['animal_type'] ?? 'Animal',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown),
                ),
                const Divider(height: 16),
                _buildDataRow('Sr. No', a['sr_no']),
                _buildDataRow('Total Count', a['total_count']),
                _buildDataRow('Breed', a['breed']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWater() {
    final water = _surveyData['water'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Hand Pumps Available', water['hand_pumps_available']),
        _buildDataRow('Hand Pumps Count', water['hand_pumps_count']),
        _buildDataRow('Wells Available', water['wells_available']),
        _buildDataRow('Wells Count', water['wells_count']),
        _buildDataRow('Tube Wells Available', water['tube_wells_available']),
        _buildDataRow('Tube Wells Count', water['tube_wells_count']),
        _buildDataRow('Nal Jal Available', water['nal_jal_available']),
        _buildDataRow('Other Sources', water['other_sources']),
      ],
    );
  }

  Widget _buildTransport() {
    final transport = _surveyData['transport'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Tractor Count', transport['tractor_count']),
        _buildDataRow('Car/Jeep Count', transport['car_jeep_count']),
        _buildDataRow('Motorcycle/Scooter Count', transport['motorcycle_scooter_count']),
        _buildDataRow('Cycle Count', transport['cycle_count']),
        _buildDataRow('E-Rickshaw Count', transport['e_rickshaw_count']),
        _buildDataRow('Pickup/Truck Count', transport['pickup_truck_count']),
      ],
    );
  }

  Widget _buildEntertainment() {
    final ent = _surveyData['entertainment'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Smart Mobiles Available', ent['smart_mobiles_available']),
        _buildDataRow('Smart Mobiles Count', ent['smart_mobiles_count']),
        _buildDataRow('Analog Mobiles Available', ent['analog_mobiles_available']),
        _buildDataRow('Analog Mobiles Count', ent['analog_mobiles_count']),
        _buildDataRow('Televisions Available', ent['televisions_available']),
        _buildDataRow('Televisions Count', ent['televisions_count']),
        _buildDataRow('Radios Available', ent['radios_available']),
        _buildDataRow('Radios Count', ent['radios_count']),
        _buildDataRow('Games Available', ent['games_available']),
        _buildDataRow('Other Entertainment', ent['other_entertainment']),
      ],
    );
  }

  Widget _buildMedical() {
    final medical = _surveyData['medical'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Allopathic Available', medical['allopathic_available']),
        _buildDataRow('Ayurvedic Available', medical['ayurvedic_available']),
        _buildDataRow('Homeopathic Available', medical['homeopathic_available']),
        _buildDataRow('Traditional Available', medical['traditional_available']),
        _buildDataRow('Jhad Phook Available', medical['jhad_phook_available']),
        _buildDataRow('Other Treatment', medical['other_treatment']),
        _buildDataRow('Preference Order', medical['preference_order']),
      ],
    );
  }

  Widget _buildDisputes() {
    final disputes = _surveyData['disputes'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Family Disputes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red[800])),
        const SizedBox(height: 8),
        _buildDataRow('Family Disputes', disputes['family_disputes']),
        _buildDataRow('Family Registered', disputes['family_registered']),
        _buildDataRow('Family Period', disputes['family_period']),
        const Divider(height: 24),
        Text('Revenue Disputes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red[800])),
        const SizedBox(height: 8),
        _buildDataRow('Revenue Disputes', disputes['revenue_disputes']),
        _buildDataRow('Revenue Registered', disputes['revenue_registered']),
        _buildDataRow('Revenue Period', disputes['revenue_period']),
        const Divider(height: 24),
        Text('Criminal Disputes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red[800])),
        const SizedBox(height: 8),
        _buildDataRow('Criminal Disputes', disputes['criminal_disputes']),
        _buildDataRow('Criminal Registered', disputes['criminal_registered']),
        _buildDataRow('Criminal Period', disputes['criminal_period']),
        const Divider(height: 24),
        Text('Other Disputes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red[800])),
        const SizedBox(height: 8),
        _buildDataRow('Other Disputes', disputes['other_disputes']),
        _buildDataRow('Other Description', disputes['other_description']),
        _buildDataRow('Other Registered', disputes['other_registered']),
        _buildDataRow('Other Period', disputes['other_period']),
      ],
    );
  }

  Widget _buildSocialConsciousness() {
    final social = _surveyData['social'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Clothing Purchase Frequency', social['clothing_purchase_frequency']),
        _buildDataRow('Food Waste Level', social['food_waste_level']),
        _buildDataRow('Food Waste Amount', social['food_waste_amount']),
        _buildDataRow('Waste Disposal Method', social['waste_disposal_method']),
        _buildDataRow('Waste Segregation', social['waste_segregation']),
        _buildDataRow('Compost Pit Available', social['compost_pit_available']),
        _buildDataRow('Toilet Available', social['toilet_available']),
        _buildDataRow('Toilet Functional', social['toilet_functional']),
        _buildDataRow('Toilet Soak Pit', social['toilet_soak_pit']),
        _buildDataRow('LED Lights Used', social['led_lights_used']),
        _buildDataRow('Devices Turned Off', social['devices_turned_off']),
        _buildDataRow('Water Leaks Fixed', social['water_leaks_fixed']),
        _buildDataRow('Plastic Avoidance', social['plastic_avoidance']),
        _buildDataRow('Family Puja', social['family_puja']),
        _buildDataRow('Family Meditation', social['family_meditation']),
        _buildDataRow('Meditation Participants', social['meditation_participants']),
        _buildDataRow('Family Yoga', social['family_yoga']),
        _buildDataRow('Yoga Participants', social['yoga_participants']),
        _buildDataRow('Community Activities', social['community_activities']),
        _buildDataRow('Activity Types', social['activity_types']),
        _buildDataRow('Spiritual Discourses', social['spiritual_discourses']),
        _buildDataRow('Discourse Participants', social['discourse_participants']),
        _buildDataRow('Family Happiness', social['family_happiness']),
        _buildDataRow('Smoking Prevalence', social['smoking_prevalence']),
        _buildDataRow('Drinking Prevalence', social['drinking_prevalence']),
        _buildDataRow('Gudka Prevalence', social['gudka_prevalence']),
        _buildDataRow('Gambling Prevalence', social['gambling_prevalence']),
        _buildDataRow('Tobacco Prevalence', social['tobacco_prevalence']),
        _buildDataRow('Saving Habit', social['saving_habit']),
        _buildDataRow('Saving Percentage', social['saving_percentage']),
      ],
    );
  }

  Widget _buildChildren() {
    final children = _surveyData['children'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Births Last 3 Years', children['births_last_3_years']),
        _buildDataRow('Infant Deaths Last 3 Years', children['infant_deaths_last_3_years']),
        _buildDataRow('Malnourished Children', children['malnourished_children']),
        _buildDataRow('Malnourished Adults', children['malnourished_adults']),
      ],
    );
  }

  Widget _buildMalnutrition() {
    final malnutrition = _surveyData['malnutrition'] as List<dynamic>? ?? [];
    
    if (malnutrition.isEmpty) {
      return const Text('No malnutrition data recorded', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return Column(
      children: malnutrition.map((person) {
        final p = person as Map<String, dynamic>;
        return Card(
          color: Colors.red[50],
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['name'] ?? 'Person',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                ),
                const Divider(height: 16),
                _buildDataRow('Sr. No', p['sr_no']),
                _buildDataRow('Sex', p['sex']),
                _buildDataRow('Age', p['age']),
                _buildDataRow('Height (feet)', p['height_feet']),
                _buildDataRow('Weight (kg)', p['weight_kg']),
                _buildDataRow('Disease Cause', p['disease_cause']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBPL() {
    final bpl = _surveyData['bpl'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Total BPL Families', bpl['total_bpl_families']),
        _buildDataRow('BPL Families with Job Cards', bpl['bpl_families_with_job_cards']),
        _buildDataRow('BPL Families Received MGNREGA', bpl['bpl_families_received_mgnrega']),
      ],
    );
  }

  Widget _buildKitchenGardens() {
    final gardens = _surveyData['kitchen_gardens'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Gardens Available', gardens['gardens_available']),
        _buildDataRow('Total Gardens', gardens['total_gardens']),
      ],
    );
  }

  Widget _buildUnemployment() {
    final unemployment = _surveyData['unemployment'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Unemployed Youth', unemployment['unemployed_youth']),
        _buildDataRow('Unemployed Adults', unemployment['unemployed_adults']),
        _buildDataRow('Total Unemployed', unemployment['total_unemployed']),
      ],
    );
  }

  Widget _buildSurveyDetails() {
    final details = _surveyData['survey_details'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Forest Details', details['forest_details']),
        _buildDataRow('Wasteland Details', details['wasteland_details']),
        _buildDataRow('Garden Details', details['garden_details']),
        _buildDataRow('Burial Ground Details', details['burial_ground_details']),
        _buildDataRow('Crop Plants Details', details['crop_plants_details']),
        _buildDataRow('Vegetables Details', details['vegetables_details']),
        _buildDataRow('Fruit Trees Details', details['fruit_trees_details']),
        _buildDataRow('Animals Details', details['animals_details']),
        _buildDataRow('Birds Details', details['birds_details']),
        _buildDataRow('Local Biodiversity Details', details['local_biodiversity_details']),
        _buildDataRow('Traditional Knowledge Details', details['traditional_knowledge_details']),
        _buildDataRow('Special Features Details', details['special_features_details']),
      ],
    );
  }

  Widget _buildInfrastructure() {
    final infra = _surveyData['infrastructure'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Approach Roads', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange[800])),
        const SizedBox(height: 8),
        _buildDataRow('Approach Roads Available', infra['approach_roads_available']),
        _buildDataRow('Number of Approach Roads', infra['num_approach_roads']),
        _buildDataRow('Approach Condition', infra['approach_condition']),
        _buildDataRow('Approach Remarks', infra['approach_remarks']),
        const Divider(height: 24),
        Text('Internal Lanes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange[800])),
        const SizedBox(height: 8),
        _buildDataRow('Internal Lanes Available', infra['internal_lanes_available']),
        _buildDataRow('Number of Internal Lanes', infra['num_internal_lanes']),
        _buildDataRow('Internal Condition', infra['internal_condition']),
        _buildDataRow('Internal Remarks', infra['internal_remarks']),
      ],
    );
  }

  Widget _buildInfrastructureDetails() {
    final details = _surveyData['infrastructure_details'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Educational Infrastructure', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple[800])),
        const SizedBox(height: 8),
        _buildDataRow('Has Primary School', details['has_primary_school']),
        _buildDataRow('Primary School Distance', details['primary_school_distance']),
        _buildDataRow('Has Junior School', details['has_junior_school']),
        _buildDataRow('Junior School Distance', details['junior_school_distance']),
        _buildDataRow('Has High School', details['has_high_school']),
        _buildDataRow('High School Distance', details['high_school_distance']),
        _buildDataRow('Has Intermediate School', details['has_intermediate_school']),
        _buildDataRow('Intermediate School Distance', details['intermediate_school_distance']),
        _buildDataRow('Other Education Facilities', details['other_education_facilities']),
        _buildDataRow('Boys Students Count', details['boys_students_count']),
        _buildDataRow('Girls Students Count', details['girls_students_count']),
        const Divider(height: 24),
        Text('Community Infrastructure', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple[800])),
        const SizedBox(height: 8),
        _buildDataRow('Has Playground', details['has_playground']),
        _buildDataRow('Playground Remarks', details['playground_remarks']),
        _buildDataRow('Has Panchayat Bhavan', details['has_panchayat_bhavan']),
        _buildDataRow('Panchayat Remarks', details['panchayat_remarks']),
        _buildDataRow('Has Sharda Kendra', details['has_sharda_kendra']),
        _buildDataRow('Sharda Kendra Distance', details['sharda_kendra_distance']),
        const Divider(height: 24),
        Text('Services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple[800])),
        const SizedBox(height: 8),
        _buildDataRow('Has Post Office', details['has_post_office']),
        _buildDataRow('Post Office Distance', details['post_office_distance']),
        _buildDataRow('Has Health Facility', details['has_health_facility']),
        _buildDataRow('Health Facility Distance', details['health_facility_distance']),
        _buildDataRow('Has Bank', details['has_bank']),
        _buildDataRow('Bank Distance', details['bank_distance']),
        _buildDataRow('Has Electrical Connection', details['has_electrical_connection']),
        const Divider(height: 24),
        Text('Water Infrastructure', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.purple[800])),
        const SizedBox(height: 8),
        _buildDataRow('Number of Wells', details['num_wells']),
        _buildDataRow('Number of Ponds', details['num_ponds']),
        _buildDataRow('Number of Hand Pumps', details['num_hand_pumps']),
        _buildDataRow('Number of Tube Wells', details['num_tube_wells']),
        _buildDataRow('Number of Tap Water', details['num_tap_water']),
      ],
    );
  }

  Widget _buildEducational() {
    final edu = _surveyData['educational'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Primary Schools', edu['primary_schools']),
        _buildDataRow('Middle Schools', edu['middle_schools']),
        _buildDataRow('Secondary Schools', edu['secondary_schools']),
        _buildDataRow('Higher Secondary Schools', edu['higher_secondary_schools']),
        _buildDataRow('Anganwadi Centers', edu['anganwadi_centers']),
        _buildDataRow('Skill Development Centers', edu['skill_development_centers']),
        _buildDataRow('Shiksha Guarantee Centers', edu['shiksha_guarantee_centers']),
        _buildDataRow('Other Facility Name', edu['other_facility_name']),
        _buildDataRow('Other Facility Count', edu['other_facility_count']),
      ],
    );
  }

  Widget _buildDrainage() {
    final drainage = _surveyData['drainage'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Drainage System', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[800])),
        const SizedBox(height: 8),
        _buildDataRow('Earthen Drain', drainage['earthen_drain']),
        _buildDataRow('Masonry Drain', drainage['masonry_drain']),
        _buildDataRow('Covered Drain', drainage['covered_drain']),
        _buildDataRow('Open Channel', drainage['open_channel']),
        _buildDataRow('No Drainage System', drainage['no_drainage_system']),
        _buildDataRow('Drainage Destination', drainage['drainage_destination']),
        _buildDataRow('Drainage Remarks', drainage['drainage_remarks']),
        const Divider(height: 24),
        Text('Waste Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue[800])),
        const SizedBox(height: 8),
        _buildDataRow('Waste Collected Regularly', drainage['waste_collected_regularly']),
        _buildDataRow('Waste Segregated', drainage['waste_segregated']),
        _buildDataRow('Waste Remarks', drainage['waste_remarks']),
      ],
    );
  }

  Widget _buildIrrigation() {
    final irrigation = _surveyData['irrigation'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Has Canal', irrigation['has_canal']),
        _buildDataRow('Has Tube Well', irrigation['has_tube_well']),
        _buildDataRow('Has Ponds', irrigation['has_ponds']),
        _buildDataRow('Has River', irrigation['has_river']),
        _buildDataRow('Has Well', irrigation['has_well']),
      ],
    );
  }

  Widget _buildSeedClubs() {
    final clubs = _surveyData['seed_clubs'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Clubs Available', clubs['clubs_available']),
        _buildDataRow('Total Clubs', clubs['total_clubs']),
      ],
    );
  }

  Widget _buildBiodiversity() {
    final bio = _surveyData['biodiversity'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Status', bio['status']),
        _buildDataRow('Details', bio['details']),
        _buildDataRow('Components', bio['components']),
        _buildDataRow('Knowledge', bio['knowledge']),
      ],
    );
  }

  Widget _buildSocialMap() {
    final map = _surveyData['social_map'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Remarks', map['remarks']),
      ],
    );
  }

  Widget _buildTraditional() {
    final traditional = _surveyData['traditional'] as List<dynamic>? ?? [];
    
    if (traditional.isEmpty) {
      return const Text('No traditional occupations recorded', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return Column(
      children: traditional.map((occ) {
        final o = occ as Map<String, dynamic>;
        return Card(
          color: Colors.amber[50],
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  o['occupation_name'] ?? 'Occupation',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.amber),
                ),
                const Divider(height: 16),
                _buildDataRow('Sr. No', o['sr_no']),
                _buildDataRow('Families Engaged', o['families_engaged']),
                _buildDataRow('Average Income', o['average_income']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSignboards() {
    final signboards = _surveyData['signboards'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Signboards', signboards['signboards']),
        _buildDataRow('Information Boards', signboards['info_boards']),
        _buildDataRow('Wall Writing', signboards['wall_writing']),
      ],
    );
  }

  Widget _buildMapPoints() {
    final mapPoints = _surveyData['map_points'] as List<dynamic>? ?? [];
    
    if (mapPoints.isEmpty) {
      return const Text('No map points recorded', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return Column(
      children: mapPoints.asMap().entries.map((entry) {
        final index = entry.key;
        final point = entry.value as Map<String, dynamic>;
        return Card(
          color: Colors.lightBlue[50],
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Point ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
                ),
                const Divider(height: 16),
                _buildDataRow('Latitude', point['latitude']),
                _buildDataRow('Longitude', point['longitude']),
                _buildDataRow('Category', point['category']),
                _buildDataRow('Remarks', point['remarks']),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCadastralMaps() {
    final cadastral = _surveyData['cadastral_maps'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Survey Number', cadastral['survey_number']),
        _buildDataRow('Total Area (Hectares)', cadastral['total_area']),
        _buildDataRow('Map Details', cadastral['map_details']),
        _buildDataRow('Availability Status', cadastral['availability_status']),
      ],
    );
  }

  Widget _buildForestMaps() {
    final forest = _surveyData['forest_maps'] as Map<String, dynamic>? ?? {};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataRow('Forest Area', forest['forest_area']),
        _buildDataRow('Forest Types', forest['forest_types']),
        _buildDataRow('Forest Resources', forest['forest_resources']),
        _buildDataRow('Conservation Status', forest['conservation_status']),
        _buildDataRow('Remarks', forest['remarks']),
      ],
    );
  }

  Widget _buildDataRow(String label, dynamic value) {
    if (!_hasValue(value)) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasValue(dynamic value) {
    if (value == null) return false;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return false;
      if (trimmed.toLowerCase() == 'n/a' || trimmed.toLowerCase() == 'null') return false;
      return true;
    }
    if (value is List) return value.isNotEmpty;
    if (value is Map) return value.isNotEmpty;
    return true;
  }

  Widget _buildBottomSubmit() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.check_circle, size: 28),
        label: const Text('Submit Survey & Go Home', style: TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: _submitSurvey,
      ),
    );
  }

  Future<void> _exportToExcel() async {
    try {
      if (_sessionId == null) {
        throw Exception('No active village survey session found');
      }
      await DataExportService().exportCompleteVillageSurveyData(_sessionId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Village survey exported to Excel successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Export failed: $e')),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editSurvey() {
    if (_sessionId != null) {
      // Set session ID in database service for continuation
      DatabaseService().currentSessionId = _sessionId;
      
      // Navigate to village form (start of survey)
      Navigator.pushNamed(context, '/village-form');
    }
  }

  Future<void> _submitSurvey() async {
    if (_sessionId == null) return;
    
    try {
      // Mark survey as completed
      await DatabaseService().updateVillageSurveyStatus(_sessionId!, 'completed');
      
      // Sync to Supabase
      final notifier = ref.read(villageSurveyProvider.notifier);
      await notifier.completeSurvey();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Village survey submitted successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submit failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
