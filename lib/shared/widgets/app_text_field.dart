import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_spacing.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    this.autofillHints,
    this.inputFormatters,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final List<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animController;
  final _fieldKey = GlobalKey<FormFieldState>();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _animController.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (_focusNode.hasFocus) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  bool get _hasError => _fieldKey.currentState?.hasError ?? false;

  Color _borderColor(BuildContext context) {
    if (_hasError) return AppColors.errorFor(context);
    if (_isFocused) return AppColors.primary;
    return AppColors.borderFor(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.primarySurface;
    final defaultSurface = isDark ? AppColors.darkSurface : AppColors.surface;
    final disabledBackground = isDark ? AppColors.darkBackground : AppColors.background;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── LABEL ──────────────────────────────────
        Text(
          widget.label,
          style: AppTextStyles.label(context).copyWith(
            color: _hasError
                ? AppColors.errorFor(context)
                : _isFocused
                    ? AppColors.primary
                    : AppColors.textSecondaryFor(context),
            fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── CONTAINER ──────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: widget.enabled
                ? (_isFocused ? surfaceColor : defaultSurface)
                : disabledBackground,
            borderRadius: AppRadius.medium,
            border: Border.all(
              color: _borderColor(context),
              width: _isFocused ? 1.5 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: (_hasError
                              ? AppColors.errorFor(context)
                              : AppColors.primary)
                          .withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  widget.prefixIcon!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: TextFormField(
                    key: _fieldKey,
                    controller: widget.controller,
                    focusNode: _focusNode,
                    keyboardType: widget.keyboardType,
                    obscureText: widget.obscureText,
                    validator: widget.validator,
                    enabled: widget.enabled,
                    textInputAction: widget.textInputAction,
                    onFieldSubmitted: widget.onFieldSubmitted,
                    onChanged: widget.onChanged,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    autofillHints: widget.autofillHints,
                    inputFormatters: widget.inputFormatters,
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      color: widget.enabled
                          ? AppColors.textPrimaryFor(context)
                          : AppColors.textTertiaryFor(context),
                    ),
                    cursorColor: AppColors.primary,
                    cursorWidth: 1.5,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      errorStyle: TextStyle(height: 0, fontSize: 0),
                    ),
                  ),
                ),
                if (widget.suffixIcon != null) ...[
                  const SizedBox(width: 8),
                  widget.suffixIcon!,
                ],
              ],
            ),
          ),
        ),

        // ── VALIDATION MESSAGE ─────────────────────
        if (_hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _fieldKey.currentState?.errorText ?? '',
              style: AppTextStyles.bodySmall(context).copyWith(
                color: AppColors.errorFor(context),
              ),
            ),
          ),
      ],
    );
  }
}
