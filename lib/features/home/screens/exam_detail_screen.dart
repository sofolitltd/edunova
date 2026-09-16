import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

class ExamDetailScreen extends ConsumerStatefulWidget {
  final String title;
  final String date;
  final String time;
  final String duration;
  final int questions;
  final Color color;

  const ExamDetailScreen({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.duration,
    required this.questions,
    required this.color,
  });

  @override
  ConsumerState<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends ConsumerState<ExamDetailScreen> {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  final Map<int, int> _answers = {};
  Timer? _timer;
  int _secondsRemaining = 7200;

  final List<Map<String, dynamic>> _demoQuestions = [
    {
      'question': 'What is the value of π (pi) up to two decimal places?',
      'options': ['3.14', '3.16', '3.12', '3.18'],
    },
    {
      'question': 'Solve: 2x + 5 = 15. What is x?',
      'options': ['5', '7.5', '10', '2.5'],
    },
    {
      'question': 'What is the square root of 144?',
      'options': ['14', '12', '11', '13'],
    },
    {
      'question': 'If a triangle has angles 60° and 80°, what is the third angle?',
      'options': ['40°', '50°', '60°', '30°'],
    },
    {
      'question': 'What is 15% of 200?',
      'options': ['25', '35', '30', '40'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  String get _formattedTime {
    final h = _secondsRemaining ~/ 3600;
    final m = (_secondsRemaining % 3600) ~/ 60;
    final s = _secondsRemaining % 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswer = index;
      _answers[_currentQuestion] = index;
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _demoQuestions.length - 1) {
      setState(() {
        _currentQuestion++;
        _selectedAnswer = _answers[_currentQuestion];
      });
    }
  }

  void _prevQuestion() {
    if (_currentQuestion > 0) {
      setState(() {
        _currentQuestion--;
        _selectedAnswer = _answers[_currentQuestion];
      });
    }
  }

  void _submitExam() {
    _timer?.cancel();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exam submitted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final q = _demoQuestions[_currentQuestion];
    final isTimeLow = _secondsRemaining < 300;

    return AppScaffold(
      appBar: AppAppBar(
        title: widget.title,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isTimeLow
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_rounded,
                size: 16,
                color: isTimeLow ? AppColors.error : AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                _formattedTime,
                style: AppTextStyles.label(context).copyWith(
                  color: isTimeLow ? AppColors.error : AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Progress Bar ──────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n.question} ${_currentQuestion + 1} / ${_demoQuestions.length}',
                      style: AppTextStyles.label(context),
                    ),
                    Text(
                      '${_answers.length}/${_demoQuestions.length} ${l10n.answered}',
                      style: AppTextStyles.label(context).copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentQuestion + 1) / _demoQuestions.length,
                    backgroundColor: AppColors.borderFor(context),
                    valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Question ──────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceFor(context),
                      borderRadius: AppRadius.medium,
                      border: Border.all(color: AppColors.borderFor(context)),
                      boxShadow: AppShadow.medium,
                    ),
                    child: Text(
                      q['question'],
                      style: AppTextStyles.h3(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Options ──────────────────────
                  ...List.generate(q['options'].length, (i) {
                    final isSelected = _selectedAnswer == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _selectAnswer(i);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? widget.color.withValues(alpha: 0.08)
                                : AppColors.surfaceFor(context),
                            borderRadius: AppRadius.medium,
                            border: Border.all(
                              color: isSelected
                                  ? widget.color
                                  : AppColors.borderFor(context),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? widget.color
                                      : AppColors.borderFor(context),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + i),
                                    style: AppTextStyles.label(context).copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondaryFor(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Text(
                                  q['options'][i],
                                  style: AppTextStyles.bodyLarge(context).copyWith(
                                    color: isSelected
                                        ? widget.color
                                        : AppColors.textPrimaryFor(context),
                                    fontWeight:
                                        isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: widget.color,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ── Bottom Navigation ─────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            decoration: BoxDecoration(
              color: AppColors.surfaceFor(context),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentQuestion > 0)
                  Expanded(
                    child: GestureDetector(
                      onTap: _prevQuestion,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundFor(context),
                          borderRadius: AppRadius.medium,
                          border: Border.all(color: AppColors.borderFor(context)),
                        ),
                        child: Center(
                          child: Text(
                            l10n.previous,
                            style: AppTextStyles.buttonMedium(context).copyWith(
                              color: AppColors.textPrimaryFor(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_currentQuestion > 0) const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      if (_currentQuestion < _demoQuestions.length - 1) {
                        _nextQuestion();
                      } else {
                        _showSubmitDialogSheet();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: AppRadius.medium,
                        boxShadow: AppShadow.primary,
                      ),
                      child: Center(
                        child: Text(
                          _currentQuestion < _demoQuestions.length - 1
                              ? l10n.next
                              : l10n.submit,
                          style: AppTextStyles.buttonMedium(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmitDialogSheet() {
    final l10n = AppLocalizations.of(context);
    final answered = _answers.length;
    final total = _demoQuestions.length;
    final unanswered = total - answered;

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
              Icon(
                Icons.assignment_turned_in_rounded,
                size: 48,
                color: widget.color,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.submitExam,
                style: AppTextStyles.h3(ctx),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatBadge(ctx, '$answered', l10n.answered, AppColors.success),
                  const SizedBox(width: AppSpacing.lg),
                  _buildStatBadge(ctx, '$unanswered', l10n.unanswered, AppColors.error),
                ],
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
                            l10n.review,
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
                      onTap: () {
                        Navigator.pop(ctx);
                        _submitExam();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          borderRadius: AppRadius.medium,
                          boxShadow: AppShadow.primary,
                        ),
                        child: Center(
                          child: Text(
                            l10n.confirmSubmit,
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

  Widget _buildStatBadge(BuildContext ctx, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$value $label',
            style: AppTextStyles.label(ctx).copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
