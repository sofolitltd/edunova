import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../../../app/theme_provider.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/constants/app_spacing.dart';
import '../models/auth_state.dart';
import '../../../l10n/app_localizations.dart';

class OTPVerifyScreen extends ConsumerStatefulWidget {
  const OTPVerifyScreen({super.key, required this.mobile});

  final String mobile;

  @override
  ConsumerState<OTPVerifyScreen> createState() => _OTPVerifyScreenState();
}

class _OTPVerifyScreenState extends ConsumerState<OTPVerifyScreen> {
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendSeconds = 60;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 120;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  void _handleVerify() {
    if (_otpCode.length != 6) return;

    HapticFeedback.lightImpact();
    ref.read(authProvider.notifier).verifyOTP(
          mobile: widget.mobile,
          code: _otpCode,
        );
  }

  void _handleResend() {
    if (_resendSeconds > 0) return;
    HapticFeedback.lightImpact();
    ref.read(authProvider.notifier).resendOTP(mobile: widget.mobile);
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.otpVerified)),
        );
        context.go('/login');
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? l10n.otpFailed)),
        );
      }
    });

    return AppScaffold(
      appBar: AppAppBar(title: l10n.verifyOtp, trailing: _buildThemeToggle()),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.lg),

                    _buildHeader(l10n),
                    const SizedBox(height: AppSpacing.xxxl),

                    _buildStepIndicator(),
                    const SizedBox(height: AppSpacing.xxxl),

                    _buildOTPFields(l10n),
                    const SizedBox(height: AppSpacing.xxxl),

                    AppButton(
                      text: l10n.verifyOtp,
                      isLoading: authState.status == AuthStatus.loading,
                      isDisabled: authState.status == AuthStatus.loading,
                      onPressed: _handleVerify,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    _buildResendButton(l10n),
                    const SizedBox(height: AppSpacing.xxxxxl),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.gradientPrimary,
            borderRadius: AppRadius.extraLarge,
            boxShadow: AppShadow.primary,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 40,
            color: AppColors.textOnPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          l10n.verifyOtp,
          style: AppTextStyles.h1(context),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${l10n.otpSentTo} ${widget.mobile}',
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: AppColors.textSecondaryFor(context),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepDot(1, true),
        _buildStepLine(true),
        _buildStepDot(2, true),
        _buildStepLine(false),
        _buildStepDot(3, false),
      ],
    );
  }

  Widget _buildStepDot(int step, bool isActive) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: isActive ? AppColors.gradientPrimary : null,
        color: isActive ? null : AppColors.borderFor(context),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$step',
          style: AppTextStyles.label(context).copyWith(
            color: isActive ? AppColors.textOnPrimary : AppColors.textTertiaryFor(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.borderFor(context),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _buildOTPFields(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 48,
          height: 56,
          child: TextFormField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: AppTextStyles.h2(context),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: AppRadius.medium,
                borderSide: BorderSide(color: AppColors.borderFor(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.medium,
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkSurface
                  : AppColors.primarySurface,
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
              if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
              setState(() {});
            },
          ),
        );
      }),
    );
  }

  Widget _buildResendButton(AppLocalizations l10n) {
    return Center(
      child: GestureDetector(
        onTap: _resendSeconds > 0 ? null : _handleResend,
        child: Text(
          _resendSeconds > 0
              ? '${l10n.resendOtpIn} $_resendSeconds${l10n.seconds}'
              : l10n.resendOtp,
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: _resendSeconds > 0
                ? AppColors.textTertiaryFor(context)
                : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(themeProvider.notifier).toggleTheme();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.borderFor(context), width: 1),
          boxShadow: AppShadow.small,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              isDark ? 'Dark' : 'Light',
              style: AppTextStyles.label(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
