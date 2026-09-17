import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../services/practice_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _service = PracticeService();
  List<QuizQuestion> _questions = [];
  int _index = 0;
  int _score = 0;
  bool _loading = true;
  bool _answered = false;
  String? _selected;
  bool? _wasCorrect;
  String? _correctMeaning;
  String? _token;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _token = await SecureStorageService().readToken();
    final questions = await _service.getQuiz(_token, count: 5);
    if (mounted) setState(() { _questions = questions; _loading = false; });
  }

  Future<void> _select(String option) async {
    if (_answered) return;
    HapticFeedback.selectionClick();
    final question = _questions[_index];
    final result = await _service.submitQuizAttempt(_token, question.wordId, option);
    if (!mounted) return;
    setState(() {
      _selected = option;
      _answered = true;
      _wasCorrect = result.correct;
      _correctMeaning = result.correctMeaning;
      if (result.correct) _score++;
    });
  }

  void _next() {
    if (_index >= _questions.length - 1) {
      setState(() => _index = _questions.length);
      return;
    }
    setState(() {
      _index++;
      _answered = false;
      _selected = null;
      _wasCorrect = null;
      _correctMeaning = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'শব্দ কুইজ'),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _questions.isEmpty
                ? _buildEmptyState()
                : _index >= _questions.length
                    ? _buildSummary()
                    : _buildQuestion(),
      ),
    );
  }

  Widget _buildQuestion() {
    final question = _questions[_index];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal, vertical: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (_index + 1) / _questions.length,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  backgroundColor: AppColors.borderFor(context),
                  valueColor: const AlwaysStoppedAnimation(AppColors.warning),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text('$_score ✓', style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Text('প্রশ্ন ${_index + 1} / ${_questions.length}', style: AppTextStyles.bodySmall(context)),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
          child: Column(
            children: [
              Text('এই শব্দের সঠিক অর্থ কোনটি?', style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.md),
              Text(question.word, style: AppTextStyles.h1(context).copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            itemCount: question.options.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) => _buildOption(question.options[i]),
          ),
        ),
        if (_answered)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(_index < _questions.length - 1 ? 'পরের প্রশ্ন' : 'ফলাফল দেখো'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOption(String option) {
    Color borderColor = AppColors.borderFor(context);
    Color? bgColor;
    IconData? icon;
    Color? iconColor;

    if (_answered) {
      if (option == _selected) {
        if (_wasCorrect == true) {
          borderColor = AppColors.success;
          bgColor = AppColors.success.withValues(alpha: 0.08);
          icon = Icons.check_circle_rounded;
          iconColor = AppColors.success;
        } else {
          borderColor = AppColors.error;
          bgColor = AppColors.error.withValues(alpha: 0.08);
          icon = Icons.cancel_rounded;
          iconColor = AppColors.error;
        }
      } else if (_wasCorrect == false && option == _correctMeaning) {
        borderColor = AppColors.success;
        bgColor = AppColors.success.withValues(alpha: 0.08);
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
      }
    }

    return GestureDetector(
      onTap: () => _select(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor ?? AppColors.surfaceFor(context),
          borderRadius: AppRadius.medium,
          border: Border.all(color: borderColor, width: bgColor != null ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Expanded(child: Text(option, style: AppTextStyles.bodyMedium(context))),
            if (icon != null) Icon(icon, color: iconColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final percent = _questions.isEmpty ? 0 : (_score / _questions.length * 100).round();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            Text('তুমি করেছো $_score/${_questions.length} টি সঠিক!', style: AppTextStyles.h2(context), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text('$percent% সঠিক উত্তর', style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => setState(() { _index = 0; _score = 0; _load(); }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('আবার খেলো'),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('হাব-এ ফিরে যাও'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text('কুইজের জন্য পর্যাপ্ত শব্দ নেই', style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text('অন্তত ৪টি শব্দ প্রয়োজন — শীঘ্রই আরও শব্দ আসবে', style: AppTextStyles.bodySmall(context), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
