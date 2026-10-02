import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

/// Step 1: collect the registered mobile number and request an OTP.
class ForgotPasswordMobileStep extends StatelessWidget {
  const ForgotPasswordMobileStep({
    super.key,
    required this.l10n,
    required this.mobileController,
    required this.isLoading,
    required this.onSendOtp,
    required this.onBackToLogin,
  });

  final AppLocalizations l10n;
  final TextEditingController mobileController;
  final bool isLoading;
  final VoidCallback onSendOtp;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.extraLarge,
        boxShadow: AppShadow.primary,
      ),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: mobileController,
                label: l10n.registeredMobileNumber,
                prefixIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedSmartPhone01,
                  size: 20,
                  color: AppColors.textTertiaryFor(context),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.enterMobile;
                  }
                  if (value.length < 10) {
                    return l10n.validMobile;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedInformationCircle,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      l10n.smsOtpHint,
                      style: AppTextStyles.bodySmall(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            text: l10n.sendOtp,
            isLoading: isLoading,
            isDisabled: isLoading,
            onPressed: onSendOtp,
          ),
          const SizedBox(height: AppSpacing.xxl),
          GestureDetector(
            onTap: onBackToLogin,
            child: Text(
              l10n.backToLogin,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}
