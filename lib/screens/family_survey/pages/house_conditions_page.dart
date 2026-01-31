import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class HouseConditionsPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const HouseConditionsPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<HouseConditionsPage> createState() => _HouseConditionsPageState();
}

class _HouseConditionsPageState extends State<HouseConditionsPage> {
  // House Type
  bool _katchaHouse = false;
  bool _pakkaHouse = false;
  bool _katchaPakkaHouse = false;
  bool _hutHouse = false;

  // Facilities
  bool _toilet = false;
  bool _drainage = false;
  bool _soakPit = false;
  bool _cattleShed = false;
  bool _compostPit = false;
  bool _nadep = false;
  bool _lpgGas = false;
  bool _biogas = false;
  bool _solarCooking = false;
  bool _electricConnection = false;
  bool _nutritionalGarden = false;

  // Other
  String? _tulsiPlants;
  String? _numberOfRooms;
  String? _houseOwnership;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _katchaHouse = widget.pageData['katcha_house'] ?? false;
    _pakkaHouse = widget.pageData['pakka_house'] ?? false;
    _katchaPakkaHouse = widget.pageData['katcha_pakka_house'] ?? false;
    _hutHouse = widget.pageData['hut_house'] ?? false;

    _toilet = widget.pageData['toilet'] ?? false;
    _drainage = widget.pageData['drainage'] ?? false;
    _soakPit = widget.pageData['soak_pit'] ?? false;
    _cattleShed = widget.pageData['cattle_shed'] ?? false;
    _compostPit = widget.pageData['compost_pit'] ?? false;
    _nadep = widget.pageData['nadep'] ?? false;
    _lpgGas = widget.pageData['lpg_gas'] ?? false;
    _biogas = widget.pageData['biogas'] ?? false;
    _solarCooking = widget.pageData['solar_cooking'] ?? false;
    _electricConnection = widget.pageData['electric_connection'] ?? false;
    _nutritionalGarden = widget.pageData['nutritional_garden'] ?? false;

    _tulsiPlants = widget.pageData['tulsi_plants'];
    _numberOfRooms = widget.pageData['number_of_rooms'];
    _houseOwnership = widget.pageData['house_ownership'];
  }

  void _updateData() {
    final data = {
      'katcha_house': _katchaHouse,
      'pakka_house': _pakkaHouse,
      'katcha_pakka_house': _katchaPakkaHouse,
      'hut_house': _hutHouse,
      'toilet': _toilet,
      'drainage': _drainage,
      'soak_pit': _soakPit,
      'cattle_shed': _cattleShed,
      'compost_pit': _compostPit,
      'nadep': _nadep,
      'lpg_gas': _lpgGas,
      'biogas': _biogas,
      'solar_cooking': _solarCooking,
      'electric_connection': _electricConnection,
      'nutritional_garden': _nutritionalGarden,
      'tulsi_plants': _tulsiPlants,
      'number_of_rooms': _numberOfRooms,
      'house_ownership': _houseOwnership,
    };
    widget.onDataChanged(data);
  }

  Widget _buildCheckboxField(String label, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: (val) {
        onChanged(val);
        _updateData();
      },
      controlAffinity: ListTileControlAffinity.leading,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child: Text(
              l10n.houseConditions,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Please provide details about your house conditions',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),

          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: Text(
              'House Type:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          FadeInLeft(delay: const Duration(milliseconds: 250), child: _buildCheckboxField(l10n.katcha, _katchaHouse, (v) => setState(() => _katchaHouse = v ?? false))),
          FadeInLeft(delay: const Duration(milliseconds: 300), child: _buildCheckboxField(l10n.pakka, _pakkaHouse, (v) => setState(() => _pakkaHouse = v ?? false))),
          FadeInLeft(delay: const Duration(milliseconds: 350), child: _buildCheckboxField(l10n.katchaPakka, _katchaPakkaHouse, (v) => setState(() => _katchaPakkaHouse = v ?? false))),
          FadeInLeft(delay: const Duration(milliseconds: 400), child: _buildCheckboxField(l10n.hut, _hutHouse, (v) => setState(() => _hutHouse = v ?? false))),

          const SizedBox(height: 24),

          FadeInLeft(
            delay: const Duration(milliseconds: 500),
            child: Text(
              l10n.houseFacilities,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Facilities
          FadeInUp(delay: const Duration(milliseconds: 550), child: _buildCheckboxField(l10n.toilet, _toilet, (v) => setState(() => _toilet = v ?? false))),
          FadeInUp(delay: const Duration(milliseconds: 600), child: _buildCheckboxField(l10n.drainage, _drainage, (v) => setState(() => _drainage = v ?? false))),
          FadeInUp(delay: const Duration(milliseconds: 650), child: _buildCheckboxField(l10n.soakPit, _soakPit, (v) => setState(() => _soakPit = v ?? false))),
          FadeInUp(delay: const Duration(milliseconds: 700), child: _buildCheckboxField(l10n.cattleShed, _cattleShed, (v) => setState(() => _cattleShed = v ?? false))),
          FadeInUp(delay: const Duration(milliseconds: 750), child: _buildCheckboxField(l10n.compostPit, _compostPit, (v) => setState(() => _compostPit = v ?? false))),
          FadeInUp(delay: const Duration(milliseconds: 800), child: _buildCheckboxField(l10n.nadep, _nadep, (v) => setState(() => _nadep = v ?? false))),
          FadeInUp(delay: const Duration(milliseconds: 850), child: _buildCheckboxField(l10n.lpgGas, _lpgGas, (v) => setState(() => _lpgGas = v ?? false))),
          FadeInUp(delay: const Duration(milliseconds: 900), child: _buildCheckboxField(l10n.biogas, _biogas, (v) => setState(() => _biogas = v ?? false))),
          FadeInUp(delay: const Duration(milliseconds: 950), child: _buildCheckboxField(l10n.solarCooking, _solarCooking, (v) => setState(() => _solarCooking = v ?? false))),
          FadeInUp(delay: const Duration(milliseconds: 1000), child: _buildCheckboxField(l10n.electricConnection, _electricConnection, (v) => setState(() => _electricConnection = v ?? false))),
          FadeInUp(delay: const Duration(milliseconds: 1050), child: _buildCheckboxField(l10n.nutritionalGarden, _nutritionalGarden, (v) => setState(() => _nutritionalGarden = v ?? false))),

          const SizedBox(height: 16),

          FadeInUp(
            delay: const Duration(milliseconds: 1100),
            child: Text(
              'Do you have Tulsi plants?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          FadeInUp(
            delay: const Duration(milliseconds: 1150),
            child: Row(
              children: [
                Radio<String>(
                  value: 'yes',
                  groupValue: _tulsiPlants,
                  onChanged: (value) {
                    setState(() {
                      _tulsiPlants = value;
                    });
                    _updateData();
                  },
                  activeColor: Colors.green,
                ),
                const Text('Yes'),
                const SizedBox(width: 20),
                Radio<String>(
                  value: 'no',
                  groupValue: _tulsiPlants,
                  onChanged: (value) {
                    setState(() {
                      _tulsiPlants = value;
                    });
                    _updateData();
                  },
                  activeColor: Colors.green,
                ),
                const Text('No'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          FadeInUp(
            delay: const Duration(milliseconds: 1200),
            child: TextFormField(
              initialValue: _numberOfRooms,
              decoration: InputDecoration(
                labelText: 'Number of rooms',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _numberOfRooms = value;
                _updateData();
              },
            ),
          ),

          const SizedBox(height: 16),

          FadeInUp(
            delay: const Duration(milliseconds: 1250),
            child: TextFormField(
              initialValue: _houseOwnership,
              decoration: InputDecoration(
                labelText: 'House ownership (Owned/Rented)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                _houseOwnership = value;
                _updateData();
              },
            ),
          ),
        ],
      ),
    );
  }
}