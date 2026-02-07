import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../providers/survey_provider.dart';

class SurveyNavigationBar extends ConsumerStatefulWidget {
  final int currentPageIndex;
  final int totalPages;
  final Function(int)? onPageChange;
  final bool isLastPage;

  const SurveyNavigationBar({
    super.key,
    required this.currentPageIndex,
    required this.totalPages,
    this.onPageChange,
    this.isLastPage = false,
  });

  @override
  ConsumerState<SurveyNavigationBar> createState() => _SurveyNavigationBarState();
}

class _SurveyNavigationBarState extends ConsumerState<SurveyNavigationBar> {
  bool _isNavigating = false;

  Future<void> _handlePrevious() async {
    if (_isNavigating || widget.currentPageIndex <= 0) return;

    setState(() => _isNavigating = true);

    try {
      final surveyNotifier = ref.read(surveyProvider.notifier);

      // Save current page data before navigating
      await surveyNotifier.saveCurrentPageData();

      // Navigate to previous page
      final newPageIndex = widget.currentPageIndex - 1;
      widget.onPageChange?.call(newPageIndex);

      // Load data for the target page
      await surveyNotifier.loadPageData(newPageIndex);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error navigating: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isNavigating = false);
      }
    }
  }

  Future<void> _handleNext() async {
    if (_isNavigating) return;

    setState(() => _isNavigating = true);

    try {
      final surveyNotifier = ref.read(surveyProvider.notifier);

      // Save current page data
      await surveyNotifier.saveCurrentPageData();

      if (widget.isLastPage) {
        // Complete survey
        await surveyNotifier.completeSurvey();
        _showCompletionDialog();
      } else {
        // Navigate to next page
        final newPageIndex = widget.currentPageIndex + 1;
        widget.onPageChange?.call(newPageIndex);

        // Load data for the target page
        await surveyNotifier.loadPageData(newPageIndex);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error navigating: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isNavigating = false);
      }
    }
  }

  Future<bool> _validateCurrentPage() async {
    // Basic validation - can be enhanced based on page requirements
    final surveyState = ref.read(surveyProvider);

    // For location page (index 0), require basic info
    if (widget.currentPageIndex == 0) {
      final requiredFields = ['village_name', 'phone_number'];
      for (final field in requiredFields) {
        if (surveyState.surveyData[field]?.toString().isEmpty ?? true) {
          return false;
        }
      }
    }

    return true;
  }

  void _showCompletionDialog() {
    final l10n = AppLocalizations.of(context)!;

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
            const Text('Thank you for completing the family survey!'),
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
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: const Text('Return to Home'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surveyState = ref.watch(surveyProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
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
      child: SafeArea(
        top: false, // Don't add padding to top since we're at bottom
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 8 : 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress indicator
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (widget.currentPageIndex + 1) / widget.totalPages,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isLastPage ? Colors.green : Colors.blue,
                  ),
                  minHeight: isSmallScreen ? 4 : 6,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),

              // Main navigation row
              Row(
                children: [
                  // Previous Button
                  if (widget.currentPageIndex > 0)
                    Expanded(
                      flex: isSmallScreen ? 1 : 1,
                      child: SizedBox(
                        height: isSmallScreen ? 44 : 52,
                        child: OutlinedButton.icon(
                          onPressed: _isNavigating ? null : _handlePrevious,
                          icon: _isNavigating
                              ? SizedBox(
                                  width: isSmallScreen ? 16 : 20,
                                  height: isSmallScreen ? 16 : 20,
                                  child: const CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(Icons.arrow_back, size: isSmallScreen ? 18 : 20),
                          label: Text(
                            l10n.previous,
                            style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 8 : 16,
                              vertical: isSmallScreen ? 8 : 12,
                            ),
                            side: const BorderSide(color: Colors.green),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (widget.currentPageIndex > 0) SizedBox(width: isSmallScreen ? 8 : 16),

                  // Next/Submit Button
                  Expanded(
                    flex: widget.currentPageIndex == 0 ? 1 : (isSmallScreen ? 2 : 3),
                    child: SizedBox(
                      height: isSmallScreen ? 44 : 52,
                      child: ElevatedButton.icon(
                        onPressed: _isNavigating ? null : _handleNext,
                        icon: _isNavigating
                            ? SizedBox(
                                width: isSmallScreen ? 16 : 20,
                                height: isSmallScreen ? 16 : 20,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                widget.isLastPage ? Icons.check : Icons.arrow_forward,
                                size: isSmallScreen ? 18 : 20,
                              ),
                        label: Text(
                          widget.isLastPage ? l10n.submit : l10n.next,
                          style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8 : 16,
                            vertical: isSmallScreen ? 8 : 12,
                          ),
                          backgroundColor: widget.isLastPage ? Colors.green : Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Page indicator (only show on larger screens)
                  if (!isSmallScreen)
                    Container(
                      margin: const EdgeInsets.only(left: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Page number
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${widget.currentPageIndex + 1}/${widget.totalPages}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),

                          // Progress dots (limit to 10 dots max)
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              widget.totalPages > 10 ? 10 : widget.totalPages,
                              (index) {
                                // For surveys with more than 10 pages, show condensed view
                                if (widget.totalPages > 10) {
                                  if (index == 0) {
                                    // First dot
                                    return Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.symmetric(horizontal: 1),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: index <= widget.currentPageIndex ? Colors.blue : Colors.grey[300],
                                      ),
                                    );
                                  } else if (index == 9) {
                                    // Last dot
                                    return Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.symmetric(horizontal: 1),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: widget.currentPageIndex >= widget.totalPages - 1 ? Colors.green : Colors.grey[300],
                                      ),
                                    );
                                  } else if (index == 4) {
                                    // Middle indicator
                                    return Container(
                                      width: 12,
                                      height: 2,
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                } else {
                                  // Normal view for <= 10 pages
                                  return Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.symmetric(horizontal: 1),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: index <= widget.currentPageIndex
                                          ? (widget.isLastPage && index == widget.totalPages - 1
                                              ? Colors.green
                                              : Colors.blue)
                                          : Colors.grey[300],
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // Current page title hint (only show on larger screens)
              if (!isSmallScreen)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _getPageTitle(widget.currentPageIndex),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Compact page indicator for small screens
              if (isSmallScreen)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.currentPageIndex + 1}/${widget.totalPages}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getPageTitle(widget.currentPageIndex),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  String _getPageTitle(int pageIndex) {
    final titles = [
      'Location Information',
      'Family Details',
      'Social Consciousness 1',
      'Social Consciousness 2',
      'Social Consciousness 3',
      'Land Holding',
      'Irrigation',
      'Crop Productivity',
      'Fertilizer Usage',
      'Animals & Livestock',
      'Agricultural Equipment',
      'Entertainment',
      'Transportation',
      'Drinking Water',
      'Medical Treatment',
      'Disputes',
      'House Conditions',
      'Diseases',
      'Government Schemes',
      'Folklore Medicine',
      'Health Programme',
      'Children Data',
      'Migration',
      'Training',
      'VB Gram Beneficiary',
      'PM Kisan Nidhi',
      'PM Kisan Samman Nidhi',
      'Kisan Credit Card',
      'Swachh Bharat',
      'Fasal Bima',
      'Bank Accounts',
      'Survey Preview',
    ];

    if (pageIndex < titles.length) {
      return titles[pageIndex];
    }
    return 'Page ${pageIndex + 1}';
  }
}
