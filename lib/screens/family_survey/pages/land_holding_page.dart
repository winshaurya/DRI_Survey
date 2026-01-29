import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';


class LandHoldingPage extends ConsumerWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;

  const LandHoldingPage({
    super.key,
    required this.pageData,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return LandHoldingPageContent(
      pageData: pageData,
      onDataChanged: onDataChanged,
      l10n: l10n,
    );
  }
}

class LandHoldingPageContent extends StatefulWidget {
  final Map<String, dynamic> pageData;
  final Function(Map<String, dynamic>) onDataChanged;
  final AppLocalizations l10n;

  const LandHoldingPageContent({
    super.key,
    required this.pageData,
    required this.onDataChanged,
    required this.l10n,
  });

  @override
  State<LandHoldingPageContent> createState() => _LandHoldingPageContentState();
}

class _LandHoldingPageContentState extends State<LandHoldingPageContent> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _irrigatedController;
  late TextEditingController _cultivableController;
  late TextEditingController _orchardController;

  @override
  void initState() {
    super.initState();
    _irrigatedController = TextEditingController(
      text: widget.pageData['irrigated_area'] ?? '',
    );
    _cultivableController = TextEditingController(
      text: widget.pageData['cultivable_area'] ?? '',
    );
    _orchardController = TextEditingController(
      text: widget.pageData['orchard_plants'] ?? '',
    );
  }

  @override
  void dispose() {
    _irrigatedController.dispose();
    _cultivableController.dispose();
    _orchardController.dispose();
    super.dispose();
  }

  void _updateData() {
    final data = {
      'irrigated_area': _irrigatedController.text,
      'cultivable_area': _cultivableController.text,
      'orchard_plants': _orchardController.text,
    };
    widget.onDataChanged(data);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text(
                l10n.landHoldingInformation,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
              ),
            ),
            const SizedBox(height: 24),

            // Irrigated Area
            FadeInLeft(
              delay: const Duration(milliseconds: 100),
              child: TextFormField(
                controller: _irrigatedController,
                decoration: InputDecoration(
                  labelText: l10n.totalIrrigatedArea,
                  hintText: l10n.enterAreaInAcres,
                  prefixIcon: const Icon(Icons.water_drop, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (value) => _updateData(),
              ),
            ),
            const SizedBox(height: 20),

            // Cultivable Area
            FadeInLeft(
              delay: const Duration(milliseconds: 200),
              child: TextFormField(
                controller: _cultivableController,
                decoration: InputDecoration(
                  labelText: l10n.totalCultivableArea,
                  hintText: l10n.enterAreaInAcres,
                  prefixIcon: const Icon(Icons.agriculture, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (value) => _updateData(),
              ),
            ),
            const SizedBox(height: 20),

            // Orchard Plants
            FadeInLeft(
              delay: const Duration(milliseconds: 300),
              child: TextFormField(
                controller: _orchardController,
                decoration: InputDecoration(
                  labelText: l10n.orchardPlantsIfAny,
                  hintText: l10n.orchardPlantsExample,
                  prefixIcon: const Icon(Icons.park, color: Colors.orange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                ),
                maxLines: 3,
                onChanged: (value) => _updateData(),
              ),
            ),
            const SizedBox(height: 16),

            // Information Text
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.landMeasurementInfo,
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
