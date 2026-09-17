import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../exams/services/exam_service.dart' as exam_service;
import '../services/batch_service.dart';
import 'tabs/exam_tab.dart';

class ClassDetailScreen extends ConsumerStatefulWidget {
  final int batchId;
  final String fallbackTitle;
  final Color color;

  const ClassDetailScreen({
    super.key,
    required this.batchId,
    required this.fallbackTitle,
    required this.color,
  });

  @override
  ConsumerState<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends ConsumerState<ClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _service = BatchService();

  bool _loading = true;
  String? _error;
  BatchDetail? _batch;
  List<BatchSubjectSchedule> _subjects = [];
  List<BatchExam> _exams = [];
  List<LeaderboardEntry> _leaderboard = [];
  List<BatchMyResult> _myResults = [];
  bool _subjectsLoaded = false;
  bool _examsLoaded = false;
  bool _leaderboardLoaded = false;
  bool _myResultsLoaded = false;
  bool _subjectsLoading = false;
  bool _examsLoading = false;
  bool _leaderboardLoading = false;
  bool _myResultsLoading = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _load();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 1 && !_subjectsLoaded && !_subjectsLoading) {
      _loadSubjects();
    }
    if (_tabController.index == 2 && !_examsLoaded && !_examsLoading) {
      _loadExams();
    }
    if (_tabController.index == 3 && !_leaderboardLoaded && !_leaderboardLoading) {
      _loadLeaderboard();
    }
    if (_tabController.index == 4 && !_myResultsLoaded && !_myResultsLoading) {
      _loadMyResults();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _token = await SecureStorageService().readToken();
    final batch = await _service.getBatchDetail(_token, widget.batchId);
    if (!mounted) return;
    setState(() {
      _batch = batch;
      _error = batch == null ? 'ব্যাচের তথ্য লোড করা যায়নি' : null;
      _loading = false;
    });
  }

  Future<void> _loadSubjects() async {
    setState(() => _subjectsLoading = true);
    final subjects = await _service.getBatchSubjects(_token, widget.batchId);
    if (!mounted) return;
    setState(() {
      _subjects = subjects;
      _subjectsLoaded = true;
      _subjectsLoading = false;
    });
  }

  Future<void> _loadExams() async {
    setState(() => _examsLoading = true);
    final exams = await _service.getBatchExams(_token, widget.batchId);
    if (!mounted) return;
    setState(() {
      _exams = exams;
      _examsLoaded = true;
      _examsLoading = false;
    });
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _leaderboardLoading = true);
    final entries = await _service.getBatchLeaderboard(_token, widget.batchId);
    if (!mounted) return;
    setState(() {
      _leaderboard = entries;
      _leaderboardLoaded = true;
      _leaderboardLoading = false;
    });
  }

  Future<void> _loadMyResults() async {
    setState(() => _myResultsLoading = true);
    final results = await _service.getBatchMyResults(_token, widget.batchId);
    if (!mounted) return;
    setState(() {
      _myResults = results;
      _myResultsLoaded = true;
      _myResultsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _batch?.name.isNotEmpty == true ? _batch!.name : widget.fallbackTitle;

    return AppScaffold(
      appBar: AppAppBar(title: title),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || _batch == null
              ? _buildError()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        AppSpacing.xl,
                        AppSpacing.screenHorizontal,
                        0,
                      ),
                      child: _buildHeader(context, l10n, _batch!),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Tab Bar ─────────────────────────────
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenHorizontal,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceFor(context),
                        borderRadius: AppRadius.medium,
                        border: Border.all(color: AppColors.borderFor(context)),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.1),
                          borderRadius: AppRadius.medium,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: widget.color,
                        unselectedLabelColor: AppColors.textTertiaryFor(context),
                        labelStyle: AppTextStyles.label(context).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        unselectedLabelStyle: AppTextStyles.label(context).copyWith(
                          fontSize: 12,
                        ),
                        labelPadding: EdgeInsets.zero,
                        tabs: [
                          Tab(text: l10n.aboutClass),
                          Tab(text: l10n.weeklySchedule),
                          const Tab(text: 'পরীক্ষা'),
                          const Tab(text: 'লিডারবোর্ড'),
                          const Tab(text: 'ফলাফল'),
                        ],
                      ),
                    ),

                    // ── Tab Bar View ────────────────────────
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAboutTab(context, l10n, _batch!),
                          _buildScheduleTab(context, _batch!),
                          _buildExamTab(context),
                          _buildLeaderboardTab(context),
                          _buildResultTab(context),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(_error ?? 'ব্যাচ পাওয়া যায়নি', textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(onPressed: _load, child: const Text('আবার চেষ্টা করুন')),
          ],
        ),
      ),
    );
  }

  // ── Header Card ────────────────────────────────
  Widget _buildHeader(BuildContext context, AppLocalizations l10n, BatchDetail batch) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [widget.color, widget.color.withValues(alpha: 0.7)],
        ),
        borderRadius: AppRadius.large,
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppRadius.medium,
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.name,
                      style: AppTextStyles.h2(context).copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      batch.courseName,
                      style: AppTextStyles.bodyLarge(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              _buildHeaderStat(
                context,
                icon: Icons.schedule_rounded,
                value: batch.schedule.isNotEmpty ? batch.schedule : '-',
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildHeaderStat(
                context,
                icon: Icons.people_rounded,
                value: '${batch.studentCount} ${l10n.students}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(BuildContext context, {
    required IconData icon,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Text(
          value,
          style: AppTextStyles.bodySmall(context).copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  // ── About Tab ──────────────────────────────────
  Widget _buildAboutTab(BuildContext context, AppLocalizations l10n, BatchDetail batch) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (batch.courseDescription.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceFor(context),
                borderRadius: AppRadius.medium,
                border: Border.all(color: AppColors.borderFor(context)),
              ),
              child: Text(batch.courseDescription, style: AppTextStyles.bodyLarge(context)),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          _infoRow(context, Icons.school_rounded, 'ক্লাস', batch.classLevel.isNotEmpty ? 'Class ${batch.classLevel}' : '-'),
          _infoRow(context, Icons.category_rounded, 'ধরন', batch.type.isNotEmpty ? batch.type : '-'),
          _infoRow(context, Icons.wb_sunny_rounded, 'শিফট', batch.shift.isNotEmpty ? batch.shift : '-'),
          _infoRow(context, Icons.people_rounded, 'মোট শিক্ষার্থী', '${batch.studentCount}'),
          const SizedBox(height: AppSpacing.xl),
          Text('শিক্ষক', style: AppTextStyles.h3(context)),
          const SizedBox(height: AppSpacing.md),
          if (batch.teachers.isEmpty)
            Text('এখনো কোনো শিক্ষক নিয়োগ করা হয়নি', style: AppTextStyles.bodySmall(context))
          else
            ...batch.teachers.map((t) => Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceFor(context),
                    borderRadius: AppRadius.small,
                    border: Border.all(color: AppColors.borderFor(context)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: widget.color.withValues(alpha: 0.1),
                        child: Text(
                          t.fullName.isNotEmpty ? t.fullName[0].toUpperCase() : '?',
                          style: AppTextStyles.label(context).copyWith(
                            color: widget.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(t.fullName, style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiaryFor(context)),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.bodySmall(context)),
          const Spacer(),
          Text(value, style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Schedule Tab ───────────────────────────────
  static const _weekDays = ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  static const _weekDayAbbrev = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  Widget _buildScheduleTab(BuildContext context, BatchDetail batch) {
    if (_subjectsLoading && !_subjectsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    // No per-subject schedule set up for this batch yet — fall back to the
    // old flat batch-wide days/time so the tab isn't empty.
    if (_subjects.isEmpty) {
      final activeDays = batch.days.map((d) => d.toLowerCase()).toSet();
      final timeRange = batch.startTime.isNotEmpty && batch.endTime.isNotEmpty
          ? '${batch.startTime} - ${batch.endTime}'
          : batch.schedule;

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _weekDays.map((day) {
            final active = activeDays.contains(day.toLowerCase());
            return _buildScheduleRow(context, day, active ? timeRange : '-', active);
          }).toList(),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_weekDays.length, (i) {
          final dayKey = _weekDayAbbrev[i].toLowerCase();
          final dayEntries = _subjects
              .where((s) => s.days.any((d) => d.toLowerCase() == dayKey))
              .toList()
            ..sort((a, b) => a.startTime.compareTo(b.startTime));
          return _buildDaySubjects(context, _weekDays[i], dayEntries);
        }),
      ),
    );
  }

  Widget _buildDaySubjects(BuildContext context, String day, List<BatchSubjectSchedule> entries) {
    final active = entries.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active ? widget.color.withValues(alpha: 0.05) : AppColors.surfaceFor(context),
        borderRadius: AppRadius.small,
        border: Border.all(
          color: active ? widget.color.withValues(alpha: 0.2) : AppColors.borderFor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: active ? widget.color : AppColors.textTertiaryFor(context),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                day,
                style: AppTextStyles.bodyLarge(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.textPrimaryFor(context) : AppColors.textTertiaryFor(context),
                ),
              ),
            ],
          ),
          if (!active)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 20),
              child: Text(
                '-',
                style: AppTextStyles.bodySmall(context).copyWith(color: AppColors.textTertiaryFor(context)),
              ),
            )
          else
            ...entries.map((e) => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm, left: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.teacherName.isNotEmpty ? '${e.subjectName} (${e.teacherName})' : e.subjectName,
                          style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (e.startTime.isNotEmpty || e.endTime.isNotEmpty)
                        Text(
                          '${e.startTime} - ${e.endTime}',
                          style: AppTextStyles.bodySmall(context).copyWith(color: widget.color),
                        ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(BuildContext context, String day, String time, bool active) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active
            ? widget.color.withValues(alpha: 0.05)
            : AppColors.surfaceFor(context),
        borderRadius: AppRadius.small,
        border: Border.all(
          color: active ? widget.color.withValues(alpha: 0.2) : AppColors.borderFor(context),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? widget.color : AppColors.textTertiaryFor(context),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              day,
              style: AppTextStyles.bodyLarge(context).copyWith(
                fontWeight: FontWeight.w500,
                color: active ? AppColors.textPrimaryFor(context) : AppColors.textTertiaryFor(context),
              ),
            ),
          ),
          Text(
            time,
            style: AppTextStyles.bodySmall(context).copyWith(
              color: active ? widget.color : AppColors.textTertiaryFor(context),
            ),
          ),
        ],
      ),
    );
  }

  // ── Exam Tab ───────────────────────────────────
  Widget _buildExamTab(BuildContext context) {
    if (_examsLoading && !_examsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_exams.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.quiz_outlined, size: 56, color: AppColors.textTertiaryFor(context)),
              const SizedBox(height: AppSpacing.md),
              Text('এই ব্যাচের জন্য কোনো পরীক্ষা নেই', style: AppTextStyles.bodyMedium(context)),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xl,
      ),
      itemCount: _exams.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final e = _exams[i];
        return GestureDetector(
          onTap: () => _openExam(context, e),
          child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(context),
            borderRadius: AppRadius.small,
            border: Border.all(
              color: e.isLive ? AppColors.error.withValues(alpha: 0.3) : AppColors.borderFor(context),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (e.isLive ? AppColors.error : widget.color).withValues(alpha: 0.1),
                  borderRadius: AppRadius.small,
                ),
                child: Icon(
                  e.isLive ? Icons.play_circle_filled_rounded : Icons.quiz_rounded,
                  size: 20,
                  color: e.isLive ? AppColors.error : widget.color,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.title, style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w500)),
                    Text('${e.date} • ${e.totalQuestions} প্রশ্ন', style: AppTextStyles.bodySmall(context)),
                  ],
                ),
              ),
              if (e.isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          ),
        );
      },
    );
  }

  Future<void> _openExam(BuildContext context, BatchExam exam) async {
    final storage = SecureStorageService();
    final token = await storage.readToken();
    try {
      final questions = await exam_service.ExamService()
          .getExamQuestions(exam.id, token: token);
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ExamTakingScreen(
          exam: exam_service.Exam(
            id: exam.id,
            title: exam.title,
            courseId: 0,
            courseName: widget.fallbackTitle,
            date: exam.date,
            time: exam.time,
            duration: exam.duration,
            totalQuestions: exam.totalQuestions,
            isLive: exam.isLive,
          ),
          questions: questions,
          token: token,
        ),
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // ── Leaderboard Tab ────────────────────────────
  Widget _buildLeaderboardTab(BuildContext context) {
    if (_leaderboardLoading && !_leaderboardLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_leaderboard.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_outlined, size: 56, color: AppColors.textTertiaryFor(context)),
              const SizedBox(height: AppSpacing.md),
              Text('এখনো কোনো ফলাফল নেই', style: AppTextStyles.bodyMedium(context)),
            ],
          ),
        ),
      );
    }

    final myUserId = ref.watch(authProvider).user?.id;
    final medalColors = [const Color(0xFFFBBF24), const Color(0xFF94A3B8), const Color(0xFFB45309)];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xl,
      ),
      itemCount: _leaderboard.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final e = _leaderboard[i];
        final isMe = myUserId != null && myUserId == e.userId;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isMe ? widget.color.withValues(alpha: 0.06) : AppColors.surfaceFor(context),
            borderRadius: AppRadius.small,
            border: Border.all(color: isMe ? widget.color.withValues(alpha: 0.3) : AppColors.borderFor(context)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '${i + 1}',
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.w800,
                    color: i < 3 ? medalColors[i] : AppColors.textTertiaryFor(context),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              CircleAvatar(
                radius: 18,
                backgroundColor: widget.color.withValues(alpha: 0.1),
                child: Text(
                  e.fullName.isNotEmpty ? e.fullName[0].toUpperCase() : '?',
                  style: AppTextStyles.label(context).copyWith(color: widget.color, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMe ? '${e.fullName} (তুমি)' : e.fullName,
                      style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text('${e.examsTaken} পরীক্ষা দিয়েছে', style: AppTextStyles.bodySmall(context)),
                  ],
                ),
              ),
              Text(
                '${e.totalScore}',
                style: AppTextStyles.h3(context).copyWith(color: widget.color),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Result Tab ─────────────────────────────────
  Color _percentColor(double percent) {
    if (percent >= 70) return AppColors.success;
    if (percent >= 50) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildResultTab(BuildContext context) {
    if (_myResultsLoading && !_myResultsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_myResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart_rounded, size: 56, color: AppColors.textTertiaryFor(context)),
              const SizedBox(height: AppSpacing.md),
              Text('এখনো কোনো ফলাফল নেই', style: AppTextStyles.bodyMedium(context)),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xl,
      ),
      itemCount: _myResults.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final r = _myResults[i];
        final color = _percentColor(r.percentage);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(context),
            borderRadius: AppRadius.small,
            border: Border.all(color: AppColors.borderFor(context)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: AppRadius.small),
                child: Center(
                  child: Text(
                    '${r.percentage.toStringAsFixed(0)}%',
                    style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.examTitle,
                      style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(r.examDate, style: AppTextStyles.bodySmall(context)),
                  ],
                ),
              ),
              Text('${r.score}/${r.totalQuestions}', style: AppTextStyles.bodySmall(context)),
            ],
          ),
        );
      },
    );
  }
}
