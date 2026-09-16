import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme_provider.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/services/secure_storage_service.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../courses/services/course_service.dart';
import '../../../notifications/services/notification_history_service.dart';
import '../../../results/services/results_service.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  final CourseService _service = CourseService();
  final ResultsService _resultsService = ResultsService();
  final NotificationHistoryService _notificationService = NotificationHistoryService();
  List<Course> _freeCourses = [];
  List<Course> _offlineCourses = [];
  List<Course> _onlineCourses = [];
  ResultSummary _resultSummary = ResultSummary.empty();
  Enrollment? _activeEnrollment;
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _loadResultSummary();
    _loadRoutine();
    _loadNotifications();
  }

  Future<void> _loadCourses() async {
    try {
      setState(() => _isLoading = true);
      final studentClass = ref.read(authProvider).user?.studentClass;
      final results = await Future.wait([
        _service.getCourses(type: 'free', classLevel: studentClass),
        _service.getCourses(type: 'offline'),
        _service.getCourses(type: 'online'),
      ]);
      setState(() {
        _freeCourses = results[0];
        _offlineCourses = results[1];
        _onlineCourses = results[2];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadResultSummary() async {
    try {
      final token = await SecureStorageService().readToken();
      final summary = await _resultsService.getSummary(token: token);
      if (mounted) setState(() => _resultSummary = summary);
    } catch (_) {}
  }

  Future<void> _loadRoutine() async {
    try {
      final token = await SecureStorageService().readToken();
      if (token == null) return;
      final enrollments = await _service.getMyEnrollments(token);
      final approved = enrollments.where(
        (e) => e.status == 'approved' && e.batchSchedule.isNotEmpty,
      );
      if (mounted && approved.isNotEmpty) {
        setState(() => _activeEnrollment = approved.first);
      }
    } catch (_) {}
  }

  Future<void> _loadNotifications() async {
    try {
      final token = await SecureStorageService().readToken();
      if (token == null) return;
      final notifications = await _notificationService.getNotifications(token);
      if (mounted) setState(() => _notifications = notifications);
    } catch (_) {}
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => Future.wait([_loadCourses(), _loadResultSummary(), _loadRoutine(), _loadNotifications()]),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // ── Header ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.welcomeBack,
                        style: AppTextStyles.h2(context),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.homeSubtitle,
                        style: AppTextStyles.bodyMedium(context),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context.push('/notifications');
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceFor(context),
                            borderRadius: AppRadius.medium,
                            boxShadow: AppShadow.small,
                            border: Border.all(color: AppColors.borderFor(context)),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(themeProvider.notifier).toggleTheme();
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceFor(context),
                            borderRadius: AppRadius.medium,
                            boxShadow: AppShadow.small,
                            border: Border.all(color: AppColors.borderFor(context)),
                          ),
                          child: Icon(
                            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Search Bar ──────────────────────────
              GestureDetector(
                onTap: () => context.push('/courses'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceFor(context),
                    borderRadius: AppRadius.medium,
                    border: Border.all(color: AppColors.borderFor(context)),
                    boxShadow: AppShadow.small,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AppColors.textTertiaryFor(context),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l10n.searchCourses,
                        style: AppTextStyles.bodyMedium(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Progress Summary ─────────────────────
              if (_resultSummary.totalExams > 0) ...[
                _buildProgressCard(context),
                const SizedBox(height: AppSpacing.md),
              ],

              // ── Routine ───────────────────────────────
              if (_activeEnrollment != null) ...[
                _buildRoutineCard(context),
                const SizedBox(height: AppSpacing.md),
              ],

              // ── Notifications Preview ────────────────
              if (_notifications.isNotEmpty) ...[
                _buildNotificationsCard(context),
                const SizedBox(height: AppSpacing.xxl),
              ] else
                const SizedBox(height: AppSpacing.lg),

              // ── Quick Access ─────────────────────────
              Text('দ্রুত প্রবেশ', style: AppTextStyles.h3(context)),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.live_tv_rounded,
                    label: 'লাইভ পরীক্ষা',
                    color: AppColors.error,
                    onTap: () => context.push('/live-exams'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.note_alt_rounded,
                    label: 'নোটস',
                    color: AppColors.primary,
                    onTap: () => context.push('/notes'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.lightbulb_rounded,
                    label: 'দৈনিক শেখার',
                    color: AppColors.warning,
                    onTap: () => context.push('/daily-content'),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _buildQuickAccessCard(
                    context,
                    icon: Icons.sports_esports_rounded,
                    label: 'অনুশীলন',
                    color: AppColors.success,
                    onTap: () => context.push('/practice'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Free Courses ────────────────────────
              if (_freeCourses.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  title: 'ফ্রী কোর্স',
                  subtitle: 'বিনামূল্যে কোর্সে ভর্তি হন',
                  color: AppColors.success,
                  onTap: () => context.push('/courses?type=free'),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _freeCourses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) => _buildCourseCardHorizontal(
                      context,
                      course: _freeCourses[index],
                      accentColor: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],

              // ── Offline Batches ─────────────────────
              if (_offlineCourses.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  title: 'অফলাইন ব্যাচ',
                  subtitle: 'কোচিং সেন্টারে ক্লাস',
                  color: AppColors.warning,
                  onTap: () => context.push('/courses?type=offline'),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _offlineCourses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) => _buildCourseCardHorizontal(
                      context,
                      course: _offlineCourses[index],
                      accentColor: AppColors.warning,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],

              // ── Online Courses ──────────────────────
              if (_onlineCourses.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  title: 'অনলাইন কোর্স',
                  subtitle: 'ঘরে বসে পড়ুন',
                  color: AppColors.primary,
                  onTap: () => context.push('/courses?type=online'),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _onlineCourses.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) => _buildCourseCardHorizontal(
                      context,
                      course: _onlineCourses[index],
                      accentColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],

              // ── Loading / Empty ─────────────────────
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!_isLoading && _freeCourses.isEmpty && _offlineCourses.isEmpty && _onlineCourses.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'কোনো কোর্স পাওয়া যায়নি',
                      style: AppTextStyles.bodyMedium(context),
                    ),
                  ),
                ),

              // ── See All Courses Button ───────────────
              GestureDetector(
                onTap: () => context.push('/courses'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: AppRadius.large,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: AppRadius.medium,
                        ),
                        child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'সব কোর্স দেখুন',
                              style: AppTextStyles.bodyLarge(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Class ৩-৮ এর সব কোর্স',
                              style: AppTextStyles.bodySmall(context).copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.8), size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Parenting Hub ────────────────────────
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.push('/articles');
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)],
                    ),
                    borderRadius: AppRadius.large,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: AppRadius.medium,
                        ),
                        child: const Icon(Icons.article_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'পেরেন্টিং হাব',
                              style: AppTextStyles.bodyLarge(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'শিশু বিকাস, মানসিক স্বাস্থ্য ও পেরেন্টিং টিপস',
                              style: AppTextStyles.bodySmall(context).copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withValues(alpha: 0.8), size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h3(context)),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTextStyles.bodySmall(context)),
          ],
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'সব দেখুন',
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCardHorizontal(
    BuildContext context, {
    required Course course,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: () => context.push('/courses/${course.id}'),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadow.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.small,
                  ),
                  child: Text(
                    course.type == 'free' ? 'ফ্রী' : course.type == 'offline' ? 'অফলাইন' : 'অনলাইন',
                    style: AppTextStyles.label(context).copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                if (course.classLevel.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.borderFor(context),
                      borderRadius: AppRadius.small,
                    ),
                    child: Text(
                      'Class ${course.classLevel}',
                      style: AppTextStyles.label(context).copyWith(fontSize: 10),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              course.titleBn.isNotEmpty ? course.titleBn : course.title,
              style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (course.type == 'free')
              Text(
                'ফ্রী',
                style: AppTextStyles.bodyLarge(context).copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              )
            else
              Text(
                '৳${course.price}',
                style: AppTextStyles.bodyLarge(context).copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            if (course.schedule.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                course.schedule,
                style: AppTextStyles.bodySmall(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.small,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: AppTextStyles.bodySmall(context).copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    final percent = _resultSummary.overallPercent;
    final color = percent >= 70
        ? AppColors.success
        : percent >= 50
            ? AppColors.warning
            : AppColors.error;

    return GestureDetector(
      onTap: () => context.push('/results'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadow.small,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('সামগ্রিক ফলাফল', style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    _resultSummary.improvementAreas.isNotEmpty
                        ? '${_resultSummary.improvementAreas.first.subject}-এ উন্নতি দরকার'
                        : '${_resultSummary.totalExams}টি পরীক্ষার ফলাফল দেখুন',
                    style: AppTextStyles.bodySmall(context),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCard(BuildContext context) {
    final enrollment = _activeEnrollment!;
    return GestureDetector(
      onTap: () => context.push('/my-enrollments'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadow.small,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.small,
              ),
              child: Icon(Icons.schedule_rounded, size: 22, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enrollment.batchName.isNotEmpty ? enrollment.batchName : 'রুটিন',
                    style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(enrollment.batchSchedule, style: AppTextStyles.bodySmall(context), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsCard(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.readByMe).length;
    final latest = _notifications.first;
    return GestureDetector(
      onTap: () => context.push('/notifications'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadow.small,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: AppRadius.small,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(child: Icon(Icons.notifications_rounded, size: 22, color: AppColors.warning)),
                  if (unreadCount > 0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$unreadCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('নোটিফিকেশন', style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(latest.title, style: AppTextStyles.bodySmall(context), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
