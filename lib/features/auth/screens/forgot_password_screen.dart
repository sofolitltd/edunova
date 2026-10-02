import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/forgot_password/forgot_password_hero_cards.dart';
import '../widgets/forgot_password/forgot_password_support_card.dart';
import '../widgets/forgot_password/forgot_password_mobile_step.dart';
import '../widgets/forgot_password/forgot_password_otp_step.dart';
import '../widgets/forgot_password/forgot_password_password_step.dart';

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
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _logoutAllDevices = true;

  static const int _otpLength = 4;
  final List<TextEditingController> _otpDigitControllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(_otpLength, (_) => FocusNode());
  String? _otpError;

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
    for (final controller in _otpDigitControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _resendTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  String get _otpCode =>
      _otpDigitControllers.map((controller) => controller.text).join();

  void _onOtpDigitChanged(int index, String value) {
    if (_otpError != null) {
      setState(() => _otpError = null);
    }
    if (value.isNotEmpty) {
      HapticFeedback.selectionClick();
      if (index < _otpLength - 1) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
      }
    }
  }

  void _onOtpBackspace(int index) {
    if (index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
      _otpDigitControllers[index - 1].clear();
      setState(() {});
    }
  }

  Future<void> _handlePasteOtp() async {
    final data = await Clipboard.getData('text/plain');
    final digits = data?.text?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (digits.length < _otpLength) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _otpError = null;
      for (var i = 0; i < _otpLength; i++) {
        _otpDigitControllers[i].text = digits[i];
      }
    });
    _otpFocusNodes.last.requestFocus();
  }

  void _handleVoiceCallOtp() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).getCodeByVoiceCall)),
    );
  }

  void _handleChangeNumber() {
    setState(() {
      _currentStep = 1;
      _otpError = null;
      for (final controller in _otpDigitControllers) {
        controller.clear();
      }
      _resendTimer?.cancel();
    });
  }

  String _maskedMobileNumber() {
    final digits = _mobileController.text;
    if (digits.length < 4) return digits;
    final visibleStart = digits.substring(0, digits.length > 5 ? 3 : 2);
    final visibleEnd = digits.substring(digits.length - 3);
    return '$visibleStart${'•' * (digits.length - visibleStart.length - visibleEnd.length)}$visibleEnd';
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
    if (_otpCode.length != _otpLength) {
      HapticFeedback.mediumImpact();
      setState(() => _otpError = AppLocalizations.of(context).invalidOtp);
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _otpError = null;
      _isLoading = true;
    });

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
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              size: 18,
              color: AppColors.textPrimaryFor(context),
            ),
          ),
        ),
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
                  _buildHeroForStep(l10n),
                  const SizedBox(height: AppSpacing.xxxl),
                  _buildCurrentStep(l10n),
                  if (_currentStep == 1) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    ForgotPasswordSupportCard(l10n: l10n),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroForStep(AppLocalizations l10n) {
    switch (_currentStep) {
      case 1:
        return MobileRecoveryHeroCard(l10n: l10n);
      case 2:
        return OtpHeroCard(
          l10n: l10n,
          maskedMobileNumber: _maskedMobileNumber(),
          onChangeNumber: _handleChangeNumber,
        );
      default:
        return PasswordCreateHeroCard(l10n: l10n);
    }
  }

  Widget _buildCurrentStep(AppLocalizations l10n) {
    switch (_currentStep) {
      case 1:
        return ForgotPasswordMobileStep(
          l10n: l10n,
          mobileController: _mobileController,
          isLoading: _isLoading,
          onSendOtp: _handleSendOtp,
          onBackToLogin: () => context.go('/login'),
        );
      case 2:
        return ForgotPasswordOtpStep(
          l10n: l10n,
          otpLength: _otpLength,
          digitControllers: _otpDigitControllers,
          focusNodes: _otpFocusNodes,
          otpError: _otpError,
          resendSeconds: _resendSeconds,
          isLoading: _isLoading,
          onDigitChanged: _onOtpDigitChanged,
          onBackspace: _onOtpBackspace,
          onPaste: _handlePasteOtp,
          onResend: _handleResendOtp,
          onVoiceCall: _handleVoiceCallOtp,
          onVerify: _handleVerifyOtp,
        );
      default:
        return ForgotPasswordPasswordStep(
          l10n: l10n,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          obscurePassword: _obscurePassword,
          obscureConfirmPassword: _obscureConfirmPassword,
          logoutAllDevices: _logoutAllDevices,
          isLoading: _isLoading,
          onFieldChanged: () => setState(() {}),
          onTogglePasswordVisibility: () {
            HapticFeedback.selectionClick();
            setState(() => _obscurePassword = !_obscurePassword);
          },
          onToggleConfirmVisibility: () {
            HapticFeedback.selectionClick();
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
          },
          onToggleLogoutAllDevices: (value) {
            HapticFeedback.selectionClick();
            setState(() => _logoutAllDevices = value);
          },
          onSubmit: _handleResetPassword,
          onCancel: () => context.go('/login'),
        );
    }
  }
}
