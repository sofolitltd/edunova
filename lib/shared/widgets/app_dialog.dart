import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// Confirm/alert dialog matching the admin dashboard's modal style —
/// rounded card, a title row with an X close button, a divider, body
/// text, and right-aligned Cancel/Confirm actions.
class AppDialog {
  AppDialog._();

  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'নিশ্চিত করুন',
    String cancelText = 'বাতিল',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: AppTextStyles.h3(ctx))),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(false),
                    child: Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondaryFor(ctx)),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.borderFor(ctx)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(message, style: AppTextStyles.bodyMedium(ctx)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(
                      cancelText,
                      style: AppTextStyles.bodyMedium(ctx).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: () => Navigator.of(ctx).pop(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                      decoration: BoxDecoration(
                        color: isDestructive ? AppColors.error : AppColors.primary,
                        borderRadius: AppRadius.medium,
                      ),
                      child: Text(
                        confirmText,
                        style: AppTextStyles.buttonMedium(ctx),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
