import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/logo_widget.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/survey_provider.dart';
import 'widgets/side_navigation.dart';
import 'widgets/survey_page.dart';
import 'widgets/survey_progress_indicator.dart';

class SurveyScreen extends ConsumerStatefulWidget {
  final String? previewSessionId;
  final String? continueSessionId;

  const SurveyScreen({super.key, this.previewSessionId, this.continueSessionId});

  @override
  ConsumerState<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends ConsumerState<SurveyScreen> {
  final PageController _pageController = PageController();
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    _initializeSurvey();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Handle route arguments here since context is now available
    if (!_isPreviewMode && widget.previewSessionId == null && widget.continueSessionId == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        if (args.containsKey('previewSessionId')) {
          _handlePreviewMode(args['previewSessionId']);
        } else if (args.containsKey('continueSessionId')) {
          final startPage = args['startPage'] is int ? args['startPage'] as int : 0;
          _handleContinueMode(args['continueSessionId'], startPage: startPage);
        }
      }
    }
  }

  Future<void> _initializeSurvey() async {
    final surveyNotifier = ref.read(surveyProvider.notifier);

    if (widget.previewSessionId != null) {
      // Preview mode - load existing session data
      _isPreviewMode = true;
      await surveyNotifier.loadSurveySessionForPreview(widget.previewSessionId!);
      // Navigate to final page (preview page)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.jumpToPage(surveyNotifier.state.totalPages - 1);
      });
    } else if (widget.continueSessionId != null) {
      // Continue mode - load existing session data for continuation
      await surveyNotifier.loadSurveySessionForContinuation(widget.continueSessionId!);
    }
    // Route arguments are now handled in didChangeDependencies
  }

  Future<void> _handlePreviewMode(String previewSessionId) async {
    final surveyNotifier = ref.read(surveyProvider.notifier);
    _isPreviewMode = true;
    await surveyNotifier.loadSurveySessionForPreview(previewSessionId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(surveyNotifier.state.totalPages - 1);
    });
  }

  Future<void> _handleContinueMode(String continueSessionId, {int startPage = 0}) async {
    final surveyNotifier = ref.read(surveyProvider.notifier);
    await surveyNotifier.loadSurveySessionForContinuation(continueSessionId, startPage: startPage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(startPage);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surveyState = ref.watch(surveyProvider);
    final surveyNotifier = ref.read(surveyProvider.notifier);

    // Page names for progress indicator
    const List<String> pageNames = [
      'Location',
      'Family',
      'Social 1',
      'Social 2',
      'Social 3',
      'Land',
      'Irrigation',
      'Crops',
      'Fertilizer',
      'Animals',
      'Equipment',
      'Entertainment',
      'Transport',
      'Water',
      'Medical',
      'Disputes',
      'House',
      'Diseases',
      'Schemes',
      'Medicine',
      'Health Prog',
      'Children',
      'Migration',
      'Training',
      'VB-G RAM-G',
      'PM Kisan Nidhi',
      'PM Kisan Samman',
      'Kisan CC',
      'Swachh',
      'Fasal Bima',
      'Bank',
      'Preview',
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        drawer: const SideNavigation(),
        body: Row(
          children: [
            // Progress indicator (sidebar on desktop, hidden on mobile)
            if (MediaQuery.of(context).size.width >= 600)
              SurveyProgressIndicator(
                currentPage: surveyState.currentPage,
                totalPages: surveyState.totalPages,
                onPageSelected: (i) => _jumpToPage(i),
                pageNames: pageNames,
              ),
            
            // Main content
            Expanded(
              child: Column(
                children: [
                  const AppHeader(),

                  // Mobile progress indicator
                  if (MediaQuery.of(context).size.width < 600)
                    SurveyProgressIndicator(
                      currentPage: surveyState.currentPage,
                      totalPages: surveyState.totalPages,
                      onPageSelected: (i) => _jumpToPage(i),
                      pageNames: pageNames,
                    ),

                  // Survey Pages
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: surveyState.totalPages,
                      itemBuilder: (context, index) {
                        return SurveyPage(
                          pageIndex: index,
                          onNext: ([Map<String, dynamic>? pageData]) async {
                            // Update survey data with current page data
                            if (pageData != null) {
                              surveyNotifier.updateSurveyDataMap(pageData);
                            }
                            if (index < surveyState.totalPages - 1) {
                              // Constraints disabled: always allow next page
                              if (index == 0) {
                                final phoneNumber =
                                    (pageData?['phone_number'] ?? '').toString().trim();
                                if (phoneNumber.isEmpty) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Phone number is required to start the survey.')),
                                  );
                                  return;
                                }
                                await surveyNotifier.initializeSurvey(
                                  villageName: pageData?['village_name'] ?? '',
                                  villageNumber: pageData?['village_number'],
                                  panchayat: pageData?['panchayat'],
                                  block: pageData?['block'],
                                  tehsil: pageData?['tehsil'],
                                  district: pageData?['district'],
                                  postalAddress: pageData?['postal_address'],
                                  pinCode: pageData?['pin_code'],
                                  surveyorName: pageData?['surveyor_name'],
                                  phoneNumber: phoneNumber,
                                );

                                // Extra-safety: ensure the freshly initialized session is persisted immediately
                                await surveyNotifier.saveCurrentPageData();
                              }
                              // Jump (centralized save + navigation)
                              await _jumpToPage(index + 1);
                            } else {
                              // Complete survey
                              _showCompletionDialog();
                            }
                          },
                          onPrevious: index > 0
                              ? () async {
                                  await _jumpToPage(index - 1);
                                }
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final surveyState = ref.read(surveyProvider);
    final surveyNotifier = ref.read(surveyProvider.notifier);

    // If survey is not started (no data entered), allow exit without prompt
    if (surveyState.currentPage == 0 && surveyState.surveyData.isEmpty) {
      return true;
    }

    // Show confirmation dialog
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Survey'),
        content: const Text(
          'You have unsaved progress. Would you like to save your current survey before leaving?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Don't exit
            child: const Text('Continue Survey'),
          ),
          TextButton(
            onPressed: () async {
              // Save current survey data
              await surveyNotifier.saveCurrentPageData();
              Navigator.of(context).pop(true); // Exit after saving
            },
            child: const Text('Save & Exit'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Exit without saving
            child: const Text('Exit Without Saving'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _jumpToPage(int pageIndex) async {
    final surveyNotifier = ref.read(surveyProvider.notifier);

    if (pageIndex < 0 || pageIndex >= surveyNotifier.state.totalPages) return;

    // Always save current page data before navigating (await per your preference)
    await surveyNotifier.saveCurrentPageData();

    // Jump the PageView (instant) and keep provider state in sync
    _pageController.jumpToPage(pageIndex);
    surveyNotifier.jumpToPage(pageIndex);

    // Load data for target page after navigation
    await surveyNotifier.loadPageData(pageIndex);
  }

  void _showCompletionDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final surveyNotifier = ref.read(surveyProvider.notifier);

    // Complete the survey
    await surveyNotifier.completeSurvey();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.surveyCompleted),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text('Thank you for completing the family survey!'),
            const SizedBox(height: 8),
            Text(
              'Your responses have been saved locally.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate back to landing page
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text('Return to Home'),
          ),
        ],
      ),
    );
  }

  bool _validatePageConstraints(int pageIndex, [Map<String, dynamic>? pageData]) {
    final surveyData = ref.read(surveyProvider).surveyData;
    final dataToCheck = pageData ?? surveyData;

    switch (pageIndex) {
      case 0: // Location - phone number is optional
        return true;

      case 1: // Family Details - optional
        return true;

      case 2: // Social Consciousness 3a - at least one question answered
        return (surveyData['clothes_frequency']?.isNotEmpty ?? false) ||
               (surveyData['food_waste']?.isNotEmpty ?? false) ||
               (surveyData['waste_segregation']?.isNotEmpty ?? false);

      case 3: // Social Consciousness 3b - optional for now
        return true;

      case 4: // Social Consciousness 3c - optional for now
        return true;

      case 5: // Land Holding - at least one field should be filled
        return (surveyData['irrigated_area']?.isNotEmpty ?? false) ||
               (surveyData['cultivable_area']?.isNotEmpty ?? false);

      case 6: // Irrigation - at least one source selected
        return (surveyData['canal'] == true) ||
               (surveyData['tube_well'] == true) ||
               (surveyData['ponds'] == true) ||
               (surveyData['other_facilities'] == true);

      case 7: // Crop Productivity - at least one crop defined
        return surveyData['crop_1_name']?.isNotEmpty ?? false;

      case 8: // Fertilizer - at least one type selected
        return (surveyData['urea_fertilizer'] == true) ||
               (surveyData['organic_fertilizer'] == true);

      case 9: // Animals - at least one animal if any livestock
        return surveyData['animal_1_type']?.isNotEmpty ?? true; // Optional

      case 10: // Equipment - at least one equipment selected
        return (surveyData['tractor'] == true) ||
               (surveyData['thresher'] == true) ||
               (surveyData['seed_drill'] == true) ||
               (surveyData['sprayer'] == true) ||
               (surveyData['duster'] == true) ||
               (surveyData['diesel_engine'] == true);

      case 11: // Entertainment - at least one facility
        return (surveyData['smart_mobile'] == true) ||
               (surveyData['analog_mobile'] == true) ||
               (surveyData['television'] == true) ||
               (surveyData['radio'] == true) ||
               (surveyData['games'] == true);

      case 12: // Transport - at least one facility
        return (surveyData['car_jeep'] == true) ||
               (surveyData['motorcycle_scooter'] == true) ||
               (surveyData['e_rickshaw'] == true) ||
               (surveyData['cycle'] == true) ||
               (surveyData['pickup_truck'] == true) ||
               (surveyData['bullock_cart'] == true);

      case 13: // Water Sources - at least one source
        return (surveyData['hand_pumps'] == true) ||
               (surveyData['well'] == true) ||
               (surveyData['tubewell'] == true) ||
               (surveyData['nal_jaal'] == true);

      case 14: // Medical - at least one treatment type
        return (surveyData['allopathic'] == true) ||
               (surveyData['ayurvedic'] == true) ||
               (surveyData['homeopathy'] == true) ||
               (surveyData['traditional'] == true) ||
               (surveyData['jhad_phook'] == true);

      case 15: // Disputes - optional
        return true;

      case 16: // House Conditions - at least one house type
        return (surveyData['katcha_house'] == true) ||
               (surveyData['pakka_house'] == true) ||
               (surveyData['katcha_pakka_house'] == true) ||
               (surveyData['hut_house'] == true);

      case 17: // Diseases - optional
        return true;

      case 18: // Government Schemes - at least Aadhaar checked
        return surveyData['aadhaar_have_card'] != null;

      case 19: // Children - basic info provided
        return surveyData['births_last_3_years'] != null ||
               surveyData['infant_deaths_last_3_years'] != null;

      case 20: // Migration - optional
        return true;

      case 21: // Training - optional
        return true;

      case 22: // Final page - always valid
        return true;

      default:
        return true;
    }
  }

  String _getCurrentPageTitle(int pageIndex) {
    final l10n = AppLocalizations.of(context)!;

    switch (pageIndex) {
      case 0:
        return 'Location Information';
      case 1:
        return 'Family Details';
      case 2:
        return 'Social Consciousness (Part 1)';
      case 3:
        return 'Social Consciousness (Part 2)';
      case 4:
        return 'Social Consciousness (Part 3)';
      case 5:
        return 'Land Holding';
      case 6:
        return 'Irrigation Facilities';
      case 7:
        return 'Crop Productivity';
      case 8:
        return 'Fertilizer Usage';
      case 9:
        return 'Livestock & Animals';
      case 10:
        return 'Agricultural Equipment';
      case 11:
        return 'Entertainment Facilities';
      case 12:
        return 'Transport Facilities';
      case 13:
        return 'Drinking Water Sources';
      case 14:
        return 'Medical Treatment';
      case 15:
        return 'Disputes & Legal Issues';
      case 16:
        return 'House Conditions';
      case 17:
        return 'Health & Diseases';
      case 18:
        return 'Government Schemes';
      case 19:
        return 'Children & Education';
      case 20:
        return 'Migration';
      case 21:
        return 'Training & Skills';
      case 22:
        return 'Survey Summary';
      default:
        return 'Survey Page ${pageIndex + 1}';
    }
  }

  Future<void> _navigateToPage(int pageIndex) async {
    final surveyNotifier = ref.read(surveyProvider.notifier);
    final currentPage = ref.read(surveyProvider).currentPage;

    if (pageIndex == currentPage) return;

    // Save current page data and wait for completion before navigating
    await surveyNotifier.saveCurrentPageData();

    // Animate the PageView to the target page and ensure provider state stays in sync
    await _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Update provider to reflect the new page index (single authoritative call)
    surveyNotifier.jumpToPage(pageIndex);

    // Load data for the new page
    await surveyNotifier.loadPageData(pageIndex);
  }

  void _showConstraintError(int pageIndex) {
    final l10n = AppLocalizations.of(context)!;
    String errorMessage = 'Please complete the required fields before proceeding.';

    switch (pageIndex) {
      case 0:
        errorMessage = 'Please enter the phone number to continue.';
        break;
      case 1:
        errorMessage = 'Please provide head of family details (name, age, and gender).';
        break;
      case 2:
        errorMessage = 'Please answer at least one social consciousness question.';
        break;
      case 3:
        errorMessage = 'Please provide land holding information.';
        break;
      case 4:
        errorMessage = 'Please select at least one irrigation facility.';
        break;
      case 5:
        errorMessage = 'Please provide crop productivity information.';
        break;
      case 6:
        errorMessage = 'Please select fertilizer usage type.';
        break;
      case 8:
        errorMessage = 'Please select agricultural equipment owned.';
        break;
      case 9:
        errorMessage = 'Please select entertainment facilities available.';
        break;
      case 10:
        errorMessage = 'Please select transport facilities available.';
        break;
      case 11:
        errorMessage = 'Please select drinking water sources.';
        break;
      case 12:
        errorMessage = 'Please select medical treatment options.';
        break;
      case 14:
        errorMessage = 'Please select house type.';
        break;
      case 16:
        errorMessage = 'Please check Aadhaar card status.';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
