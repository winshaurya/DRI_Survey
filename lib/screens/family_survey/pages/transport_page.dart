import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class TransportPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const TransportPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<TransportPage> createState() => _TransportPageState();
}

class _TransportPageState extends State<TransportPage> {
  late bool _carJeep;
  late bool _motorcycleScooter;
  late bool _eRickshaw;
  late bool _cycle;
  late bool _pickupTruck;
  late bool _bullockCart;

  @override
  void initState() {
    super.initState();
    _carJeep = widget.pageData['car_jeep'] ?? false;
    _motorcycleScooter = widget.pageData['motorcycle_scooter'] ?? false;
    _eRickshaw = widget.pageData['e_rickshaw'] ?? false;
    _cycle = widget.pageData['cycle'] ?? false;
    _pickupTruck = widget.pageData['pickup_truck'] ?? false;
    _bullockCart = widget.pageData['bullock_cart'] ?? false;
  }

  void _updateData() {
    final data = {
      'car_jeep': _carJeep,
      'motorcycle_scooter': _motorcycleScooter,
      'e_rickshaw': _eRickshaw,
      'cycle': _cycle,
      'pickup_truck': _pickupTruck,
      'bullock_cart': _bullockCart,
    };
    widget.onDataChanged(data);
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
              'Transport Facilities',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInDown(
            delay: const Duration(milliseconds: 100),
            child: Text(
              'Select transport facilities owned by your family',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Car/Jeep
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Car / Jeep',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Four-wheeler vehicles'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.directions_car, color: Colors.blue),
                ),
                value: _carJeep,
                onChanged: (value) {
                  setState(() => _carJeep = value ?? false);
                  _updateData();
                },
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Motorcycle/Scooter
          FadeInLeft(
            delay: const Duration(milliseconds: 300),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Motorcycle / Scooter',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Two-wheeler vehicles'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.motorcycle, color: Colors.red),
                ),
                value: _motorcycleScooter,
                onChanged: (value) {
                  setState(() => _motorcycleScooter = value ?? false);
                  _updateData();
                },
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // E-Rickshaw
          FadeInLeft(
            delay: const Duration(milliseconds: 400),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'E-Rickshaw',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Electric rickshaw for transport'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.electric_rickshaw, color: Colors.green),
                ),
                value: _eRickshaw,
                onChanged: (value) {
                  setState(() => _eRickshaw = value ?? false);
                  _updateData();
                },
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Cycle
          FadeInLeft(
            delay: const Duration(milliseconds: 500),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Bicycle',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Cycle for local transport'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.pedal_bike, color: Colors.orange),
                ),
                value: _cycle,
                onChanged: (value) {
                  setState(() => _cycle = value ?? false);
                  _updateData();
                },
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Pickup Truck
          FadeInLeft(
            delay: const Duration(milliseconds: 600),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Pickup Truck',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Commercial vehicle'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.local_shipping, color: Colors.purple),
                ),
                value: _pickupTruck,
                onChanged: (value) {
                  setState(() => _pickupTruck = value ?? false);
                  _updateData();
                },
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Bullock Cart
          FadeInLeft(
            delay: const Duration(milliseconds: 700),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: CheckboxListTile(
                title: const Text(
                  'Bullock Cart',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Traditional animal-drawn cart'),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.brown[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.agriculture, color: Colors.brown),
                ),
                value: _bullockCart,
                onChanged: (value) {
                  setState(() => _bullockCart = value ?? false);
                  _updateData();
                },
                activeColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
