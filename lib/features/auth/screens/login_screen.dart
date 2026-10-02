import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme_provider.dart';

import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/constants/app_spacing.dart';
import '../models/auth_state.dart';
import '../../../l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoggingIn = false;
  String? _errorMessage;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoggingIn) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isLoggingIn = true;
      _errorMessage = null;
    });
    ref
        .read(authProvider.notifier)
        .login(
          mobile: _mobileController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.loading) return;
      if (next.status == AuthStatus.success) {
        setState(() => _isLoggingIn = false);
        context.go('/home');
      } else if (next.status == AuthStatus.error) {
        setState(() {
          _isLoggingIn = false;
          _errorMessage = next.errorMessage;
        });
      }
    });

    return AppScaffold(
      body: SafeArea(
        child: Stack(
          children: [
            FadeTransition(
              opacity: _fadeIn,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(l10n),

                        const SizedBox(height: 16),

                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceFor(context),
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            boxShadow: AppShadow.primary,
                          ),
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            children: [
                              if (_errorMessage != null)
                                _buildErrorBanner(_errorMessage!),
                              if (_errorMessage != null)
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
                                onChanged: (_) {
                                  if (_errorMessage != null) {
                                    setState(() => _errorMessage = null);
                                  }
                                },
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
                                onFieldSubmitted: (_) => _handleLogin(),
                                onChanged: (_) {
                                  if (_errorMessage != null) {
                                    setState(() => _errorMessage = null);
                                  }
                                },
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    );
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
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: AppSpacing.xxl),

                              AppButton(
                                text: l10n.login,
                                isLoading: _isLoggingIn,
                                isDisabled: _isLoggingIn,
                                onPressed: _handleLogin,
                              ),

                              const SizedBox(height: AppSpacing.xl),

                              Align(
                                alignment: Alignment.center,
                                child: InkWell(
                                  onTap: () => context.push('/forgot-password'),
                                  child: Text(
                                    l10n.forgotPassword,
                                    style: AppTextStyles.bodyMedium(context)
                                        .copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxxl),

                        _buildRegisterLink(l10n),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Theme Toggle ───────────────────────
            Positioned(bottom: 8, left: 16, child: Row(spacing: 8, children:[_buildThemeToggle(), _buildLanguageToggle()])),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
      

        Text(l10n.welcomeBack, style: AppTextStyles.h1(context)),
        const SizedBox(height: AppSpacing.sm),

        Text(
          l10n.signInToContinue,
          style: AppTextStyles.bodyMedium(context)
              .copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildRegisterLink(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.large,
        boxShadow: AppShadow.primary,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.newStudentQuestion,
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.joinNowPrompt,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: AppColors.textPrimaryFor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: () => context.push('/register'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppRadius.medium,
              ),
              child: Text(
                l10n.register,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLanguageToggle() {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(localeProvider.notifier).toggleLocale();
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
            const Icon(
              Icons.language_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              isBn ? 'বাংলা' :'ENG' ,
              style: AppTextStyles.label(
                context,
              ).copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 20, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall(
                context,
              ).copyWith(color: AppColors.error, fontWeight: FontWeight.w500),
            ),
          ),
        ],
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
              style: AppTextStyles.label(
                context,
              ).copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
