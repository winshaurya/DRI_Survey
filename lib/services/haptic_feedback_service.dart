import 'package:flutter/services.dart';

class HapticFeedbackService {
  static const HapticFeedbackService _instance = HapticFeedbackService._internal();

  const HapticFeedbackService._internal();

  factory HapticFeedbackService() {
    return _instance;
  }

  // Light feedback for minor interactions (checkbox toggle, button press)
  Future<void> lightImpact() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Silently fail on platforms that don't support haptic feedback
    }
  }

  // Medium feedback for important actions (form submission, navigation)
  Future<void> mediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Silently fail on platforms that don't support haptic feedback
    }
  }

  // Heavy feedback for significant actions (error states, completion)
  Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Silently fail on platforms that don't support haptic feedback
    }
  }

  // Selection feedback for picker interactions
  Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Silently fail on platforms that don't support haptic feedback
    }
  }

  // Vibrate for errors or warnings
  Future<void> vibrate() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      // Silently fail on platforms that don't support haptic feedback
    }
  }

  // Success feedback - combination of light impact and selection
  Future<void> success() async {
    try {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Silently fail on platforms that don't support haptic feedback
    }
  }

  // Error feedback - heavy impact followed by vibrate
  Future<void> error() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.vibrate();
    } catch (e) {
      // Silently fail on platforms that don't support haptic feedback
    }
  }

  // Navigation feedback for page transitions
  Future<void> navigation() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Silently fail on platforms that don't support haptic feedback
    }
  }

  // Form validation feedback
  Future<void> validationSuccess() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Silently fail on platforms that don't support haptic feedback
    }
  }

  Future<void> validationError() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      // Silently fail on platforms that don't support haptic feedback
    }
  }

  // Data save feedback
  Future<void> dataSaved() async {
    try {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Silently fail on platforms that don't support haptic feedback
    }
  }
}
