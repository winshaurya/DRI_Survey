import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import '../l10n/app_localizations.dart';

class ContextualHelp extends StatefulWidget {
  final String title;
  final String message;
  final Widget child;
  final HelpPosition position;
  final bool showHelp;
  final VoidCallback? onDismiss;
  final Duration autoHideDuration;

  const ContextualHelp({
    super.key,
    required this.title,
    required this.message,
    required this.child,
    this.position = HelpPosition.bottom,
    this.showHelp = true,
    this.onDismiss,
    this.autoHideDuration = const Duration(seconds: 5),
  });

  @override
  State<ContextualHelp> createState() => _ContextualHelpState();
}

enum HelpPosition {
  top,
  bottom,
  left,
  right,
}

class _ContextualHelpState extends State<ContextualHelp> {
  bool _showTooltip = false;
  Timer? _autoHideTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _showTooltip = widget.showHelp;
    if (widget.showHelp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          _showTooltipOverlay();
        }
      });
    }
  }

  @override
  void didUpdateWidget(ContextualHelp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showHelp != oldWidget.showHelp) {
      _showTooltip = widget.showHelp;
      if (widget.showHelp) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) {
            _showTooltipOverlay();
          }
        });
      } else {
        _hideTooltipOverlay();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _autoHideTimer?.cancel();
    _autoHideTimer = null;
    super.dispose();
  }

  void _showTooltipOverlay() {
    if (_isDisposed) return;
    
    _hideTooltipOverlay();

    setState(() => _showTooltip = true);

    // Start auto-hide timer
    _autoHideTimer = Timer(widget.autoHideDuration, () {
      if (!_isDisposed && mounted) {
        _hideTooltipOverlay();
      }
    });
  }

  void _hideTooltipOverlay() {
    _autoHideTimer?.cancel();
    _autoHideTimer = null;
    if (!_isDisposed && mounted) {
      setState(() => _showTooltip = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showTooltip) ...[
          // Backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideTooltipOverlay,
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          // Tooltip content
          Positioned(
            top: 100,
            left: 20,
            width: 300,
            child: SlideInUp(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.help_outline,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _hideTooltipOverlay,
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Message
                      Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Action button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _hideTooltipOverlay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Got it'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Inline help text with expandable details
class ExpandableHelp extends StatefulWidget {
  final String summary;
  final String details;
  final IconData icon;
  final Color color;

  const ExpandableHelp({
    super.key,
    required this.summary,
    required this.details,
    this.icon = Icons.help_outline,
    this.color = Colors.blue,
  });

  @override
  State<ExpandableHelp> createState() => _ExpandableHelpState();
}

class _ExpandableHelpState extends State<ExpandableHelp> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: widget.color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: widget.color.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () {
          setState(() => _isExpanded = !_isExpanded);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    widget.icon,
                    color: widget.color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.summary,
                      style: TextStyle(
                        color: widget.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: widget.color,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 8),
                Text(
                  widget.details,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Floating help button
class FloatingHelpButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;

  const FloatingHelpButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Help',
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: const Icon(Icons.help_outline),
    );
  }
}

// Survey progress with help
class SurveyProgressWithHelp extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String currentStepHelp;

  const SurveyProgressWithHelp({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.currentStepHelp,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = currentStep / totalSteps;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
            const SizedBox(height: 8),

            Text(
              'Step ${currentStep} of ${totalSteps}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            // Current step help
            ContextualHelp(
              title: 'Step Help',
              message: currentStepHelp,
              showHelp: true,
              child: Container(), // Empty child since we don't need it
            ),
          ],
        ),
      ),
    );
  }
}
