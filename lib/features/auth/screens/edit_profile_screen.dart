import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Personal ──────────────────────────────────
  final _fullNameController = TextEditingController();
  String _gender = 'male';
  String _religion = 'islam';

  // ── Academic ──────────────────────────────────
  String _studentClass = '3';
  String _shift = 'morning';
  final _schoolController = TextEditingController();

  // ── Family ────────────────────────────────────
  final _fatherNameController = TextEditingController();
  final _fatherMobileController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _motherMobileController = TextEditingController();
  final _notificationMobileController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _schoolController.dispose();
    _fatherNameController.dispose();
    _fatherMobileController.dispose();
    _motherNameController.dispose();
    _motherMobileController.dispose();
    _notificationMobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    final user = ref.read(authProvider).user;
    if (user != null) {
      _fullNameController.text = user.fullName;
      _gender = user.gender.isNotEmpty ? user.gender : 'male';
      _religion = user.religion.isNotEmpty ? user.religion : 'islam';
      _studentClass = user.studentClass.isNotEmpty ? user.studentClass : '3';
      _shift = user.shift.isNotEmpty ? user.shift : 'morning';
      _schoolController.text = user.school;
      _fatherNameController.text = user.fatherName;
      _fatherMobileController.text = user.fatherMobile;
      _motherNameController.text = user.motherName;
      _motherMobileController.text = user.motherMobile;
      _notificationMobileController.text = user.notificationMobile;
      _addressController.text = user.address;
    }
  }

  Future<void> _handleSave() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    try {
      await ref.read(authProvider.notifier).updateProfile(
        fullName: _fullNameController.text.trim(),
        fatherName: _fatherNameController.text.trim(),
        fatherMobile: _fatherMobileController.text.trim(),
        motherName: _motherNameController.text.trim(),
        motherMobile: _motherMobileController.text.trim(),
        notificationMobile: _notificationMobileController.text.trim(),
        gender: _gender,
        religion: _religion,
        studentClass: _studentClass,
        shift: _shift,
        school: _schoolController.text.trim(),
        address: _addressController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).profileSaved)),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      appBar: AppAppBar(
        title: l10n.editProfile,
        trailing: GestureDetector(
          onTap: _handleSave,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: AppRadius.small,
            ),
            child: Text(
              l10n.save,
              style: AppTextStyles.buttonMedium(context),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.medium,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppColors.primary,
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
                Tab(text: l10n.personal),
                Tab(text: l10n.family),
              ],
            ),
          ),

          // ── Tab Bar View ────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(l10n),
                _buildFamilyTab(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  TAB 1 — Profile (Personal + Academic)
  // ═══════════════════════════════════════════════
  Widget _buildProfileTab(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Personal Section ───────────────────
          _buildSectionHeader(l10n.personal, Icons.person_outline_rounded),
          const SizedBox(height: AppSpacing.lg),

          AppTextField(
            controller: _fullNameController,
            label: l10n.fullName,
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.enterFullName;
              if (v.length < 3) return l10n.nameMinLength;
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Gender ─────────────────────────────
          Text(
            l10n.gender,
            style: AppTextStyles.label(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
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

          // ── Religion ───────────────────────────
          Text(
            l10n.religion,
            style: AppTextStyles.label(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildChoiceChip(
                label: l10n.islam,
                isSelected: _religion == 'islam',
                onTap: () => setState(() => _religion = 'islam'),
              ),
              _buildChoiceChip(
                label: l10n.hinduism,
                isSelected: _religion == 'hinduism',
                onTap: () => setState(() => _religion = 'hinduism'),
              ),
              _buildChoiceChip(
                label: l10n.christianity,
                isSelected: _religion == 'christianity',
                onTap: () => setState(() => _religion = 'christianity'),
              ),
              _buildChoiceChip(
                label: l10n.buddhism,
                isSelected: _religion == 'buddhism',
                onTap: () => setState(() => _religion = 'buddhism'),
              ),
              _buildChoiceChip(
                label: l10n.other,
                isSelected: _religion == 'other',
                onTap: () => setState(() => _religion = 'other'),
              ),
            ],
          ),

          // ── Divider ────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
            child: Divider(height: 1),
          ),

          // ── Academic Section ───────────────────
          _buildSectionHeader(l10n.academic, Icons.school_outlined),
          const SizedBox(height: AppSpacing.lg),

          // ── Class ──────────────────────────────
          Text(
            l10n.classLevel,
            style: AppTextStyles.label(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildChoiceChip(
                label: l10n.classThree,
                isSelected: _studentClass == '3',
                onTap: () => setState(() => _studentClass = '3'),
              ),
              _buildChoiceChip(
                label: l10n.classFour,
                isSelected: _studentClass == '4',
                onTap: () => setState(() => _studentClass = '4'),
              ),
              _buildChoiceChip(
                label: l10n.classFive,
                isSelected: _studentClass == '5',
                onTap: () => setState(() => _studentClass = '5'),
              ),
              _buildChoiceChip(
                label: l10n.classSix,
                isSelected: _studentClass == '6',
                onTap: () => setState(() => _studentClass = '6'),
              ),
              _buildChoiceChip(
                label: l10n.classSeven,
                isSelected: _studentClass == '7',
                onTap: () => setState(() => _studentClass = '7'),
              ),
              _buildChoiceChip(
                label: l10n.classEight,
                isSelected: _studentClass == '8',
                onTap: () => setState(() => _studentClass = '8'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Shift ──────────────────────────────
          Text(
            l10n.shift,
            style: AppTextStyles.label(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
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

          // ── School ─────────────────────────────
          AppTextField(
            controller: _schoolController,
            label: l10n.school,
            prefixIcon: const Icon(Icons.school_outlined, size: 20),
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  TAB 2 — Family & Contact
  // ═══════════════════════════════════════════════
  Widget _buildFamilyTab(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Father ─────────────────────────────
          _buildSectionHeader(l10n.father, Icons.account_circle_rounded),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _fatherNameController,
            label: l10n.fatherName,
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _fatherMobileController,
            label: l10n.fatherMobile,
            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Mother ─────────────────────────────
          _buildSectionHeader(l10n.mother, Icons.account_circle_rounded),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _motherNameController,
            label: l10n.motherName,
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _motherMobileController,
            label: l10n.motherMobile,
            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Notification Mobile ─────────────────
          _buildSectionHeader(l10n.notification, Icons.notifications_outlined),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _notificationMobileController,
            label: l10n.notificationMobile,
            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Address ────────────────────────────
          _buildSectionHeader(l10n.address, Icons.location_on_outlined),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _addressController,
            label: l10n.fullAddress,
            prefixIcon: const Icon(Icons.home_outlined, size: 20),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: AppSpacing.xxxxxl),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  Shared Widgets
  // ═══════════════════════════════════════════════
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.h3(context).copyWith(fontSize: 16),
        ),
      ],
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
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceFor(context),
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
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textTertiaryFor(context),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.label(context).copyWith(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondaryFor(context),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
