import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  bool _saving = false;

  // ── Personal ──────────────────────────────────
  String _gender = '';
  String _religion = '';

  // ── Academic ──────────────────────────────────
  String _studentClass = '';
  String _shift = '';
  final _schoolController = TextEditingController();

  // ── Family ────────────────────────────────────
  final _fatherNameController = TextEditingController();
  final _fatherMobileController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _motherMobileController = TextEditingController();

  // ── Address ───────────────────────────────────
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Class is already captured at registration — pre-fill so it doesn't
    // need to be picked again here.
    final user = ref.read(authProvider).user;
    if (user != null && user.studentClass.isNotEmpty) {
      _studentClass = user.studentClass;
    }
  }

  @override
  void dispose() {
    _schoolController.dispose();
    _fatherNameController.dispose();
    _fatherMobileController.dispose();
    _motherNameController.dispose();
    _motherMobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _gender.isNotEmpty &&
      _religion.isNotEmpty &&
      _studentClass.isNotEmpty &&
      _shift.isNotEmpty &&
      _schoolController.text.trim().isNotEmpty &&
      _fatherNameController.text.trim().isNotEmpty &&
      _fatherMobileController.text.trim().isNotEmpty &&
      _addressController.text.trim().isNotEmpty;

  Future<void> _handleComplete() async {
    if (!_isValid) return;

    setState(() => _saving = true);
    try {
      final user = ref.read(authProvider).user;
      await ref.read(authProvider.notifier).updateProfile(
            fullName: user?.fullName ?? '',
            gender: _gender,
            religion: _religion,
            studentClass: _studentClass,
            shift: _shift,
            school: _schoolController.text.trim(),
            fatherName: _fatherNameController.text.trim(),
            fatherMobile: _fatherMobileController.text.trim(),
            motherName: _motherNameController.text.trim(),
            motherMobile: _motherMobileController.text.trim(),
            address: _addressController.text.trim(),
          );
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('সেভ হয়নি: $e'), backgroundColor: AppColors.error),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.read(authProvider).user;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.backgroundFor(context),
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal, vertical: AppSpacing.xl),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: AppRadius.medium,
                      ),
                      child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('স্বাগতম!', style: AppTextStyles.h2(context)),
                          Text('আপনার প্রোফাইল সম্পূর্ণ করুন', style: AppTextStyles.bodySmall(context)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable Form ─────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Name (read-only) ─────────────
                      Text(l10n.fullName, style: AppTextStyles.label(context).copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withValues(alpha: 0.08),
                          borderRadius: AppRadius.medium,
                          border: Border.all(color: AppColors.borderFor(context)),
                        ),
                        child: Text(user?.fullName ?? '', style: AppTextStyles.bodyMedium(context)),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── Gender ─────────────────────
                      Text(l10n.gender, style: AppTextStyles.label(context).copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChoiceChip(
                              label: l10n.male,
                              icon: Icons.male_rounded,
                              isSelected: _gender == 'male',
                              onTap: () => setState(() => _gender = 'male'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _buildChoiceChip(
                              label: l10n.female,
                              icon: Icons.female_rounded,
                              isSelected: _gender == 'female',
                              onTap: () => setState(() => _gender = 'female'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── Religion ───────────────────
                      Text(l10n.religion, style: AppTextStyles.label(context).copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _buildChoiceChip(label: l10n.islam, isSelected: _religion == 'islam', onTap: () => setState(() => _religion = 'islam')),
                          _buildChoiceChip(label: l10n.hinduism, isSelected: _religion == 'hinduism', onTap: () => setState(() => _religion = 'hinduism')),
                          _buildChoiceChip(label: l10n.christianity, isSelected: _religion == 'christianity', onTap: () => setState(() => _religion = 'christianity')),
                          _buildChoiceChip(label: l10n.buddhism, isSelected: _religion == 'buddhism', onTap: () => setState(() => _religion = 'buddhism')),
                          _buildChoiceChip(label: l10n.other, isSelected: _religion == 'other', onTap: () => setState(() => _religion = 'other')),
                        ],
                      ),

                      // ── Divider ────────────────────
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                        child: Divider(height: 1),
                      ),

                      // ── Class ──────────────────────
                      Text(l10n.classLevel, style: AppTextStyles.label(context).copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          _buildChoiceChip(label: l10n.classThree, isSelected: _studentClass == '3', onTap: () => setState(() => _studentClass = '3')),
                          _buildChoiceChip(label: l10n.classFour, isSelected: _studentClass == '4', onTap: () => setState(() => _studentClass = '4')),
                          _buildChoiceChip(label: l10n.classFive, isSelected: _studentClass == '5', onTap: () => setState(() => _studentClass = '5')),
                          _buildChoiceChip(label: l10n.classSix, isSelected: _studentClass == '6', onTap: () => setState(() => _studentClass = '6')),
                          _buildChoiceChip(label: l10n.classSeven, isSelected: _studentClass == '7', onTap: () => setState(() => _studentClass = '7')),
                          _buildChoiceChip(label: l10n.classEight, isSelected: _studentClass == '8', onTap: () => setState(() => _studentClass = '8')),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── Shift ──────────────────────
                      Text(l10n.shift, style: AppTextStyles.label(context).copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChoiceChip(
                              label: l10n.morning,
                              icon: Icons.wb_sunny_rounded,
                              isSelected: _shift == 'morning',
                              onTap: () => setState(() => _shift = 'morning'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _buildChoiceChip(
                              label: l10n.day,
                              icon: Icons.brightness_5_rounded,
                              isSelected: _shift == 'day',
                              onTap: () => setState(() => _shift = 'day'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── School ─────────────────────
                      Text(l10n.school, style: AppTextStyles.label(context).copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      _buildTextField(
                        controller: _schoolController,
                        hintText: 'আপনার স্কুলের নাম',
                        icon: Icons.school_outlined,
                      ),

                      // ── Divider ────────────────────
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                        child: Divider(height: 1),
                      ),

                      // ── Family ─────────────────────
                      Text(l10n.fatherName, style: AppTextStyles.label(context).copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      _buildTextField(
                        controller: _fatherNameController,
                        hintText: l10n.fatherName,
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text(l10n.fatherMobile, style: AppTextStyles.label(context).copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      _buildTextField(
                        controller: _fatherMobileController,
                        hintText: l10n.fatherMobile,
                        icon: Icons.call_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text(l10n.motherName, style: AppTextStyles.label(context).copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      _buildTextField(
                        controller: _motherNameController,
                        hintText: l10n.motherName,
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text(l10n.motherMobile, style: AppTextStyles.label(context).copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      _buildTextField(
                        controller: _motherMobileController,
                        hintText: l10n.motherMobile,
                        icon: Icons.call_outlined,
                        keyboardType: TextInputType.phone,
                      ),

                      // ── Divider ────────────────────
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                        child: Divider(height: 1),
                      ),

                      // ── Address ────────────────────
                      Text(l10n.address, style: AppTextStyles.label(context).copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      _buildTextField(
                        controller: _addressController,
                        hintText: l10n.address,
                        icon: Icons.location_on_outlined,
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSpacing.xxxxxl),
                    ],
                  ),
                ),
              ),

              // ── Bottom Button ───────────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
                decoration: BoxDecoration(
                  color: AppColors.surfaceFor(context),
                  border: Border(top: BorderSide(color: AppColors.borderFor(context))),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saving || !_isValid ? null : _handleComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.textSecondary.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
                    ),
                    child: _saving
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(
                            'সম্পন্ন',
                            style: AppTextStyles.bodyLarge(context).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: AppColors.surfaceFor(context),
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
    );
  }

  Widget _buildChoiceChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceFor(context),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderFor(context),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.textTertiaryFor(context)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.label(context).copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondaryFor(context),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
