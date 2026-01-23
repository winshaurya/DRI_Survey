import 'package:flutter/material.dart';

class SnackbarUtils {
  static void showSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    Color? backgroundColor,
    Color? textColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: textColor ?? Colors.white,
                size: 20,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ],
        ),
        duration: duration,
        backgroundColor: backgroundColor ?? Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showErrorSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 6),
  }) {
    showSnackbar(
      context,
      message,
      duration: duration,
      backgroundColor: Colors.red,
    );
  }

  static void showSuccessSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    showSnackbar(
      context,
      message,
      duration: duration,
      backgroundColor: Colors.green,
    );
  }

  static void showInfoSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    showSnackbar(
      context,
      message,
      duration: duration,
      backgroundColor: Colors.blue,
    );
  }
}
