import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  int? _expandedFaq;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      appBar: AppAppBar(title: l10n.help),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xl),

            // ── Contact Cards ─────────────────────
            Text(l10n.contactUs, style: AppTextStyles.h3(context)),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _buildContactCard(
                    context,
                    icon: LucideIcons.phone,
                    title: l10n.callUs,
                    subtitle: '+880 1XXX-XXXXXX',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildContactCard(
                    context,
                    icon: LucideIcons.mail,
                    title: l10n.emailUs,
                    subtitle: 'support@edunova.com',
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildContactCard(
              context,
              icon: LucideIcons.mapPin,
              title: l10n.visitUs,
              subtitle: 'Dhaka, Bangladesh',
              color: AppColors.warning,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── FAQs ──────────────────────────────
            Text(l10n.frequentlyAsked, style: AppTextStyles.h3(context)),
            const SizedBox(height: AppSpacing.lg),
            _buildFaqItem(
              context,
              index: 0,
              question: l10n.faq1Question,
              answer: l10n.faq1Answer,
            ),
            _buildFaqItem(
              context,
              index: 1,
              question: l10n.faq2Question,
              answer: l10n.faq2Answer,
            ),
            _buildFaqItem(
              context,
              index: 2,
              question: l10n.faq3Question,
              answer: l10n.faq3Answer,
            ),
            _buildFaqItem(
              context,
              index: 3,
              question: l10n.faq4Question,
              answer: l10n.faq4Answer,
            ),
            _buildFaqItem(
              context,
              index: 4,
              question: l10n.faq5Question,
              answer: l10n.faq5Answer,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Social Links ──────────────────────
            Text(l10n.followUs, style: AppTextStyles.h3(context)),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                _buildSocialButton(
                  context,
                  icon: Icons.facebook_rounded,
                  color: const Color(0xFF1877F2),
                ),
                const SizedBox(width: AppSpacing.md),
                _buildSocialButton(
                  context,
                  icon: Icons.camera_alt_rounded,
                  color: const Color(0xFFE4405F),
                ),
                const SizedBox(width: AppSpacing.md),
                _buildSocialButton(
                  context,
                  icon: Icons.play_circle_filled_rounded,
                  color: const Color(0xFFFF0000),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.borderFor(context)),
        boxShadow: AppShadow.small,
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.bodyLarge(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(
    BuildContext context, {
    required int index,
    required String question,
    required String answer,
  }) {
    final isExpanded = _expandedFaq == index;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.medium,
        border: Border.all(
          color: isExpanded
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.borderFor(context),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() => _expandedFaq = expanded ? index : null);
          },
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isExpanded
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.backgroundFor(context),
              borderRadius: AppRadius.small,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppTextStyles.label(context).copyWith(
                  color: isExpanded
                      ? AppColors.primary
                      : AppColors.textTertiaryFor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          title: Text(
            question,
            style: AppTextStyles.bodyLarge(context).copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          trailing: Icon(
            isExpanded
                ? LucideIcons.chevronUp
                : LucideIcons.chevronDown,
            size: 20,
            color: isExpanded
                ? AppColors.primary
                : AppColors.textTertiaryFor(context),
          ),
          children: [
            Text(answer, style: AppTextStyles.bodyMedium(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.medium,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, size: 26, color: color),
    );
  }
}
