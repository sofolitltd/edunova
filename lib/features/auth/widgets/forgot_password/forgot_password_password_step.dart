import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

/// Step 3: choose a new password, shown with a live strength meter,
/// a confirm-password match indicator and a security checklist.
class ForgotPasswordPasswordStep extends StatelessWidget {
  const ForgotPasswordPasswordStep({
    super.key,
    required this.l10n,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.logoutAllDevices,
    required this.isLoading,
    required this.onFieldChanged,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmVisibility,
    required this.onToggleLogoutAllDevices,
    required this.onSubmit,
    required this.onCancel,
  });

  final AppLocalizations l10n;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool logoutAllDevices;
  final bool isLoading;
  final VoidCallback onFieldChanged;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onToggleConfirmVisibility;
  final ValueChanged<bool> onToggleLogoutAllDevices;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  bool get _hasMinLength => passwordController.text.length >= 6;

  bool get _hasDigitAndSymbol =>
      RegExp(r'\d').hasMatch(passwordController.text) &&
      RegExp(r'[!@#\$&*~%^()\-_=+.,]').hasMatch(passwordController.text);

  bool get _hasMixedCase =>
      RegExp(r'[a-z]').hasMatch(passwordController.text) &&
      RegExp(r'[A-Z]').hasMatch(passwordController.text);

  int get _strengthScore =>
      [_hasMinLength, _hasDigitAndSymbol, _hasMixedCase]
          .where((met) => met)
          .length;

  Color _strengthColor() {
    switch (_strengthScore) {
      case 3:
        return AppColors.success;
      case 2:
        return AppColors.primary;
      case 1:
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }

  String _strengthLabel() {
    switch (_strengthScore) {
      case 3:
        return l10n.passwordStrengthStrong;
      case 2:
        return l10n.passwordStrengthGood;
      default:
        return l10n.passwordStrengthWeak;
    }
  }

  @override
  Widget build(BuildContext context) {
    final passwordsMatch = confirmPasswordController.text.isNotEmpty &&
        confirmPasswordController.text == passwordController.text;
    final confirmHasValue = confirmPasswordController.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.extraLarge,
        boxShadow: AppShadow.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: passwordController,
            label: l10n.newPassword,
            prefixIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedSquareLock01,
              size: 20,
              color: AppColors.textTertiaryFor(context),
            ),
            obscureText: obscurePassword,
            textInputAction: TextInputAction.next,
            onChanged: (_) => onFieldChanged(),
            suffixIcon: GestureDetector(
              onTap: onTogglePasswordVisibility,
              child: HugeIcon(
                icon: obscurePassword
                    ? HugeIcons.strokeRoundedViewOffSlash
                    : HugeIcons.strokeRoundedEye,
                size: 20,
                color: AppColors.textTertiaryFor(context),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.enterPassword;
              }
              if (value.length < 6) {
                return l10n.passwordMinLength;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  child: LinearProgressIndicator(
                    value: passwordController.text.isEmpty
                        ? 0
                        : _strengthScore / 3,
                    minHeight: 6,
                    backgroundColor: AppColors.borderLightFor(context),
                    valueColor: AlwaysStoppedAnimation(_strengthColor()),
                  ),
                ),
              ),
              if (passwordController.text.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _strengthLabel(),
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: _strengthColor(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: confirmPasswordController,
            label: l10n.confirmNewPassword,
            prefixIcon: HugeIcon(
              icon: HugeIcons.strokeRoundedResetPassword,
              size: 20,
              color: AppColors.textTertiaryFor(context),
            ),
            obscureText: obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onChanged: (_) => onFieldChanged(),
            onFieldSubmitted: (_) => onSubmit(),
            suffixIcon: confirmHasValue
                ? HugeIcon(
                    icon: passwordsMatch
                        ? HugeIcons.strokeRoundedCheckmarkCircle02
                        : HugeIcons.strokeRoundedAlertCircle,
                    size: 20,
                    color: passwordsMatch
                        ? AppColors.success
                        : AppColors.errorFor(context),
                  )
                : GestureDetector(
                    onTap: onToggleConfirmVisibility,
                    child: HugeIcon(
                      icon: obscureConfirmPassword
                          ? HugeIcons.strokeRoundedViewOffSlash
                          : HugeIcons.strokeRoundedEye,
                      size: 20,
                      color: AppColors.textTertiaryFor(context),
                    ),
                  ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.confirmPasswordMsg;
              }
              if (value != passwordController.text) {
                return l10n.passwordsDontMatch;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.borderLightFor(context),
              borderRadius: AppRadius.medium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.securityRequirementsTitle,
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.textSecondaryFor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _PasswordRequirement(
                  met: _hasMinLength,
                  label: l10n.reqPasswordLength,
                ),
                const SizedBox(height: AppSpacing.xs),
                _PasswordRequirement(
                  met: _hasDigitAndSymbol,
                  label: l10n.reqPasswordSpecial,
                ),
                const SizedBox(height: AppSpacing.xs),
                _PasswordRequirement(
                  met: _hasMixedCase,
                  label: l10n.reqPasswordCase,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: () => onToggleLogoutAllDevices(!logoutAllDevices),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.borderLightFor(context),
                borderRadius: AppRadius.medium,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Switch(
                    value: logoutAllDevices,
                    activeTrackColor: AppColors.primary,
                    onChanged: onToggleLogoutAllDevices,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.logoutAllDevicesTitle,
                          style: AppTextStyles.label(context).copyWith(
                            color: AppColors.textPrimaryFor(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          l10n.logoutAllDevicesSubtitle,
                          style: AppTextStyles.bodySmall(context).copyWith(
                            color: AppColors.textSecondaryFor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            text: l10n.savePassword,
            icon: Icons.arrow_forward_rounded,
            isLoading: isLoading,
            isDisabled: isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: GestureDetector(
              onTap: onCancel,
              child: Text(
                l10n.cancelBackToLogin,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: AppColors.textSecondaryFor(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordRequirement extends StatelessWidget {
  const _PasswordRequirement({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = met ? AppColors.success : AppColors.textTertiaryFor(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HugeIcon(
          icon: met
              ? HugeIcons.strokeRoundedCheckmarkCircle02
              : HugeIcons.strokeRoundedCancelCircle,
          size: 16,
          color: color,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall(context).copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
