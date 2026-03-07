import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../components/logo_widget.dart';
import '../../providers/survey_provider.dart';
import '../../services/sync_service.dart';
import '../../services/supabase_service.dart';
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
        _pageController.jumpToPage(ref.read(surveyProvider).totalPages - 1);
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
      _pageController.jumpToPage(ref.read(surveyProvider).totalPages - 1);
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
                            debugPrint('[SurveyScreen] onNext called for index $index; pageData keys=${pageData?.keys}');
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

                                // 1. create minimal remote session
                                final online = await SupabaseService.instance.isOnline();
                                if (!online && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Offline – session will sync when network is available.')),
                                  );
                                }
                                final success = await SupabaseService.instance.ensureFamilySessionExists(phoneNumber);
                                debugPrint('[SurveyScreen] ensureFamilySessionExists returned $success for $phoneNumber');
                                if (mounted) {
                                  if (success && online) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Remote session created')),
                                    );
                                  } else if (!success && online) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Attempted to create remote session but it may have failed. Check logs.'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                }

                                // 2. initialize locally and save page0 fields
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
                                await surveyNotifier.saveCurrentPageData();

                                // 3. update remote session with full page0 data
                                try {
                                  final upd = Map<String, dynamic>.from(pageData!);
                                  upd['phone_number'] = phoneNumber;
                                  await SupabaseService.instance.saveFamilyData(
                                    'family_survey_sessions',
                                    upd,
                                  );
                                  debugPrint('[SurveyScreen] updated remote session data for $phoneNumber');
                                } catch (e) {
                                  debugPrint('[SurveyScreen] failed remote session update: $e');
                                }

                                // now perform lightweight page-0 sync as before
                                try {
                                  SyncService.instance
                                      .syncFamilyPageData(phoneNumber, 0, pageData ?? {})
                                      .timeout(const Duration(seconds: 6));
                                } catch (e) {
                                  debugPrint('Failed to start background family sync: $e');
                                }

                                // fire‑and‑forget a lightweight page‑0 sync to Supabase so that a
                                // session row exists remotely as soon as possible, matching the
                                // village survey pattern (timeout prevents long delays).
                                try {
                                  // kick off a background page‑0 sync to Supabase; we intentionally
                                  // ignore the returned future so it runs fire‑and‑forget
                                  SyncService.instance
                                      .syncFamilyPageData(phoneNumber, 0, pageData!)
                                      .timeout(const Duration(seconds: 6));
                                } catch (e) {
                                  debugPrint('Failed to start background family sync: $e');
                                }
                              }
                              // Jump (centralized save + navigation)
                              await _jumpToPage(index + 1);
                            } else {
                              // Complete survey
                              _showCompletionDialog();

                              // final full sync in case any page-level ops failed or
                              // additional tables were added later; this is fire-and-forget
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final phoneNumber = (pageData?['phone_number'] ?? '').toString().trim();
                                if (phoneNumber.isNotEmpty) {
                                  SyncService.instance.syncFamilySurveyToSupabase(phoneNumber);
                                }
                              });
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
                  // SurveyNavigationBar removed
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

    final total = ref.read(surveyProvider).totalPages;
    if (pageIndex < 0 || pageIndex >= total) return;

    // Before moving off the current page we save its contents exactly once.
    // saveCurrentPageData awaits local DB persistence and starts cloud sync in
    // background, so awaiting here keeps navigation consistent and safe.
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

}
