import 'package:flutter/material.dart';

import 'app_colors.dart';

class DialogUtils {
  static void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary3,
        ),
      ),
    );
  }

  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }

  static void showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
