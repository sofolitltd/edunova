import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

/// Hero banner for step 1 (request OTP by mobile number).
class MobileRecoveryHeroCard extends StatelessWidget {
  const MobileRecoveryHeroCard({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: AppRadius.extraLarge,
        boxShadow: AppShadow.primary,
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
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: AppRadius.large,
                ),
                child: const HugeIcon(
                  icon: HugeIcons.strokeRoundedResetPassword,
                  size: 26,
                  color: AppColors.textOnPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        l10n.secureRecoveryBadge,
                        style: AppTextStyles.bodySmall(context).copyWith(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.forgotPasswordHeroTitle,
                      style: AppTextStyles.h3(context).copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.forgotPasswordHeroSubtitle,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.textOnPrimary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.white.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedShieldUser,
                  size: 16,
                  color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.encryptedRecoveryNote,
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero banner for step 2 (OTP verification).
class OtpHeroCard extends StatelessWidget {
  const OtpHeroCard({
    super.key,
    required this.l10n,
    required this.maskedMobileNumber,
    required this.onChangeNumber,
  });

  final AppLocalizations l10n;
  final String maskedMobileNumber;
  final VoidCallback onChangeNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: AppRadius.extraLarge,
        boxShadow: AppShadow.primary,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: AppRadius.large,
            ),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedMailValidation02,
              size: 26,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    l10n.otpStepBadge,
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.otpStepTitle,
                  style: AppTextStyles.h3(context).copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text.rich(
                  TextSpan(
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                    ),
                    children: [
                      TextSpan(text: '${l10n.otpSentTo} '),
                      TextSpan(
                        text: maskedMobileNumber,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                GestureDetector(
                  onTap: onChangeNumber,
                  child: Text(
                    l10n.changeNumber,
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Hero banner for step 3 (create a new password).
class PasswordCreateHeroCard extends StatelessWidget {
  const PasswordCreateHeroCard({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: AppRadius.extraLarge,
        boxShadow: AppShadow.primary,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: AppRadius.large,
            ),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedEncrypt,
              size: 26,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    l10n.otpVerifiedBadge,
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.passwordResetTitle,
                  style: AppTextStyles.h3(context).copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.createPasswordHeroSubtitle,
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
