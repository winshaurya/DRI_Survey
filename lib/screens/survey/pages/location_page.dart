import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../services/location_service.dart';

class LocationPage extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const LocationPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  bool _isLoadingLocation = false;
  bool _locationFetched = false;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    if (_locationFetched) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationData = await LocationService.getCompleteLocationData();

      if (locationData != null && mounted) {
        setState(() {
          widget.pageData['latitude'] = locationData['latitude'];
          widget.pageData['longitude'] = locationData['longitude'];
          widget.pageData['accuracy'] = locationData['accuracy'];
          widget.pageData['location_timestamp'] = locationData['timestamp'];

          // Auto-fill address fields
          if (locationData['village']?.isNotEmpty == true) {
            widget.pageData['village_name'] = locationData['village'];
          }
          if (locationData['district']?.isNotEmpty == true) {
            widget.pageData['district'] = locationData['district'];
          }
          if (locationData['state']?.isNotEmpty == true) {
            widget.pageData['state'] = locationData['state'];
          }
          if (locationData['pincode']?.isNotEmpty == true) {
            widget.pageData['pin_code'] = locationData['pincode'];
          }

          _locationFetched = true;
        });

        widget.onDataChanged(widget.pageData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToGetLocation(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.locationInformation,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            IconButton(
              onPressed: _isLoadingLocation ? null : _fetchLocation,
              icon: _isLoadingLocation
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              tooltip: l10n.getCurrentLocation,
            ),
          ],
        ),

        if (_locationFetched)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  l10n.locationDetectedSuccessfully,
                  style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Phone Number Field (Primary Key for Survey)
        TextFormField(
          initialValue: widget.pageData['phone_number'],
          decoration: InputDecoration(
            labelText: 'Phone Number (Required)',
            hintText: 'Enter 10-digit phone number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          maxLength: 10,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Phone number is required';
            }
            if (value.length != 10) {
              return 'Phone number must be 10 digits';
            }
            return null;
          },
          onChanged: (value) {
            widget.pageData['phone_number'] = value;
            widget.onDataChanged(widget.pageData);
          },
        ),

        const SizedBox(height: 16),

        TextFormField(
          initialValue: widget.pageData['village_name'],
          decoration: InputDecoration(
            labelText: l10n.villageName,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            widget.pageData['village_name'] = value;
            widget.onDataChanged(widget.pageData);
          },
        ),

        const SizedBox(height: 16),

        TextFormField(
          initialValue: widget.pageData['panchayat'],
          decoration: InputDecoration(
            labelText: l10n.panchayat,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            widget.pageData['panchayat'] = value;
            widget.onDataChanged(widget.pageData);
          },
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: widget.pageData['block'],
                decoration: InputDecoration(
                  labelText: l10n.block,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  widget.pageData['block'] = value;
                  widget.onDataChanged(widget.pageData);
                },
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: TextFormField(
                initialValue: widget.pageData['district'],
                decoration: InputDecoration(
                  labelText: l10n.district,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  widget.pageData['district'] = value;
                  widget.onDataChanged(widget.pageData);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        TextFormField(
          initialValue: widget.pageData['postal_address'],
          decoration: InputDecoration(
            labelText: l10n.postalAddress,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 3,
          onChanged: (value) {
            widget.pageData['postal_address'] = value;
            widget.onDataChanged(widget.pageData);
          },
        ),

        const SizedBox(height: 16),

        TextFormField(
          initialValue: widget.pageData['pin_code'],
          decoration: InputDecoration(
            labelText: l10n.pinCode,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            widget.pageData['pin_code'] = value;
            widget.onDataChanged(widget.pageData);
          },
        ),
      ],
    );
  }
}
