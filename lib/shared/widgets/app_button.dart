import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outline, ghost }

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
    this.height = 54,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;
  final double height;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEnabled =>
      !widget.isLoading && !widget.isDisabled && widget.onPressed != null;

  void _onTapDown(TapDownDetails _) {
    if (_isEnabled) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (_isEnabled) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (_isEnabled) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: _buildDecoration(),
          child: _buildContent(context),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.primarySurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return BoxDecoration(
          gradient: _isEnabled
              ? (_isPressed
                  ? const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                    )
                  : AppColors.gradientPrimary)
              : null,
          color: _isEnabled ? null : borderColor,
          borderRadius: AppRadius.large,
          boxShadow: _isEnabled && !_isPressed ? AppShadow.primary : [],
        );
      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: surfaceColor,
          borderRadius: AppRadius.large,
        );
      case AppButtonVariant.outline:
        return BoxDecoration(
          color: _isPressed ? surfaceColor : Colors.transparent,
          borderRadius: AppRadius.large,
          border: Border.all(
            color: _isEnabled ? AppColors.primary : borderColor,
            width: 1.5,
          ),
        );
      case AppButtonVariant.ghost:
        return BoxDecoration(
          color: _isPressed ? surfaceColor : Colors.transparent,
          borderRadius: AppRadius.large,
        );
    }
  }

  Widget _buildContent(BuildContext context) {
    final contentColor = widget.variant == AppButtonVariant.primary
        ? AppColors.textOnPrimary
        : AppColors.primary;

    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(contentColor),
          ),
        ),
      );
    }

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 20, color: contentColor),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            widget.text,
            style: AppTextStyles.buttonLarge(context).copyWith(color: contentColor),
          ),
        ],
      ),
    );
  }
}
