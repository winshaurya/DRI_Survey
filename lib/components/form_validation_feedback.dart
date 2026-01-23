import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

enum ValidationState { none, success, warning, error }

class FormValidationFeedback extends StatelessWidget {
  final ValidationState state;
  final String? message;
  final IconData? icon;
  final bool showAnimation;

  const FormValidationFeedback({
    super.key,
    this.state = ValidationState.none,
    this.message,
    this.icon,
    this.showAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    if (state == ValidationState.none || message == null) {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData displayIcon;

    switch (state) {
      case ValidationState.success:
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green.shade200;
        textColor = Colors.green.shade700;
        displayIcon = icon ?? Icons.check_circle;
        break;
      case ValidationState.warning:
        backgroundColor = Colors.orange.shade50;
        borderColor = Colors.orange.shade200;
        textColor = Colors.orange.shade700;
        displayIcon = icon ?? Icons.warning;
        break;
      case ValidationState.error:
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red.shade200;
        textColor = Colors.red.shade700;
        displayIcon = icon ?? Icons.error;
        break;
      default:
        return const SizedBox.shrink();
    }

    Widget feedbackWidget = Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            displayIcon,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message!,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );

    if (showAnimation) {
      return FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: feedbackWidget,
      );
    }

    return feedbackWidget;
  }
}

// Enhanced TextField with validation feedback
class ValidatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final TextInputType keyboardType;
  final int? maxLength;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool enabled;
  final int? maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const ValidatedTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  ValidationState _validationState = ValidationState.none;
  String? _validationMessage;
  bool _hasBeenEdited = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (_hasBeenEdited && widget.validator != null) {
      _validateInput(widget.controller.text);
    }
    widget.onChanged?.call(widget.controller.text);
  }

  void _validateInput(String value) {
    final error = widget.validator?.call(value);
    setState(() {
      if (error != null) {
        _validationState = ValidationState.error;
        _validationMessage = error;
      } else if (value.isNotEmpty) {
        _validationState = ValidationState.success;
        _validationMessage = null;
      } else {
        _validationState = ValidationState.none;
        _validationMessage = null;
      }
    });
  }

  void _onFocusLost() {
    if (!_hasBeenEdited) {
      setState(() => _hasBeenEdited = true);
    }
    if (widget.validator != null) {
      _validateInput(widget.controller.text);
    }
  }

  Color _getBorderColor() {
    switch (_validationState) {
      case ValidationState.success:
        return Colors.green;
      case ValidationState.error:
        return Colors.red;
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              _onFocusLost();
            }
          },
          child: TextField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            maxLength: widget.maxLength,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widget.suffixIcon!,
                        if (_validationState == ValidationState.success)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          )
                        else if (_validationState == ValidationState.error)
                          const Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 20,
                          ),
                      ],
                    )
                  : (_validationState == ValidationState.success
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        )
                      : _validationState == ValidationState.error
                          ? const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 20,
                            )
                          : null),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _getBorderColor(),
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _getBorderColor(),
                  width: 1,
                ),
              ),
              filled: true,
              fillColor: widget.enabled
                  ? Colors.white
                  : Colors.grey.shade100,
            ),
          ),
        ),
        FormValidationFeedback(
          state: _validationState,
          message: _validationMessage,
          showAnimation: false,
        ),
      ],
    );
  }
}
