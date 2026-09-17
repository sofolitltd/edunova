import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../services/exam_pdf_service.dart';
import '../services/exam_service.dart';
import 'exam_result_screen.dart';

class LiveExamsScreen extends ConsumerStatefulWidget {
  const LiveExamsScreen({super.key});

  @override
  ConsumerState<LiveExamsScreen> createState() => _LiveExamsScreenState();
}

class _LiveExamsScreenState extends ConsumerState<LiveExamsScreen> {
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

  Future<void> _downloadExamPdf(BuildContext context, Exam exam) async {
    final includeAnswers = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Download Questions'),
        content: const Text('Download with answers or without answers?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Questions Only'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('With Answers'),
          ),
        ],
      ),
    );
    if (includeAnswers == null || !mounted) return;

    final storage = SecureStorageService();
    final token = await storage.readToken();
    try {
      final questions = await _examService.getExamQuestions(exam.id, token: token);
      await ExamPdfService.shareQuestionsPdf(
        exam: exam,
        questions: questions,
        includeAnswers: includeAnswers,
      );
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
    return AppScaffold(
      appBar: const AppAppBar(title: 'লাইভ পরীক্ষা'),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),

                    if (_liveExams.isEmpty) ...[
                      _buildEmptyState(context),
                    ] else ...[
                      Text('Available Now', style: AppTextStyles.h3(context)),
                      const SizedBox(height: AppSpacing.lg),
                      ..._liveExams.map((exam) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _buildLiveExamCard(context, exam),
                      )),
                    ],

                    if (_results.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxl),
                      Text('Recent Results', style: AppTextStyles.h3(context)),
                      const SizedBox(height: AppSpacing.lg),
                      ..._results.map((result) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _buildResultCard(context, result),
                      )),
                    ],
                    const SizedBox(height: AppSpacing.xxxxxl),
                  ],
                ),
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
          Icon(Icons.live_tv_rounded, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text('No Live Exams Right Now', style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.xs),
          Text('Check back soon when an exam goes live!', style: AppTextStyles.bodySmall(context), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildLiveExamCard(BuildContext context, Exam exam) {
    return GestureDetector(
      onTap: () => _startExam(exam),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceFor(context),
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
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
              child: const Icon(Icons.play_circle_filled_rounded, size: 24, color: AppColors.error),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(exam.title, style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            Text('LIVE', style: AppTextStyles.label(context).copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${exam.courseName} · ${exam.totalQuestions} questions', style: AppTextStyles.bodySmall(context)),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _downloadExamPdf(context, exam),
              icon: Icon(Icons.download_rounded, color: AppColors.textSecondaryFor(context)),
              tooltip: 'Download',
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

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ExamResultScreen(
          examTitle: result.examTitle,
          correctAnswers: result.correctAnswers,
          totalQuestions: result.totalQuestions,
        ),
      )),
      child: Container(
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
                child: Text('${result.percentage.round()}%', style: AppTextStyles.label(context).copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(result.examTitle, style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${result.correctAnswers}/${result.totalQuestions} correct', style: AppTextStyles.bodySmall(context)),
                ],
              ),
            ),
            Icon(Icons.check_circle_rounded, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _startExam(Exam exam) async {
    final storage = SecureStorageService();
    final token = await storage.readToken();
    try {
      final questions = await _examService.getExamQuestions(exam.id, token: token);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _ExamTakingScreen(exam: exam, questions: questions, token: token),
        ),
      ).then((_) => _loadData());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load exam: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

class _ExamTakingScreen extends StatefulWidget {
  final Exam exam;
  final List<ExamQuestion> questions;
  final String? token;

  const _ExamTakingScreen({required this.exam, required this.questions, this.token});

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
      child: AppScaffold(
        appBar: AppAppBar(
          title: widget.exam.title,
          trailing: Text(
            '${_current + 1}/${widget.questions.length}',
            style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        body: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (_current + 1) / widget.questions.length,
              backgroundColor: AppColors.borderFor(context),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question number
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        'Question ${_current + 1}',
                        style: AppTextStyles.label(context).copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Question text
                    Text(q.questionText, style: AppTextStyles.h3(context)),
                    const SizedBox(height: AppSpacing.xxl),

                    // Options
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

            // Bottom bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceFor(context),
                border: Border(top: BorderSide(color: AppColors.borderFor(context))),
              ),
              child: Row(
                children: [
                  if (_current > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _current--),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.borderFor(context)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('Previous', style: AppTextStyles.bodyMedium(context)),
                      ),
                    ),
                  if (_current > 0) const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting
                          ? null
                          : _current < widget.questions.length - 1
                              ? () => setState(() => _current++)
                              : _submitExam,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _submitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_current < widget.questions.length - 1 ? 'Next' : 'Submit', style: AppTextStyles.bodyMedium(context).copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
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

  Widget _buildOption(BuildContext context, String label, String text) {
    final selected = _answers[widget.questions[_current].id] == label;

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
            color: selected ? AppColors.primary : AppColors.borderFor(context),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(label, style: AppTextStyles.label(context).copyWith(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                )),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(text, style: AppTextStyles.bodyMedium(context))),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    final exit = await AppDialog.confirm(
      context,
      title: 'Exit Exam?',
      message: 'Your progress will be lost. Are you sure?',
      confirmText: 'Exit',
      cancelText: 'Continue Exam',
      isDestructive: true,
    );
    if (exit == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _submitExam() async {
    final unanswered = widget.questions.length - _answers.length;
    if (unanswered > 0) {
      final proceed = await AppDialog.confirm(
        context,
        title: 'Submit Exam?',
        message: '$unanswered question(s) unanswered. Submit anyway?',
        confirmText: 'Submit',
        cancelText: 'Review',
      );
      if (proceed != true) return;
    }

    setState(() => _submitting = true);
    final score = widget.questions
        .where((q) => _answers[q.id] == q.correctLetter)
        .length;
    try {
      await ExamService().submitExamResult(
        examId: widget.exam.id,
        score: score,
        totalQuestions: widget.questions.length,
        token: widget.token,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ExamResultScreen(
          examTitle: widget.exam.title,
          correctAnswers: score,
          totalQuestions: widget.questions.length,
          questions: widget.questions,
          answers: _answers,
        ),
      ));
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
