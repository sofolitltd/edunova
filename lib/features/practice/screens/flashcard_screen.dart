import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/services/secure_storage_service.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../services/practice_service.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final _service = PracticeService();
  List<VocabularyWord> _words = [];
  int _index = 0;
  bool _loading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _token = await SecureStorageService().readToken();
    final words = await _service.getFlashcards(_token);
    if (mounted) setState(() { _words = words; _loading = false; });
  }

  void _onFlipDone(bool wasFront) {
    if (wasFront) {
      HapticFeedback.selectionClick();
      _service.reviewFlashcard(_token, _words[_index].id);
    }
  }

  void _next() {
    if (_index >= _words.length - 1) return;
    HapticFeedback.lightImpact();
    setState(() => _index++);
  }

  void _prev() {
    if (_index <= 0) return;
    setState(() => _index--);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppAppBar(title: 'ফ্ল্যাশকার্ড'),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _words.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal, vertical: AppSpacing.md),
                        child: LinearProgressIndicator(
                          value: (_index + 1) / _words.length,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          backgroundColor: AppColors.borderFor(context),
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('${_index + 1} / ${_words.length}', style: AppTextStyles.bodySmall(context)),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                          child: FlipCard(
                            key: ValueKey(_index),
                            speed: 400,
                            direction: FlipDirection.HORIZONTAL,
                            onFlipDone: _onFlipDone,
                            front: _buildCardFront(),
                            back: _buildCardBack(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _index > 0 ? _prev : null,
                                icon: const Icon(Icons.arrow_back_rounded),
                                label: const Text('আগেরটা'),
                                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _index < _words.length - 1 ? _next : () => Navigator.of(context).pop(),
                                icon: Icon(_index < _words.length - 1 ? Icons.arrow_forward_rounded : Icons.check_rounded),
                                label: Text(_index < _words.length - 1 ? 'পরেরটা' : 'শেষ'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
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

  Widget _buildCardFront() {
    final word = _words[_index];
    return Container(
      key: const ValueKey('front'),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: AppRadius.large,
        boxShadow: AppShadow.primary,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(word.word, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 36), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            const Icon(Icons.touch_app_rounded, color: Colors.white70, size: 28),
            const SizedBox(height: 4),
            const Text('অর্থ দেখতে ট্যাপ করো', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    final word = _words[_index];
    return Container(
      key: const ValueKey('back'),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: AppShadow.small,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(word.word, style: AppTextStyles.h2(context).copyWith(color: AppColors.primary)),
            const SizedBox(height: AppSpacing.md),
            Text(word.meaning, style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            if (word.meaningBn.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(word.meaningBn, style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
            ],
            if (word.exampleSentence.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: AppRadius.small,
                ),
                child: Text(
                  '"${word.exampleSentence}"',
                  style: AppTextStyles.bodySmall(context).copyWith(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
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
            Icon(Icons.style_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text('এখনো কোনো শব্দ যোগ হয়নি', style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Text('তোমার ক্লাসের জন্য শীঘ্রই নতুন শব্দ আসবে', style: AppTextStyles.bodySmall(context), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
