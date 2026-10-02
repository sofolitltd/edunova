import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

/// Step 2: 4-digit OTP entry, resend/voice-call actions and help strip.
class ForgotPasswordOtpStep extends StatelessWidget {
  const ForgotPasswordOtpStep({
    super.key,
    required this.l10n,
    required this.otpLength,
    required this.digitControllers,
    required this.focusNodes,
    required this.otpError,
    required this.resendSeconds,
    required this.isLoading,
    required this.onDigitChanged,
    required this.onBackspace,
    required this.onPaste,
    required this.onResend,
    required this.onVoiceCall,
    required this.onVerify,
  });

  final AppLocalizations l10n;
  final int otpLength;
  final List<TextEditingController> digitControllers;
  final List<FocusNode> focusNodes;
  final String? otpError;
  final int resendSeconds;
  final bool isLoading;
  final void Function(int index, String value) onDigitChanged;
  final void Function(int index) onBackspace;
  final VoidCallback onPaste;
  final VoidCallback onResend;
  final VoidCallback onVoiceCall;
  final VoidCallback onVerify;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(context),
            borderRadius: AppRadius.extraLarge,
            boxShadow: AppShadow.primary,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedSmsCode,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.otpDigitsLabel,
                        style: AppTextStyles.label(context).copyWith(
                          color: AppColors.textSecondaryFor(context),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurfaceFor(context),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      l10n.otpPendingBadge,
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(otpLength, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == otpLength - 1 ? 0 : AppSpacing.sm,
                    ),
                    child: _OtpDigitBox(
                      controller: digitControllers[index],
                      focusNode: focusNodes[index],
                      hasError: otpError != null,
                      onChanged: (value) => onDigitChanged(index, value),
                      onBackspace: () => onBackspace(index),
                    ),
                  );
                }),
              ),
              if (otpError != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  otpError!,
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.errorFor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              GestureDetector(
                onTap: onPaste,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.borderLightFor(context),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedClipboardPaste,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l10n.pasteCodeFromSms,
                        style: AppTextStyles.label(context).copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.borderLightFor(context),
                  borderRadius: AppRadius.medium,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedClock01,
                              size: 18,
                              color: AppColors.textSecondaryFor(context),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              l10n.resendOtpIn,
                              style: AppTextStyles.bodySmall(context),
                            ),
                          ],
                        ),
                        Text(
                          resendSeconds > 0
                              ? '${resendSeconds.toString().padLeft(2, '0')}${l10n.seconds}'
                              : '00${l10n.seconds}',
                          style: AppTextStyles.label(context).copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: resendSeconds > 0 ? null : onResend,
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedRefresh,
                                size: 16,
                                color: resendSeconds > 0
                                    ? AppColors.textTertiaryFor(context)
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                l10n.resendOtp,
                                style: AppTextStyles.label(context).copyWith(
                                  color: resendSeconds > 0
                                      ? AppColors.textTertiaryFor(context)
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: onVoiceCall,
                          child: Row(
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedCall,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                l10n.getCodeByVoiceCall,
                                style: AppTextStyles.label(context).copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                text: l10n.verifyOtp,
                icon: Icons.arrow_forward_rounded,
                isLoading: isLoading,
                isDisabled: isLoading,
                onPressed: onVerify,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedShield01,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    l10n.otpSecurityNote,
                    style: AppTextStyles.bodySmall(context),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _OtpHelpStrip(l10n: l10n),
      ],
    );
  }
}

class _OtpDigitBox extends StatelessWidget {
  const _OtpDigitBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onBackspace,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 64,
      child: KeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: AppTextStyles.h3(context).copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.surfaceFor(context),
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: AppRadius.medium,
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.errorFor(context)
                    : AppColors.borderFor(context),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.medium,
              borderSide: BorderSide(
                color: hasError
                    ? AppColors.errorFor(context)
                    : AppColors.borderFor(context),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.medium,
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _OtpHelpStrip extends StatelessWidget {
  const _OtpHelpStrip({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.extraLarge,
        boxShadow: AppShadow.small,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.borderLightFor(context),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedCustomerService01,
              size: 20,
              color: AppColors.textSecondaryFor(context),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.otpTroubleQuestion,
                  style: AppTextStyles.label(context),
                ),
                Text(
                  '${l10n.hotlineCall}: 01332020222',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.textSecondaryFor(context),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse('tel:01332020222')),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.borderLightFor(context),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                l10n.getHelp,
                style: AppTextStyles.label(context).copyWith(
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
