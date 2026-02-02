import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/font_size_provider.dart';
import '../../../providers/survey_provider.dart';
import '../pages/animals_page.dart';
import '../pages/children_page.dart';
import '../pages/crop_productivity_page.dart';
import '../pages/equipment_page.dart';
import '../pages/family_details_page.dart';
import '../pages/fertilizer_page.dart';
import '../pages/house_conditions_page.dart';
import '../pages/irrigation_page.dart';
import '../pages/land_holding_page.dart';
import '../pages/location_page.dart';
import '../pages/social_consciousness_page_1.dart';
import '../pages/social_consciousness_page_2.dart';
import '../pages/social_consciousness_page_3.dart';
import '../pages/government_schemes_page.dart';
import '../pages/entertainment_page.dart';
import '../pages/transport_page.dart';
import '../pages/water_sources_page.dart';
import '../pages/medical_page.dart';
import '../pages/disputes_page.dart';
import '../pages/diseases_page.dart';
import '../pages/migration_page.dart';
import '../pages/training_page.dart';
import '../pages/final_page.dart';

class SurveyPage extends ConsumerStatefulWidget {
  final int pageIndex;
  final Function([Map<String, dynamic>?]) onNext;
  final VoidCallback? onPrevious;

  const SurveyPage({
    super.key,
    required this.pageIndex,
    required this.onNext,
    this.onPrevious,
  });

  @override
  ConsumerState<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends ConsumerState<SurveyPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _pageData = {};
  late double fontScale;

  @override
  void initState() {
    super.initState();
    fontScale = 0.7;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final surveyData = ref.read(surveyProvider).surveyData;
      if (surveyData.isNotEmpty) {
        setState(() {
          _pageData.addAll(surveyData);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    fontScale = ref.watch(fontSizeProvider);

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: FadeInUp(
                    child: _buildPageContent(widget.pageIndex, l10n, fontScale, ref),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (widget.onPrevious != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onPrevious,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.green),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.previous,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                      ),
                    if (widget.onPrevious != null) const SizedBox(width: 16),
                    Expanded(
                      flex: widget.onPrevious != null ? 2 : 1,
                      child: ElevatedButton(
                        onPressed: () => _handleNext(ref),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.pageIndex == 22 ? l10n.submit : l10n.next,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent(int pageIndex, AppLocalizations l10n, double fontScale, WidgetRef ref) {
    switch (pageIndex) {
      case 0:
        return LocationPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 1:
        return FamilyDetailsPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 2:
        return SocialConsciousnessPage1(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 3:
        return SocialConsciousnessPage2(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 4:
        return SocialConsciousnessPage3(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 5:
        return LandHoldingPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 6:
        return IrrigationPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 7:
        return CropProductivityPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 8:
        return FertilizerPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 9:
        return AnimalsPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 10:
        return EquipmentPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 11:
        return EntertainmentPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 12:
        return TransportPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 13:
        return WaterSourcesPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 14:
        return MedicalPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 15:
        return DisputesPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 16:
        return HouseConditionsPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 17:
        return DiseasesPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 18:
        return GovernmentSchemesPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 19:
        return ChildrenPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 20:
        return MigrationPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 21:
        return TrainingPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      case 22:
        return FinalPage(pageData: _pageData, onDataChanged: (data) => setState(() => _pageData.addAll(data)));
      default:
        return const Center(child: Text('Page not found'));
    }
  }



  Future<void> _handleNext(WidgetRef ref) async {
    _formKey.currentState?.save();
    widget.onNext(_pageData);
  }
}