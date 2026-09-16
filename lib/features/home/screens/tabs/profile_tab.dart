import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../app/theme_provider.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/providers/locale_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/services/auth_service.dart';
import '../../../results/services/results_service.dart';
import '../../../../shared/services/secure_storage_service.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  final _authService = AuthService();
  final _resultsService = ResultsService();
  int _approvedCourses = 0;
  ResultSummary _resultSummary = ResultSummary.empty();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final token = await SecureStorageService().readToken();
      if (token == null) return;
      final results = await Future.wait([
        _authService.getDashboardStats(token),
        _resultsService.getSummary(token: token),
      ]);
      final dashboard = results[0] as Map<String, dynamic>;
      final summary = results[1] as ResultSummary;
      if (mounted) {
        setState(() {
          _approvedCourses = dashboard['approved_enrollments'] ?? 0;
          _resultSummary = summary;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final currentLocale = ref.watch(localeProvider);
    final isBn = currentLocale.languageCode == 'bn';
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final userName = user?.fullName ?? 'User';
    final userMobile = user?.mobile ?? '';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    final isVerified = user?.verified ?? false;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xl),

            // ── Profile Header ─────────────────────
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientPrimary,
                      shape: BoxShape.circle,
                      boxShadow: AppShadow.primary,
                    ),
                    child: Center(
                      child: Text(
                        userInitial,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    userName,
                    style: AppTextStyles.h2(context),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        l10n.verified,
                        style: AppTextStyles.label(context).copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    userMobile,
                    style: AppTextStyles.bodyMedium(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Incomplete Profile Banner ─────────
            if (user != null && !user.isProfileComplete)
              GestureDetector(
                onTap: () => context.push('/profile-setup'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.08),
                    borderRadius: AppRadius.medium,
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.warning),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'প্রোফাইল অসম্পূর্ণ',
                              style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'ট্যাপ করে সম্পূর্ণ করুন',
                              style: AppTextStyles.bodySmall(context),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.warning),
                    ],
                  ),
                ),
              ),

            // ── Stats ──────────────────────────────
            Row(
              children: [
                _buildProfileStat(context, '$_approvedCourses', l10n.courses),
                const SizedBox(width: AppSpacing.md),
                _buildProfileStat(context, '${_resultSummary.totalExams}', l10n.examsTaken),
                const SizedBox(width: AppSpacing.md),
                _buildProfileStat(
                  context,
                  _resultSummary.totalExams > 0 ? '${_resultSummary.overallPercent.toStringAsFixed(0)}%' : '—',
                  l10n.avgScore,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Settings Section ───────────────────
            Text(
              l10n.settings,
              style: AppTextStyles.h3(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSettingsTile(
              context,
              icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              title: l10n.darkMode,
              trailing: Switch(
                value: isDark,
                onChanged: (_) {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
                activeThumbColor: AppColors.primary,
              ),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.language_rounded,
              title: l10n.language,
              trailing: Text(
                isBn ? 'বাংলা' : 'English',
                style: AppTextStyles.label(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () {
                ref.read(localeProvider.notifier).toggleLocale();
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.notifications_rounded,
              title: l10n.notifications,
              trailing: Switch(
                value: true,
                onChanged: (_) {},
                activeThumbColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Account Section ────────────────────
            Text(
              l10n.account,
              style: AppTextStyles.h3(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSettingsTile(
              context,
              icon: Icons.person_rounded,
              title: l10n.editProfile,
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiaryFor(context),
              ),
              onTap: () => context.push('/edit-profile'),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.school_rounded,
              title: 'আমার এনরোলমেন্ট',
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiaryFor(context),
              ),
              onTap: () => context.push('/my-enrollments'),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.live_tv_rounded,
              title: 'লাইভ পরীক্ষা',
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiaryFor(context),
              ),
              onTap: () => context.push('/live-exams'),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.note_alt_rounded,
              title: 'নোটস',
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiaryFor(context),
              ),
              onTap: () => context.push('/notes'),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.lightbulb_rounded,
              title: 'দৈনিক শেখার',
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiaryFor(context),
              ),
              onTap: () => context.push('/daily-content'),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.swap_horiz_rounded,
              title: 'বার্ষিক ট্রানজিশন',
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiaryFor(context),
              ),
              onTap: () => context.push('/transition'),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.lock_rounded,
              title: l10n.changePassword,
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiaryFor(context),
              ),
              onTap: () => context.push('/change-password'),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.help_rounded,
              title: l10n.help,
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiaryFor(context),
              ),
              onTap: () => context.push('/help-support'),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.info_outline_rounded,
              title: l10n.about,
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiaryFor(context),
              ),
              onTap: () => context.push('/about'),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSettingsTile(
              context,
              icon: Icons.logout_rounded,
              title: l10n.logout,
              color: AppColors.error,
              trailing: Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 20,
              ),
              onTap: () => _showLogoutSheet(context, ref, l10n),
            ),
            const SizedBox(height: AppSpacing.xxxxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(BuildContext context, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadow.small,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.h3(context).copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.bodySmall(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.borderFor(context)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color ?? AppColors.primary),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge(context).copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  void _showLogoutSheet(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(ctx),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderFor(ctx),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.logOut,
                  size: 28,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.logoutConfirm,
                style: AppTextStyles.h3(ctx),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.logoutConfirmSubtitle,
                style: AppTextStyles.bodyMedium(ctx),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundFor(ctx),
                          borderRadius: AppRadius.medium,
                          border: Border.all(color: AppColors.borderFor(ctx)),
                        ),
                        child: Center(
                          child: Text(
                            l10n.cancel,
                            style: AppTextStyles.buttonMedium(ctx).copyWith(
                              color: AppColors.textPrimaryFor(ctx),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(ctx);
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) context.go('/login');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: AppRadius.medium,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            l10n.logout,
                            style: AppTextStyles.buttonMedium(ctx),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
