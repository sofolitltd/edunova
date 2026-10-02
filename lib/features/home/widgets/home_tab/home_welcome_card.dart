import 'package:flutter/material.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/services/auth_service.dart' show User;

/// Welcome banner shown at the top of the home tab: greeting, class/school,
/// streak + results status pills, notification/theme buttons and a search bar.
class HomeWelcomeCard extends StatelessWidget {
  const HomeWelcomeCard({
    super.key,
    required this.l10n,
    required this.isDark,
    required this.user,
    required this.firstName,
    required this.streak,
    required this.overallPercent,
    required this.hasResults,
    required this.unreadNotificationCount,
    required this.onSearchTap,
    required this.onNotificationsTap,
    required this.onThemeToggle,
    required this.onStreakTap,
    required this.onResultsTap,
  });

  final AppLocalizations l10n;
  final bool isDark;
  final User? user;
  final String firstName;
  final int streak;
  final double overallPercent;
  final bool hasResults;
  final int unreadNotificationCount;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onThemeToggle;
  final VoidCallback onStreakTap;
  final VoidCallback onResultsTap;

  @override
  Widget build(BuildContext context) {
    final fullName = (user?.fullName ?? '').trim();
    final initial = fullName.isNotEmpty ? fullName.characters.first.toUpperCase() : '?';
    final classLabel = (user?.studentClass ?? '').isNotEmpty ? 'Class ${user!.studentClass}' : '';
    final school = user?.school ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.extraLarge,
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppShadow.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySurfaceFor(context),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: AppTextStyles.h3(context).copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstName.isNotEmpty ? 'স্বাগতম, $firstName' : l10n.homeSubtitle,
                      style: AppTextStyles.h3(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (classLabel.isNotEmpty || school.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        [classLabel, school].where((s) => s.isNotEmpty).join(' • '),
                        style: AppTextStyles.bodySmall(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _HeaderIconButton(
                icon: Icons.notifications_outlined,
                badgeCount: unreadNotificationCount,
                onTap: onNotificationsTap,
              ),
              const SizedBox(width: AppSpacing.xs),
              _HeaderIconButton(
                icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                onTap: onThemeToggle,
              ),
            ],
          ),
          if (streak > 0 || hasResults) ...[
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (streak > 0) ...[
                    _StatusPill(
                      emoji: '🔥',
                      label: '$streak দিন স্ট্রিক',
                      onTap: onStreakTap,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  if (hasResults)
                    _StatusPill(
                      icon: Icons.emoji_events_rounded,
                      label: '${overallPercent.toStringAsFixed(0)}% গড় ফলাফল',
                      color: AppColors.primary,
                      onTap: onResultsTap,
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: onSearchTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.backgroundFor(context),
                borderRadius: AppRadius.medium,
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 20, color: AppColors.textTertiaryFor(context)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.searchCourses,
                    style: AppTextStyles.bodyMedium(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    this.badgeCount = 0,
    required this.onTap,
  });

  final IconData icon;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.backgroundFor(context),
          shape: BoxShape.circle,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(child: Icon(icon, size: 20, color: AppColors.textSecondaryFor(context))),
            if (badgeCount > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surfaceFor(context), width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    this.emoji,
    this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  final String? emoji;
  final IconData? icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pillColor = color ?? AppColors.textSecondaryFor(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: pillColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) Text(emoji!, style: const TextStyle(fontSize: 13)),
            if (icon != null) Icon(icon, size: 14, color: pillColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyles.label(context).copyWith(
                color: pillColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
