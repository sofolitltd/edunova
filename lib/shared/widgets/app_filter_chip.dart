import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// Horizontal filter/tab pill — a full pill shape, solid primary fill
/// with white text when active, soft lavender fill with a thin primary
/// border and primary-tinted text otherwise.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedFill = isDark ? AppColors.darkSurfaceElevated : AppColors.primarySurface;
    final unselectedBorder = AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.25);
    final unselectedText = isDark ? AppColors.primaryLight : AppColors.primaryDark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : unselectedFill,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: isSelected ? null : Border.all(color: unselectedBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : unselectedText,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.label(context).copyWith(
                color: isSelected ? Colors.white : unselectedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
