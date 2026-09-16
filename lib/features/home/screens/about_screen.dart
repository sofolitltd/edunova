import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      appBar: AppAppBar(title: l10n.about),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xxl),

            // ── App Logo ──────────────────────────
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: AppShadow.primary,
                ),
                child: const Center(
                  child: Text(
                    'E',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                l10n.appName,
                style: AppTextStyles.h1(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: Text(
                l10n.aboutSubtitle,
                style: AppTextStyles.bodyMedium(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'v1.0.0',
                  style: AppTextStyles.label(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Description ───────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceFor(context),
                borderRadius: AppRadius.medium,
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Text(
                l10n.aboutDescription,
                style: AppTextStyles.bodyLarge(context),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Features ──────────────────────────
            Text(l10n.keyFeatures, style: AppTextStyles.h3(context)),
            const SizedBox(height: AppSpacing.lg),
            _buildFeatureItem(
              context,
              icon: LucideIcons.bookOpen,
              title: l10n.feature1Title,
              subtitle: l10n.feature1Subtitle,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildFeatureItem(
              context,
              icon: LucideIcons.video,
              title: l10n.feature2Title,
              subtitle: l10n.feature2Subtitle,
              color: AppColors.success,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildFeatureItem(
              context,
              icon: LucideIcons.clipboardCheck,
              title: l10n.feature3Title,
              subtitle: l10n.feature3Subtitle,
              color: AppColors.warning,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildFeatureItem(
              context,
              icon: LucideIcons.barChart3,
              title: l10n.feature4Title,
              subtitle: l10n.feature4Subtitle,
              color: AppColors.accent,
            ),

            // ── Legal ─────────────────────────────
            const SizedBox(height: AppSpacing.xxl),
            Text(l10n.legal, style: AppTextStyles.h3(context)),
            const SizedBox(height: AppSpacing.lg),
            _buildLegalTile(
              context,
              icon: LucideIcons.fileText,
              title: l10n.termsOfService,
              onTap: () => context.push('/terms'),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildLegalTile(
              context,
              icon: LucideIcons.shield,
              title: l10n.privacyPolicy,
              onTap: () => context.push('/privacy'),
            ),
            const SizedBox(height: AppSpacing.xxxxxl),

            // ── Copyright ─────────────────────────
            Center(
              child: Text(
                '© 2026 ${l10n.appName}. ${l10n.allRightsReserved}',
                style: AppTextStyles.bodySmall(context),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.small,
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadius.small,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalTile(BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.small,
          border: Border.all(color: AppColors.borderFor(context)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge(context).copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: AppColors.textTertiaryFor(context),
            ),
          ],
        ),
      ),
    );
  }
}
