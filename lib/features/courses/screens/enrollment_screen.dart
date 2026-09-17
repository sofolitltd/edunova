import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text_styles.dart';
import '../../../shared/widgets/app_app_bar.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/course_service.dart';

class EnrollmentScreen extends ConsumerStatefulWidget {
  final int courseId;
  final String courseName;
  final String courseTitleBn;
  final int price;
  final String type;

  const EnrollmentScreen({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.courseTitleBn,
    required this.price,
    required this.type,
  });

  @override
  ConsumerState<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends ConsumerState<EnrollmentScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Step 0: User Info
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Step 1: Family Info (offline only)
  final _fatherNameController = TextEditingController();
  final _fatherMobileController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _motherMobileController = TextEditingController();
  final _notificationMobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _familyFormKey = GlobalKey<FormState>();

  // Payment
  String _selectedPayment = '';
  String _selectedMobileBanking = '';
  final _sentFromController = TextEditingController();

  bool get _isOffline => widget.type == 'offline';
  int get _totalSteps => _isOffline ? 4 : 3;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nameController.text = user.fullName;
      _mobileController.text = user.mobile;
      _fatherNameController.text = user.fatherName;
      _fatherMobileController.text = user.fatherMobile;
      _motherNameController.text = user.motherName;
      _motherMobileController.text = user.motherMobile;
      _notificationMobileController.text = user.notificationMobile;
      _addressController.text = user.address;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _fatherNameController.dispose();
    _fatherMobileController.dispose();
    _motherNameController.dispose();
    _motherMobileController.dispose();
    _notificationMobileController.dispose();
    _addressController.dispose();
    _sentFromController.dispose();
    super.dispose();
  }

  static const List<Map<String, String>> _paymentMethods = [
    {'value': 'bkash', 'label': 'bKash', 'icon': '💎'},
    {'value': 'nagad', 'label': 'Nagad', 'icon': '🟠'},
    {'value': 'rocket', 'label': 'Rocket', 'icon': '🚀'},
    {'value': 'cash', 'label': 'ক্যাশ', 'icon': '💵'},
    {'value': 'card', 'label': 'কার্ড', 'icon': '💳'},
  ];

  static const List<Map<String, String>> _mobileBankingOptions = [
    {'value': 'bkash', 'label': 'bKash'},
    {'value': 'nagad', 'label': 'Nagad'},
    {'value': 'rocket', 'label': 'Rocket'},
  ];

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) return;
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1 && _isOffline) {
      if (!_familyFormKey.currentState!.validate()) return;
      _saveFamilyInfo();
      setState(() => _currentStep = 2);
    } else if (_currentStep == (_isOffline ? 2 : 1)) {
      if (_selectedPayment.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('পেমেন্ট পদ্ধতি নির্বাচন করুন')),
        );
        return;
      }
      if (widget.type != 'free' && _selectedPayment != 'cash' && _selectedPayment != 'card') {
        if (_selectedMobileBanking.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('মোবাইল ব্যাংকিং সিলেক্ট করুন')),
          );
          return;
        }
      }
      _submitEnrollment();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _saveFamilyInfo() {
    try {
      ref.read(authProvider.notifier).updateProfile(
            fullName: _nameController.text.trim(),
            fatherName: _fatherNameController.text.trim(),
            fatherMobile: _fatherMobileController.text.trim(),
            motherName: _motherNameController.text.trim(),
            motherMobile: _motherMobileController.text.trim(),
            notificationMobile: _notificationMobileController.text.trim(),
            address: _addressController.text.trim(),
          );
    } catch (_) {}
  }

  Future<void> _submitEnrollment() async {
    setState(() => _isSubmitting = true);

    try {
      final service = CourseService();
      await service.enroll(
        courseId: widget.courseId,
        fullName: _nameController.text.trim(),
        mobile: _mobileController.text.trim(),
        amount: widget.price,
      );
      setState(() {
        _isSubmitting = false;
        _currentStep = _totalSteps - 1;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('এনরোলমেন্ট ব্যর্থ: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: 'এনরোলমেন্ট',
        showBackButton: _currentStep < 2,
      ),
      body: Column(
        children: [
          // ── Step Indicator ────────────────
          if (_currentStep < _totalSteps - 1) _buildStepIndicator(),

          // ── Content ──────────────────────
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildUserInfoStep(),
                if (_isOffline) _buildFamilyInfoStep(),
                _buildPaymentStep(),
                _buildSuccessStep(),
              ],
            ),
          ),

          // ── Bottom Button ─────────────────
          if (_currentStep < _totalSteps - 1) _buildBottomButton(),
        ],
      ),
    );
  }

  // ── Step Indicator ──────────────────────
  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Theme.of(context).cardColor,
      child: _isOffline
          ? Row(
              children: [
                _stepDot(1, _currentStep >= 0, 'তথ্য'),
                _stepLine(_currentStep >= 1),
                _stepDot(2, _currentStep >= 1, 'পরিবার'),
                _stepLine(_currentStep >= 2),
                _stepDot(3, _currentStep >= 2, 'পেমেন্ট'),
                _stepLine(_currentStep >= 3),
                _stepDot(4, _currentStep >= 3, 'সম্পন্ন'),
              ],
            )
          : Row(
              children: [
                _stepDot(1, _currentStep >= 0, 'তথ্য'),
                _stepLine(_currentStep >= 1),
                _stepDot(2, _currentStep >= 1, 'পেমেন্ট'),
                _stepLine(_currentStep >= 2),
                _stepDot(3, _currentStep >= 2, 'সম্পন্ন'),
              ],
            ),
    );
  }

  Widget _stepDot(int step, bool isActive, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.gradientPrimary : null,
            color: isActive ? null : AppColors.borderFor(context),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isActive && _currentStep >= 1
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.textTertiaryFor(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.primary : AppColors.textTertiaryFor(context),
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.borderFor(context),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  // ── Step 1: User Info ───────────────────
  Widget _buildUserInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // Course Summary
            _buildCourseSummary(),
            const SizedBox(height: AppSpacing.xxl),

            Text('আপনার তথ্য', style: AppTextStyles.h3(context)),
            const SizedBox(height: AppSpacing.lg),

            AppTextField(
              controller: _nameController,
              label: 'পুরো নাম',
              prefixIcon: Icon(Icons.person_rounded, size: 20,
                  color: AppColors.textTertiaryFor(context)),
              keyboardType: TextInputType.name,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'নাম দিন';
                if (v.trim().length < 3) return 'নাম কমপক্ষে ৩ অক্ষর';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            AppTextField(
              controller: _mobileController,
              label: 'মোবাইল নম্বর',
              prefixIcon: Icon(Icons.phone_rounded, size: 20,
                  color: AppColors.textTertiaryFor(context)),
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'মোবাইল নম্বর দিন';
                if (v.trim().length < 10) return 'সঠিক মোবাইল নম্বর দিন';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Family Info (offline only) ──
  Widget _buildFamilyInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Form(
        key: _familyFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.warning),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'অফলাইন কোর্সের জন্য পরিবারের তথ্য আবশ্যক',
                      style: AppTextStyles.bodySmall(context).copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Father
            _buildSectionHeader('বাবা', Icons.account_circle_rounded),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _fatherNameController,
              label: 'বাবার নাম',
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'বাবার নাম দিন';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _fatherMobileController,
              label: 'বাবার মোবাইল',
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'বাবার মোবাইল দিন';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Mother
            _buildSectionHeader('মা', Icons.account_circle_rounded),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _motherNameController,
              label: 'মায়ের নাম',
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'মায়ের নাম দিন';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _motherMobileController,
              label: 'মায়ের মোবাইল',
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Notification & Address
            _buildSectionHeader('যোগাযোগ', Icons.notifications_outlined),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _notificationMobileController,
              label: 'নোটিফিকেশন মোবাইল',
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _addressController,
              label: 'পুরো ঠিকানা',
              prefixIcon: const Icon(Icons.home_outlined, size: 20),
              textInputAction: TextInputAction.done,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'ঠিকানা দিন';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xxxxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(title, style: AppTextStyles.h3(context).copyWith(fontSize: 16)),
      ],
    );
  }

  // ── Step 2: Payment ─────────────────────
  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),

          // Amount
          if (widget.type != 'free') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'পেমেন্ট পরিমাণ',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '৳${widget.price}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          Text('পেমেন্ট পদ্ধতি', style: AppTextStyles.h3(context)),
          const SizedBox(height: AppSpacing.md),

          // Payment Methods Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemCount: _paymentMethods.length,
            itemBuilder: (context, index) {
              final method = _paymentMethods[index];
              final isSelected = _selectedPayment == method['value'];

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedPayment = method['value']!;
                    _selectedMobileBanking = '';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.borderFor(context),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(method['icon']!, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 6),
                      Text(
                        method['label']!,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textPrimaryFor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Mobile Banking Options (show if bkash/nagad/rocket selected)
          if (widget.type != 'free' &&
              _selectedPayment != 'cash' &&
              _selectedPayment != 'card' &&
              _selectedPayment.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Text('মোবাইল ব্যাংকিং', style: AppTextStyles.h3(context)),
            const SizedBox(height: AppSpacing.md),
            ..._mobileBankingOptions.map((option) {
              final isSelected = _selectedMobileBanking == option['value'];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedMobileBanking = option['value']!);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.borderFor(context),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.textTertiaryFor(context),
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        option['label']!,
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // Sent From
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _sentFromController,
              label: 'যে নম্বর থেকে পাঠানো হয়েছে',
              prefixIcon: Icon(Icons.send_rounded, size: 20,
                  color: AppColors.textTertiaryFor(context)),
              keyboardType: TextInputType.phone,
            ),
          ],
        ],
      ),
    );
  }

  // ── Step 3: Success ─────────────────────
  Widget _buildSuccessStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Checkmark
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.success, AppColors.success.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),

            Text(
              'এনরোলমেন্ট সম্পন্ন!',
              style: AppTextStyles.h1(context).copyWith(color: AppColors.success),
            ),
            const SizedBox(height: AppSpacing.md),

            Text(
              'আপনার এনরোলমেন্ট সফলভাবে জমা দেওয়া হয়েছে।\nঅ্যাডমিন অনুমোদনের পর আপনি কোর্সে প্রবেশ করতে পারবেন।',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textSecondaryFor(context),
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Enrollment Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  _detailRow('কোর্স', widget.courseTitleBn.isNotEmpty ? widget.courseTitleBn : widget.courseName),
                  const SizedBox(height: 8),
                  if (widget.type != 'free')
                    _detailRow('পরিমাণ', '৳${widget.price}'),
                  if (widget.type != 'free')
                    const SizedBox(height: 8),
                  _detailRow('নাম', _nameController.text.trim()),
                  const SizedBox(height: 8),
                  _detailRow('মোবাইল', _mobileController.text.trim()),
                  if (_selectedPayment.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _detailRow('পেমেন্ট', _selectedPayment.toUpperCase()),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            AppButton(
              text: 'হোমে ফিরুন',
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall(context).copyWith(
            color: AppColors.textSecondaryFor(context),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  // ── Course Summary ──────────────────────
  Widget _buildCourseSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.courseTitleBn.isNotEmpty ? widget.courseTitleBn : widget.courseName,
                  style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.type == 'free' ? 'ফ্রী কোর্স' : '৳${widget.price}',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: widget.type == 'free' ? AppColors.success : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Button ───────────────────────
  Widget _buildBottomButton() {
    final isFirstStep = _currentStep == 0;
    final isLastInputStep = _isOffline ? _currentStep == 2 : _currentStep == 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (!isFirstStep)
              Expanded(
                child: AppButton(
                  text: 'পূর্ববর্তী',
                  variant: AppButtonVariant.outline,
                  onPressed: _prevStep,
                ),
              ),
            if (!isFirstStep) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: AppButton(
                text: isLastInputStep ? 'এনরোল করুন' : 'পরবর্তী',
                isLoading: _isSubmitting,
                isDisabled: _isSubmitting,
                onPressed: _nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
