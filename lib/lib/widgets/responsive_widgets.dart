// widgets/responsive_widgets.dart
import 'package:flutter/material.dart';

// Responsive Text Widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final double? baseFontSize;
  
  const ResponsiveText(
    this.text, {
    this.style,
    this.textAlign,
    this.maxLines,
    this.baseFontSize,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    
    // Calculate responsive scale
    double scaleFactor;
    if (width < 400) {
      scaleFactor = 0.85;
    } else if (width < 600) scaleFactor = 1.0;
    else if (width < 900) scaleFactor = 1.15;
    else scaleFactor = 1.3;
    
    // If baseFontSize is provided, use it as base
    final baseSize = baseFontSize ?? style?.fontSize ?? 14;
    final scaledSize = baseSize * scaleFactor;
    
    return Text(
      text,
      style: (style ?? TextStyle()).copyWith(
        fontSize: scaledSize,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }
}

// Responsive Button
class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? baseFontSize;
  
  const ResponsiveButton({
    required this.text,
    required this.onPressed,
    this.baseFontSize,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    
    // Calculate responsive scale
    double scaleFactor;
    if (width < 400) {
      scaleFactor = 0.9;
    } else if (width < 600) scaleFactor = 1.0;
    else if (width < 900) scaleFactor = 1.1;
    else scaleFactor = 1.2;
    
    final buttonFontSize = (baseFontSize ?? 16) * scaleFactor;
    final horizontalPadding = 24 * scaleFactor;
    final verticalPadding = 16 * scaleFactor;
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, 
          vertical: verticalPadding,
        ),
        textStyle: TextStyle(
          fontSize: buttonFontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(text),
    );
  }
}