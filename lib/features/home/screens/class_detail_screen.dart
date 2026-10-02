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
import '../widgets/class_detail/class_detail_about_tab.dart';
import '../widgets/class_detail/class_detail_schedule_tab.dart';
import '../widgets/class_detail/class_detail_exam_tab.dart';
import '../widgets/class_detail/class_detail_leaderboard_tab.dart';
import '../widgets/class_detail/class_detail_result_tab.dart';
import '../widgets/class_detail/class_detail_students_tab.dart';
import '../widgets/class_detail/class_detail_notice_tab.dart';
import '../widgets/class_detail/class_detail_bill_tab.dart';
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
  List<BatchStudent> _students = [];
  List<BatchNotice> _notices = [];
  BatchPayments? _payments;
  bool _subjectsLoaded = false;
  bool _examsLoaded = false;
  bool _leaderboardLoaded = false;
  bool _myResultsLoaded = false;
  bool _studentsLoaded = false;
  bool _noticesLoaded = false;
  bool _paymentsLoaded = false;
  bool _subjectsLoading = false;
  bool _examsLoading = false;
  bool _leaderboardLoading = false;
  bool _myResultsLoading = false;
  bool _studentsLoading = false;
  bool _noticesLoading = false;
  bool _paymentsLoading = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
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
    if (_tabController.index == 5 && !_studentsLoaded && !_studentsLoading) {
      _loadStudents();
    }
    if (_tabController.index == 6 && !_noticesLoaded && !_noticesLoading) {
      _loadNotices();
    }
    if (_tabController.index == 7 && !_paymentsLoaded && !_paymentsLoading) {
      _loadPayments();
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

  Future<void> _loadStudents() async {
    setState(() => _studentsLoading = true);
    final students = await _service.getBatchStudents(_token, widget.batchId);
    if (!mounted) return;
    setState(() {
      _students = students;
      _studentsLoaded = true;
      _studentsLoading = false;
    });
  }

  Future<void> _loadNotices() async {
    setState(() => _noticesLoading = true);
    final notices = await _service.getBatchNotices(_token, widget.batchId);
    if (!mounted) return;
    setState(() {
      _notices = notices;
      _noticesLoaded = true;
      _noticesLoading = false;
    });
  }

  Future<void> _loadPayments() async {
    setState(() => _paymentsLoading = true);
    final payments = await _service.getBatchPayments(_token, widget.batchId);
    if (!mounted) return;
    setState(() {
      _payments = payments;
      _paymentsLoaded = true;
      _paymentsLoading = false;
    });
  }

  Future<void> _payFee({
    required double amount,
    required String method,
    required String transactionId,
    required String senderNumber,
    required String month,
    required int year,
  }) {
    return _service.payBatchFee(
      _token,
      widget.batchId,
      amount: amount,
      method: method,
      transactionId: transactionId,
      senderNumber: senderNumber,
      month: month,
      year: year,
    );
  }

  Future<void> _openExam(BatchExam exam) async {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final myUserId = ref.watch(authProvider).user?.id;

    return AppScaffold(
      appBar: const AppAppBar(title: 'ব্যাচ বিস্তারিত'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || _batch == null
              ? _buildError()
              : Column(
                  children: [
                    // ── Tab Bar ─────────────────────────────
                    Container(
                      color: Theme.of(context).cardColor,
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        dividerColor: Colors.transparent,
                        indicatorColor: widget.color,
                        labelColor: widget.color,
                        unselectedLabelColor: AppColors.textTertiaryFor(context),
                        labelStyle: AppTextStyles.label(context).copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                        unselectedLabelStyle: AppTextStyles.label(context).copyWith(
                          fontSize: 13,
                        ),
                        tabs: [
                          Tab(text: l10n.aboutClass),
                          Tab(text: l10n.weeklySchedule),
                          const Tab(text: 'পরীক্ষা'),
                          const Tab(text: 'লিডারবোর্ড'),
                          const Tab(text: 'ফলাফল'),
                          const Tab(text: 'শিক্ষার্থী'),
                          const Tab(text: 'নোটিস'),
                          const Tab(text: 'বিল'),
                        ],
                      ),
                    ),

                    // ── Tab Bar View ────────────────────────
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          ClassDetailAboutTab(batch: _batch!, color: widget.color),
                          ClassDetailScheduleTab(
                            batch: _batch!,
                            subjects: _subjects,
                            loading: _subjectsLoading,
                            loaded: _subjectsLoaded,
                            color: widget.color,
                          ),
                          ClassDetailExamTab(
                            exams: _exams,
                            loading: _examsLoading,
                            loaded: _examsLoaded,
                            color: widget.color,
                            onExamTap: _openExam,
                          ),
                          ClassDetailLeaderboardTab(
                            leaderboard: _leaderboard,
                            loading: _leaderboardLoading,
                            loaded: _leaderboardLoaded,
                            color: widget.color,
                            myUserId: myUserId,
                          ),
                          ClassDetailResultTab(
                            results: _myResults,
                            loading: _myResultsLoading,
                            loaded: _myResultsLoaded,
                          ),
                          ClassDetailStudentsTab(
                            students: _students,
                            loading: _studentsLoading,
                            loaded: _studentsLoaded,
                            color: widget.color,
                          ),
                          ClassDetailNoticeTab(
                            notices: _notices,
                            loading: _noticesLoading,
                            loaded: _noticesLoaded,
                            color: widget.color,
                          ),
                          ClassDetailBillTab(
                            monthlyFee: _payments?.monthlyFee ?? 0,
                            payments: _payments?.payments ?? [],
                            loading: _paymentsLoading,
                            loaded: _paymentsLoaded,
                            color: widget.color,
                            onPay: _payFee,
                            onPaid: _loadPayments,
                          ),
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
}
