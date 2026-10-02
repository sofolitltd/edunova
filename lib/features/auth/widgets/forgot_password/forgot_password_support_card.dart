import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

/// "Need help?" card shown under the mobile-number step.
class ForgotPasswordSupportCard extends StatelessWidget {
  const ForgotPasswordSupportCard({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primarySurfaceFor(context),
        borderRadius: AppRadius.extraLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedCustomerService,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.needHelpTitle,
                  style: AppTextStyles.label(context).copyWith(
                    color: AppColors.textPrimaryFor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceFor(context),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  l10n.supportHours,
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.textSecondaryFor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _SupportAction(
                  icon: HugeIcons.strokeRoundedCall,
                  iconColor: AppColors.primary,
                  label: l10n.hotlineCall,
                  value: '01332020222',
                  onTap: () => launchUrl(Uri.parse('tel:01332020222')),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SupportAction(
                  icon: HugeIcons.strokeRoundedMessage01,
                  iconColor: AppColors.success,
                  label: l10n.liveChatLabel,
                  value: l10n.whatsappLabel,
                  onTap: () =>
                      launchUrl(Uri.parse('https://wa.me/8801332020222')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportAction extends StatelessWidget {
  const _SupportAction({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final List<List<dynamic>> icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.medium,
          boxShadow: AppShadow.small,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.small,
              ),
              child: HugeIcon(icon: icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySmall(context),
                  ),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label(context).copyWith(
                      color: AppColors.textPrimaryFor(context),
                      fontWeight: FontWeight.w700,
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
