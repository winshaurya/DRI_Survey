import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FontSizeNotifier extends Notifier<double> {
  @override
  double build() {
    return 0.7; // Default 30% smaller (0.7 scale)
  }

  void setFontSize(double scale) {
    state = scale.clamp(0.5, 1.5); // Limit between 50% and 150%
  }

  void resetToDefault() {
    state = 0.7;
  }
}

final fontSizeProvider = NotifierProvider<FontSizeNotifier, double>(() {
  return FontSizeNotifier();
});

// Extension to apply font size scaling to TextStyle
extension FontSizeExtension on TextStyle {
  TextStyle scaled(double scale) {
    return copyWith(fontSize: (fontSize ?? 14) * scale);
  }
}
