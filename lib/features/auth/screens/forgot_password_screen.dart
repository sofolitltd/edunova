import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/theme_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  int _currentStep = 1;
  bool _isLoading = false;

  Timer? _resendTimer;
  int _resendSeconds = 60;

  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _resendTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  void _handleSendOtp() {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentStep = 2;
        });
        _startResendTimer();
      }
    });
  }

  void _handleVerifyOtp() {
    if (_otpController.text.length != 6) return;

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentStep = 3;
        });
      }
    });
  }

  void _handleResetPassword() {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).resetPasswordSuccess)),
        );
        context.go('/login');
      }
    });
  }

  void _handleResendOtp() {
    if (_resendSeconds > 0) return;
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      appBar: AppAppBar(
        title: l10n.resetPassword,
        showBackButton: false,
        leading: GestureDetector(
          onTap: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              context.go('/login');
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceFor(context),
              borderRadius: AppRadius.medium,
              boxShadow: AppShadow.small,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.textPrimaryFor(context),
            ),
          ),
        ),
        trailing: _buildThemeToggle(),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  _buildHeader(l10n),
                  const SizedBox(height: AppSpacing.xxxl),
                  _buildStepIndicator(),
                  const SizedBox(height: AppSpacing.xxxl),
                  _buildCurrentStep(l10n),
                ],
              ),
            ),
          ),
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
            gradient: AppColors.gradientAccent,
            borderRadius: AppRadius.extraLarge,
            boxShadow: AppShadow.primary,
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            size: 40,
            color: AppColors.textOnPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Text(
          _currentStep == 3 ? l10n.passwordResetTitle : l10n.resetPassword,
          style: AppTextStyles.h1(context),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _currentStep == 3 ? l10n.passwordResetSubtitle : l10n.resetPasswordSubtitle,
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
        _buildStepDot(1, _currentStep >= 1),
        _buildStepLine(_currentStep >= 2),
        _buildStepDot(2, _currentStep >= 2),
        _buildStepLine(_currentStep >= 3),
        _buildStepDot(3, _currentStep >= 3),
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
            color: isActive
                ? AppColors.textOnPrimary
                : AppColors.textTertiaryFor(context),
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

  Widget _buildCurrentStep(AppLocalizations l10n) {
    switch (_currentStep) {
      case 1:
        return _buildMobileStep(l10n);
      case 2:
        return _buildOtpStep(l10n);
      case 3:
        return _buildPasswordStep(l10n);
      default:
        return _buildMobileStep(l10n);
    }
  }

  Widget _buildMobileStep(AppLocalizations l10n) {
    return Column(
      children: [
        AppTextField(
          controller: _mobileController,
          label: l10n.mobileNumber,
          prefixIcon: Icon(
            Icons.phone_rounded,
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
        const SizedBox(height: AppSpacing.xxxxl),
        AppButton(
          text: l10n.sendOtp,
          isLoading: _isLoading,
          isDisabled: _isLoading,
          onPressed: _handleSendOtp,
        ),
        const SizedBox(height: AppSpacing.xxxxxl),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: Text(
            l10n.backToLogin,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpStep(AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          '${l10n.otpSentTo} ${_mobileController.text}',
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: AppColors.textSecondaryFor(context),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppTextField(
          controller: _otpController,
          label: l10n.enterOtp,
          prefixIcon: Icon(
            Icons.pin_rounded,
            size: 20,
            color: AppColors.textTertiaryFor(context),
          ),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.length != 6) {
              return l10n.invalidOtp;
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppButton(
          text: l10n.verifyOtp,
          isLoading: _isLoading,
          isDisabled: _isLoading,
          onPressed: _handleVerifyOtp,
        ),
        const SizedBox(height: AppSpacing.xxl),
        GestureDetector(
          onTap: _resendSeconds > 0 ? null : _handleResendOtp,
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
      ],
    );
  }

  Widget _buildPasswordStep(AppLocalizations l10n) {
    return Column(
      children: [
        AppTextField(
          controller: _passwordController,
          label: l10n.newPassword,
          prefixIcon: Icon(
            Icons.lock_rounded,
            size: 20,
            color: AppColors.textTertiaryFor(context),
          ),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          suffixIcon: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _obscurePassword = !_obscurePassword);
            },
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
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
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: _confirmPasswordController,
          label: l10n.confirmNewPassword,
          prefixIcon: Icon(
            Icons.lock_rounded,
            size: 20,
            color: AppColors.textTertiaryFor(context),
          ),
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleResetPassword(),
          suffixIcon: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() =>
                  _obscureConfirmPassword = !_obscureConfirmPassword);
            },
            child: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              size: 20,
              color: AppColors.textTertiaryFor(context),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.confirmPasswordMsg;
            }
            if (value != _passwordController.text) {
              return l10n.passwordsDontMatch;
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.xxxxl),
        AppButton(
          text: l10n.savePassword,
          isLoading: _isLoading,
          isDisabled: _isLoading,
          onPressed: _handleResetPassword,
        ),
      ],
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