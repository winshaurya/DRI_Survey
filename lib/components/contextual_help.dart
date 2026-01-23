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
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.showHelp) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTooltipOverlay();
      });
    }
  }

  @override
  void didUpdateWidget(ContextualHelp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showHelp != oldWidget.showHelp) {
      if (widget.showHelp) {
        _showTooltipOverlay();
      } else {
        _hideTooltipOverlay();
      }
    }
  }

  @override
  void dispose() {
    _hideTooltipOverlay();
    super.dispose();
  }

  void _showTooltipOverlay() {
    _hideTooltipOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => _TooltipOverlay(
        title: widget.title,
        message: widget.message,
        position: widget.position,
        targetContext: context,
        onDismiss: () {
          _hideTooltipOverlay();
          widget.onDismiss?.call();
        },
        autoHideDuration: widget.autoHideDuration,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _showTooltip = true);
  }

  void _hideTooltipOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _showTooltip = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showTooltip)
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideTooltipOverlay,
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),
      ],
    );
  }
}

class _TooltipOverlay extends StatefulWidget {
  final String title;
  final String message;
  final HelpPosition position;
  final BuildContext targetContext;
  final VoidCallback onDismiss;
  final Duration autoHideDuration;

  const _TooltipOverlay({
    required this.title,
    required this.message,
    required this.position,
    required this.targetContext,
    required this.onDismiss,
    required this.autoHideDuration,
  });

  @override
  State<_TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<_TooltipOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Auto-hide after duration
    Future.delayed(widget.autoHideDuration, () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FadeTransition(
      opacity: _animation,
      child: Stack(
        children: [
          // Semi-transparent overlay
          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          // Tooltip content
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: 20,
            right: 20,
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
                            onPressed: widget.onDismiss,
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
                          onPressed: widget.onDismiss,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(l10n.gotIt),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
    final l10n = AppLocalizations.of(context)!;
    return FloatingActionButton.small(
      onPressed: onPressed,
      backgroundColor: Colors.blue.shade600,
      foregroundColor: Colors.white,
      tooltip: l10n.help,
      child: const Icon(Icons.help_outline, size: 20),
    );
  }
}

// Progress indicator with help
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.stepOfTotal(currentStep.toString(), totalSteps.toString()),
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.blue.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            currentStepHelp,
            style: TextStyle(
              color: Colors.blue.shade600,
              fontSize: 12,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
