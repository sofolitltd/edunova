import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../services/practice_service.dart';

class SentenceScreen extends StatefulWidget {
  const SentenceScreen({super.key});

  @override
  State<SentenceScreen> createState() => _SentenceScreenState();
}

class _SentenceScreenState extends State<SentenceScreen> {
  final _service = PracticeService();
  final _controller = TextEditingController();
  List<SentenceExercise> _exercises = [];
  int _index = 0;
  bool _loading = true;
  bool _submitted = false;
  String _sampleAnswer = '';
  String? _token;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _token = await SecureStorageService().readToken();
    final exercises = await _service.getSentenceExercises(_token);
    if (mounted) setState(() { _exercises = exercises; _loading = false; });
  }

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    final exercise = _exercises[_index];
    final sample = await _service.submitSentenceAttempt(_token, exercise.id, _controller.text.trim());
    if (!mounted) return;
    setState(() { _submitted = true; _sampleAnswer = sample; });
  }

  void _next() {
    if (_index >= _exercises.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _index++;
      _submitted = false;
      _sampleAnswer = '';
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'বাক্য গঠন'),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _exercises.isEmpty
                ? _buildEmptyState()
                : _buildExercise(),
      ),
    );
  }

  Widget _buildExercise() {
    final exercise = _exercises[_index];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('অনুশীলন ${_index + 1} / ${_exercises.length}', style: AppTextStyles.bodySmall(context)),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF06B6D4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: AppRadius.medium,
              boxShadow: AppShadow.primary,
            ),
            child: Column(
              children: [
                const Text('এই শব্দ দিয়ে একটি বাক্য লেখো:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Text(exercise.prompt, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 28)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _controller,
            enabled: !_submitted,
            maxLines: 3,
            style: AppTextStyles.bodyMedium(context),
            decoration: InputDecoration(
              hintText: 'তোমার বাক্যটি এখানে লেখো...',
              filled: true,
              fillColor: AppColors.surfaceFor(context),
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: AppRadius.medium,
                borderSide: BorderSide(color: AppColors.borderFor(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.medium,
                borderSide: BorderSide(color: AppColors.borderFor(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.medium,
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!_submitted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('জমা দাও'),
              ),
            )
          else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: AppRadius.medium,
                border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_rounded, size: 18, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text('নমুনা বাক্য', style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_sampleAnswer.isNotEmpty ? _sampleAnswer : 'তোমার বাক্যটি সংরক্ষণ করা হয়েছে!', style: AppTextStyles.bodyMedium(context)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(_index < _exercises.length - 1 ? 'পরেরটা' : 'শেষ'),
              ),
            ),
          ],
        ],
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
            Icon(Icons.edit_note_rounded, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text('এখনো কোনো অনুশীলন নেই', style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text('তোমার ক্লাসের জন্য শীঘ্রই নতুন অনুশীলন আসবে', style: AppTextStyles.bodySmall(context), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
