import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../services/batch_service.dart' show BatchPayment;

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const _monthsBn = {
  'January': 'জানুয়ারি', 'February': 'ফেব্রুয়ারি', 'March': 'মার্চ', 'April': 'এপ্রিল',
  'May': 'মে', 'June': 'জুন', 'July': 'জুলাই', 'August': 'আগস্ট',
  'September': 'সেপ্টেম্বর', 'October': 'অক্টোবর', 'November': 'নভেম্বর', 'December': 'ডিসেম্বর',
};

const _statusLabelsBn = {'pending': 'বিচারাধীন', 'verified': 'পরিশোধিত', 'rejected': 'বাতিল'};

Color _statusColor(String status) {
  switch (status) {
    case 'verified':
      return AppColors.success;
    case 'rejected':
      return AppColors.error;
    default:
      return AppColors.warning;
  }
}

typedef PayFeeCallback = Future<void> Function({
  required double amount,
  required String method,
  required String transactionId,
  required String senderNumber,
  required String month,
  required int year,
});

/// "Bill" tab: pay this month's fee (manual bKash/Nagad submission, admin
/// reviews) and see the student's own payment history for this batch.
class ClassDetailBillTab extends StatelessWidget {
  const ClassDetailBillTab({
    super.key,
    required this.monthlyFee,
    required this.payments,
    required this.loading,
    required this.loaded,
    required this.color,
    required this.onPay,
    required this.onPaid,
  });

  final int monthlyFee;
  final List<BatchPayment> payments;
  final bool loading;
  final bool loaded;
  final Color color;
  final PayFeeCallback onPay;
  final VoidCallback onPaid;

  @override
  Widget build(BuildContext context) {
    if (loading && !loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final now = DateTime.now();
    final currentMonthPaid = payments.any(
      (p) => p.month == _months[now.month - 1] && p.year == now.year && p.status != 'rejected',
    );

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.xl,
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.7)],
            ),
            borderRadius: AppRadius.large,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_monthsBn[_months[now.month - 1]]} ${now.year} মাসের ফি',
                style: AppTextStyles.bodyMedium(context).copyWith(color: Colors.white.withValues(alpha: 0.85)),
              ),
              const SizedBox(height: 4),
              Text(
                '৳$monthlyFee',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.md),
              if (currentMonthPaid)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: AppRadius.medium,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'এই মাসের ফি জমা দেওয়া হয়েছে',
                        style: AppTextStyles.bodyMedium(context).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => _openPaySheet(context, now),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: color,
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
                      elevation: 0,
                    ),
                    child: Text('ফি পরিশোধ করুন', style: AppTextStyles.bodyMedium(context).copyWith(color: color, fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('পেমেন্ট ইতিহাস', style: AppTextStyles.h3(context)),
        const SizedBox(height: AppSpacing.md),
        if (payments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(
              child: Text('এখনো কোনো পেমেন্ট ইতিহাস নেই', style: AppTextStyles.bodyMedium(context)),
            ),
          )
        else
          ...payments.map((p) => Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceFor(context),
                  borderRadius: AppRadius.small,
                  border: Border.all(color: AppColors.borderFor(context)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_monthsBn[p.month] ?? p.month} ${p.year}',
                            style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${p.method.toUpperCase()} • ${p.createdAt}',
                            style: AppTextStyles.bodySmall(context),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('৳${p.amount.toStringAsFixed(0)}', style: AppTextStyles.bodyLarge(context).copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _statusColor(p.status).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            _statusLabelsBn[p.status] ?? p.status,
                            style: AppTextStyles.bodySmall(context).copyWith(
                              color: _statusColor(p.status),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  void _openPaySheet(BuildContext context, DateTime now) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _PayFeeSheet(
        monthlyFee: monthlyFee,
        defaultMonth: _months[now.month - 1],
        defaultYear: now.year,
        color: color,
        onPay: onPay,
        onPaid: onPaid,
      ),
    );
  }
}

class _PayFeeSheet extends StatefulWidget {
  const _PayFeeSheet({
    required this.monthlyFee,
    required this.defaultMonth,
    required this.defaultYear,
    required this.color,
    required this.onPay,
    required this.onPaid,
  });

  final int monthlyFee;
  final String defaultMonth;
  final int defaultYear;
  final Color color;
  final PayFeeCallback onPay;
  final VoidCallback onPaid;

  @override
  State<_PayFeeSheet> createState() => _PayFeeSheetState();
}

class _PayFeeSheetState extends State<_PayFeeSheet> {
  static const _paymentMethods = [
    {'value': 'bkash', 'label': 'bKash'},
    {'value': 'nagad', 'label': 'Nagad'},
  ];

  late String _month;
  late int _year;
  String _method = 'bkash';
  final _senderController = TextEditingController();
  final _transactionIdController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _month = widget.defaultMonth;
    _year = widget.defaultYear;
  }

  @override
  void dispose() {
    _senderController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_senderController.text.trim().isEmpty || _transactionIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('নম্বর ও ট্রানজেকশন আইডি দিন')),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.onPay(
        amount: widget.monthlyFee.toDouble(),
        method: _method,
        transactionId: _transactionIdController.text.trim(),
        senderNumber: _senderController.text.trim(),
        month: _month,
        year: _year,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onPaid();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderFor(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('ফি পরিশোধ করুন', style: AppTextStyles.h3(context)),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _month,
                      decoration: const InputDecoration(labelText: 'মাস'),
                      items: _months
                          .map((m) => DropdownMenuItem(value: m, child: Text(_monthsBn[m]!)))
                          .toList(),
                      onChanged: (v) => setState(() => _month = v ?? _month),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _year,
                      decoration: const InputDecoration(labelText: 'বছর'),
                      items: [_year - 1, _year, _year + 1]
                          .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                          .toList(),
                      onChanged: (v) => setState(() => _year = v ?? _year),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text('পরিমাণ: ৳${widget.monthlyFee}', style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.md),
              ..._paymentMethods.map((method) {
                final isSelected = _method == method['value'];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _method = method['value']!);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? widget.color.withValues(alpha: 0.08) : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? widget.color : AppColors.borderFor(context),
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
                            color: isSelected ? widget.color : Colors.transparent,
                            border: Border.all(color: isSelected ? widget.color : AppColors.textTertiaryFor(context)),
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                        ),
                        const SizedBox(width: 12),
                        Text(method['label']!, style: AppTextStyles.bodyMedium(context)),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _senderController,
                label: 'যে নম্বর থেকে পাঠানো হয়েছে',
                prefixIcon: Icon(Icons.phone_android_rounded, size: 20, color: AppColors.textTertiaryFor(context)),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _transactionIdController,
                label: 'ট্রানজেকশন আইডি',
                prefixIcon: Icon(Icons.confirmation_number_outlined, size: 20, color: AppColors.textTertiaryFor(context)),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'জমা দিন',
                  isLoading: _submitting,
                  onPressed: _submitting ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
