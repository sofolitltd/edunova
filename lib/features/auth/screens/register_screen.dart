import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../../../app/theme_provider.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/constants/app_spacing.dart';
import '../models/auth_state.dart';
import '../../../l10n/app_localizations.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _studentClass = '';

  static const _classes = ['3', '4', '5', '6', '7', '8'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;
    if (_studentClass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).classLevel)),
      );
      return;
    }

    HapticFeedback.lightImpact();
    ref.read(authProvider.notifier).register(
          fullName: _fullNameController.text.trim(),
          mobile: _mobileController.text.trim(),
          password: _passwordController.text,
          studentClass: _studentClass,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.success && next.flow == AuthFlow.registerOtp) {
        context.go('/otp-verify', extra: next.pendingMobile);
      } else if (next.status == AuthStatus.success) {
        context.go('/login');
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.errorMessage ?? l10n.registrationFailed)),
        );
      }
    });

    return AppScaffold(
      appBar: AppAppBar(
        title: l10n.createAccount,
        trailing: _buildThemeToggle(),
        leading: GestureDetector(
          onTap: () => context.go('/login'),
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
      ),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.lg),

                      _buildHeader(l10n),
                      const SizedBox(height: AppSpacing.xxxl),

                      AppTextField(
                        controller: _fullNameController,
                        label: l10n.fullName,
                        prefixIcon: Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: AppColors.textTertiaryFor(context),
                        ),
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.enterFullName;
                          }
                          if (value.length < 3) {
                            return l10n.nameMinLength;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      AppTextField(
                        controller: _mobileController,
                        label: l10n.mobileNumber,
                        prefixIcon: Icon(
                          Icons.phone_rounded,
                          size: 20,
                          color: AppColors.textTertiaryFor(context),
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
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
                      const SizedBox(height: AppSpacing.lg),

                      AppTextField(
                        controller: _passwordController,
                        label: l10n.password,
                        prefixIcon: Icon(
                          Icons.lock_rounded,
                          size: 20,
                          color: AppColors.textTertiaryFor(context),
                        ),
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleRegister(),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() =>
                                _obscurePassword = !_obscurePassword);
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
                        label: l10n.confirmPassword,
                        prefixIcon: Icon(
                          Icons.lock_rounded,
                          size: 20,
                          color: AppColors.textTertiaryFor(context),
                        ),
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.next,
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
                      const SizedBox(height: AppSpacing.xxxl),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.classLevel,
                          style: AppTextStyles.label(context)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: _classes.map((c) {
                          final isSelected = _studentClass == c;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _studentClass = c);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : AppColors.surfaceFor(context),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.borderFor(context),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Text(
                                c,
                                style: AppTextStyles.label(context).copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondaryFor(context),
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),

                      AppButton(
                        text: l10n.createAccount,
                        isLoading: authState.status == AuthStatus.loading,
                        isDisabled: authState.status == AuthStatus.loading,
                        onPressed: _handleRegister,
                      ),
                      const SizedBox(height: AppSpacing.xxxxxl),

                      _buildTerms(l10n),
                      const SizedBox(height: AppSpacing.xxxxxl),

                      _buildLoginLink(l10n),
                    ],
                  ),
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
        Row(
          children: [
            _buildStepDot(1, true),
            _buildStepLine(true),
            _buildStepDot(2, false),
            _buildStepLine(false),
            _buildStepDot(3, false),
          ],
        ),
        const SizedBox(height: AppSpacing.xxxl),

        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l10n.joinEduNova,
            style: AppTextStyles.h1(context),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l10n.createAccountToStart,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.textSecondaryFor(context),
            ),
          ),
        ),
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

  Widget _buildTerms(AppLocalizations l10n) {
    return Text.rich(
      TextSpan(
        text: l10n.byCreatingAccount,
        style: AppTextStyles.bodySmall(context),
        children: [
          TextSpan(
            text: l10n.termsOfService,
            style: AppTextStyles.bodySmall(context).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()..onTap = () => context.push('/terms'),
          ),
          TextSpan(text: l10n.and),
          TextSpan(
            text: l10n.privacyPolicy,
            style: AppTextStyles.bodySmall(context).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()..onTap = () => context.push('/privacy'),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoginLink(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.alreadyHaveAccount,
          style: AppTextStyles.bodyMedium(context),
        ),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: Text(
            l10n.login,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
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
