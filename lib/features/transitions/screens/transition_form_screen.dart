import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../services/transitions_service.dart';

class TransitionFormScreen extends ConsumerStatefulWidget {
  const TransitionFormScreen({super.key});

  @override
  ConsumerState<TransitionFormScreen> createState() => _TransitionFormScreenState();
}

class _TransitionFormScreenState extends ConsumerState<TransitionFormScreen> {
  final _service = TransitionsService();
  final _gpaController = TextEditingController();
  final _notesController = TextEditingController();
  int? _fromClass;
  int? _toClass;
  bool _loading = false;
  bool _submitted = false;

  List<StudentTransition> _pastTransitions = [];
  List<StudentFeedback> _feedbacks = [];

  static const _classes = [3, 4, 5, 6, 7, 8];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final storage = SecureStorageService();
    final token = await storage.readToken();
    try {
      final transitions = await _service.getMyTransitions(token: token);
      final feedbacks = await _service.getMyFeedback(token: token);
      if (mounted) setState(() { _pastTransitions = transitions; _feedbacks = feedbacks; });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'বার্ষিক ট্রানজিশন'),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form
            if (!_submitted) ...[
              // From class
              Text('Current Class', style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _classes.map((c) {
                  final selected = _fromClass == c;
                  return GestureDetector(
                    onTap: () => setState(() => _fromClass = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surfaceFor(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? AppColors.primary : AppColors.borderFor(context)),
                      ),
                      child: Text('Class $c', style: TextStyle(
                        color: selected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // To class
              Text('Next Class', style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _classes.where((c) => _fromClass == null || c > _fromClass!).map((c) {
                  final selected = _toClass == c;
                  return GestureDetector(
                    onTap: () => setState(() => _toClass = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surfaceFor(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? AppColors.primary : AppColors.borderFor(context)),
                      ),
                      child: Text('Class $c', style: TextStyle(
                        color: selected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // GPA
              Text('Your GPA (0.0 - 5.0)', style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _gpaController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'e.g. 4.5',
                  filled: true,
                  fillColor: AppColors.surfaceFor(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderFor(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderFor(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Notes
              Text('Result Notes (optional)', style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Any additional notes about your results...',
                  filled: true,
                  fillColor: AppColors.surfaceFor(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderFor(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.borderFor(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text('Submit Transition', style: AppTextStyles.bodyMedium(context).copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],

            // Success state
            if (_submitted) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: AppRadius.medium,
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 64, color: AppColors.success),
                    const SizedBox(height: AppSpacing.md),
                    Text('Submitted Successfully!', style: AppTextStyles.h3(context)),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Your transition feedback is being generated.', style: AppTextStyles.bodySmall(context), textAlign: TextAlign.center),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],

            // Past feedback
            if (_feedbacks.isNotEmpty) ...[
              Text('Your Feedback', style: AppTextStyles.h3(context)),
              const SizedBox(height: AppSpacing.lg),
              ..._feedbacks.map((f) => _buildFeedbackCard(f)),
              const SizedBox(height: AppSpacing.xxl),
            ],

            // Past transitions
            if (_pastTransitions.isNotEmpty) ...[
              Text('Transition History', style: AppTextStyles.h3(context)),
              const SizedBox(height: AppSpacing.lg),
              ..._pastTransitions.map((t) => _buildTransitionCard(t)),
            ],
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildFeedbackCard(StudentFeedback feedback) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.borderFor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeedbackSection('Strengths', feedback.strengths, AppColors.success),
          const SizedBox(height: AppSpacing.md),
          _buildFeedbackSection('Areas to Improve', feedback.improvements, AppColors.warning),
          const SizedBox(height: AppSpacing.md),
          _buildFeedbackSection('Recommendations', feedback.recommendations, AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(String title, String content, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        Text(content, style: AppTextStyles.bodySmall(context).copyWith(height: 1.6)),
      ],
    );
  }

  Widget _buildTransitionCard(StudentTransition transition) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.borderFor(context)),
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
            child: Center(
              child: Text('${transition.gpa.toStringAsFixed(1)}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Class ${transition.fromClass} → Class ${transition.toClass}', style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600)),
                Text(transition.submittedAt, style: AppTextStyles.bodySmall(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_fromClass == null || _toClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both classes'), backgroundColor: AppColors.error),
      );
      return;
    }

    final gpa = double.tryParse(_gpaController.text);
    if (gpa == null || gpa < 0 || gpa > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid GPA (0.0-5.0)'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _loading = true);
    final storage = SecureStorageService();
    final token = await storage.readToken();

    try {
      await _service.submitTransition(
        fromClass: _fromClass!,
        toClass: _toClass!,
        gpa: gpa,
        resultNotes: _notesController.text,
        token: token,
      );
      if (mounted) {
        setState(() { _submitted = true; _loading = false; });
        _loadHistory();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  void dispose() {
    _gpaController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
