import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/services/secure_storage_service.dart';
import '../../../exams/services/exam_service.dart';

class ExamTab extends ConsumerStatefulWidget {
  const ExamTab({super.key});

  @override
  ConsumerState<ExamTab> createState() => _ExamTabState();
}

class _ExamTabState extends ConsumerState<ExamTab> {
  final _examService = ExamService();
  List<Exam> _liveExams = [];
  List<ExamResult> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final storage = SecureStorageService();
    final token = await storage.readToken();
    try {
      final exams = await _examService.getLiveExams(token: token);
      final results = await _examService.getExamResults(token: token);
      if (mounted) {
        setState(() {
          _liveExams = exams;
          _results = results;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    Text('পরীক্ষা', style: AppTextStyles.h2(context)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'লাইভ পরীক্ষা এবং ফলাফল',
                      style: AppTextStyles.bodyMedium(context),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Stats Row
                    Row(
                      children: [
                        _buildStatChip(
                          context,
                          icon: Icons.live_tv_rounded,
                          value: '${_liveExams.length}',
                          label: 'Live',
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _buildStatChip(
                          context,
                          icon: Icons.check_circle_rounded,
                          value: '${_results.length}',
                          label: 'সম্পন্ন',
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _buildStatChip(
                          context,
                          icon: Icons.trending_up_rounded,
                          value: _results.isNotEmpty
                              ? '${(_results.map((r) => r.percentage).reduce((a, b) => a + b) / _results.length).round()}%'
                              : '0%',
                          label: 'গড়',
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Live Exams
                    if (_liveExams.isNotEmpty) ...[
                      Text(
                        'এখন লাইভ',
                        style: AppTextStyles.h3(context),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ..._liveExams.map((exam) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _buildLiveExamCard(context, exam),
                          )),
                      const SizedBox(height: AppSpacing.xxl),
                    ],

                    // Results
                    if (_results.isNotEmpty) ...[
                      Text(
                        'সাম্প্রতিক ফলাফল',
                        style: AppTextStyles.h3(context),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ..._results.map((result) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: _buildResultCard(context, result),
                          )),
                    ],

                    if (_liveExams.isEmpty && _results.isEmpty)
                      _buildEmptyState(context),

                    const SizedBox(height: AppSpacing.xxxxxl),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        children: [
          Icon(Icons.quiz_rounded, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'এখনো কোনো পরীক্ষা নেই',
            style: AppTextStyles.bodyLarge(context)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'শীঘ্রই লাইভ পরীক্ষা আসছে!',
            style: AppTextStyles.bodySmall(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.borderFor(context)),
          boxShadow: AppShadow.small,
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTextStyles.bodyLarge(context).copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveExamCard(BuildContext context, Exam exam) {
    return GestureDetector(
      onTap: () async {
        final storage = SecureStorageService();
        final token = await storage.readToken();
        try {
          final questions =
              await _examService.getExamQuestions(exam.id, token: token);
          if (!mounted) return;
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (_) => _ExamTakingScreen(
                      exam: exam, questions: questions, token: token)))
              .then((_) => _loadData());
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Failed: $e'),
                  backgroundColor: AppColors.error),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.medium,
          border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3)),
          boxShadow: AppShadow.small,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: AppRadius.small,
              ),
              child: const Icon(Icons.play_circle_filled_rounded,
                  size: 24, color: AppColors.error),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(exam.title,
                            style: AppTextStyles.bodyLarge(context)
                                .copyWith(fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            Text('LIVE',
                                style: AppTextStyles.label(context)
                                    .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${exam.courseName} · ${exam.totalQuestions} প্রশ্ন',
                    style: AppTextStyles.bodySmall(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, ExamResult result) {
    final color = result.percentage >= 80
        ? AppColors.success
        : result.percentage >= 50
            ? AppColors.primary
            : AppColors.warning;

    return Container(
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadius.small,
            ),
            child: Center(
              child: Text(
                '${result.percentage.round()}%',
                style: AppTextStyles.label(context).copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.examTitle,
                  style: AppTextStyles.bodyLarge(context)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${result.correctAnswers}/${result.totalQuestions} সঠিক',
                  style: AppTextStyles.bodySmall(context),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle_rounded, color: color, size: 24),
        ],
      ),
    );
  }
}

class _ExamTakingScreen extends StatefulWidget {
  final Exam exam;
  final List<ExamQuestion> questions;
  final String? token;

  const _ExamTakingScreen(
      {required this.exam, required this.questions, this.token});

  @override
  State<_ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<_ExamTakingScreen> {
  int _current = 0;
  final Map<int, String> _answers = {};
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[_current];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundFor(context),
        appBar: AppBar(
          backgroundColor: AppColors.surfaceFor(context),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _confirmExit,
          ),
          title: Text(widget.exam.title,
              style: AppTextStyles.bodyLarge(context)
                  .copyWith(fontWeight: FontWeight.w600)),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_current + 1}/${widget.questions.length}',
                  style: AppTextStyles.bodyMedium(context)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: (_current + 1) / widget.questions.length,
              backgroundColor: AppColors.borderFor(context),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        'প্রশ্ন ${_current + 1}',
                        style: AppTextStyles.label(context).copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(q.questionText, style: AppTextStyles.h3(context)),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildOption(context, 'A', q.optionA),
                    const SizedBox(height: AppSpacing.md),
                    _buildOption(context, 'B', q.optionB),
                    const SizedBox(height: AppSpacing.md),
                    _buildOption(context, 'C', q.optionC),
                    const SizedBox(height: AppSpacing.md),
                    _buildOption(context, 'D', q.optionD),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceFor(context),
                border: Border(
                    top: BorderSide(
                        color: AppColors.borderFor(context))),
              ),
              child: Row(
                children: [
                  if (_current > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            setState(() => _current--),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          side: BorderSide(
                              color:
                                  AppColors.borderFor(context)),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                        ),
                        child: Text('আগে',
                            style: AppTextStyles.bodyMedium(
                                context)),
                      ),
                    ),
                  if (_current > 0)
                    const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting
                          ? null
                          : _current <
                                  widget.questions.length - 1
                              ? () =>
                                  setState(() => _current++)
                              : _submitExam,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12)),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white))
                          : Text(
                              _current <
                                      widget.questions.length -
                                          1
                                  ? 'পরবর্তী'
                                  : 'জমা দিন',
                              style: AppTextStyles.bodyMedium(
                                      context)
                                  .copyWith(
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
      BuildContext context, String label, String text) {
    final selected =
        _answers[widget.questions[_current].id] == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _answers[widget.questions[_current].id] = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceFor(context),
          borderRadius: AppRadius.medium,
          border: Border.all(
            color:
                selected ? AppColors.primary : AppColors.borderFor(context),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.textSecondary
                        .withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(label,
                    style: AppTextStyles.label(context).copyWith(
                      color: selected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: Text(text,
                    style: AppTextStyles.bodyMedium(context))),
          ],
        ),
      ),
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('পরীক্ষা ছেড়ে যাবেন?'),
        content: const Text(
            'আপনার অগ্রগতি মুছে যাবে। নিশ্চিত?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('চালিয়ে যান')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text('বের হন',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitExam() async {
    final unanswered = widget.questions.length - _answers.length;
    if (unanswered > 0) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('জমা দিবেন?'),
          content:
              Text('$unanswered টি প্রশ্ন বাকি আছে। তবু জমা দিবেন?'),
          actions: [
            TextButton(
                onPressed: () =>
                    Navigator.of(ctx).pop(false),
                child: const Text('দেখুন')),
            TextButton(
                onPressed: () =>
                    Navigator.of(ctx).pop(true),
                child: const Text('জমা দিন')),
          ],
        ),
      );
      if (proceed != true) return;
    }

    setState(() => _submitting = true);
    try {
      await ExamService().submitExamResult(
        examId: widget.exam.id,
        answers: _answers,
        token: widget.token,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('পরীক্ষা জমা হয়েছে!'),
            backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }
}
