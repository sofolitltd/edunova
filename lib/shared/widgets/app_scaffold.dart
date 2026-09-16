import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.body,
    this.appBar,
    this.extendBodyBehindAppBar = false,
    this.padding,
    this.backgroundColor,
    this.bottomNavigationBar,
  });

  final Widget? body;
  final PreferredSizeWidget? appBar;
  final bool extendBodyBehindAppBar;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: AppColors.backgroundFor(context),
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor ?? AppColors.backgroundFor(context),
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        appBar: appBar,
        body: Container(
          decoration: BoxDecoration(
            gradient: AppColors.gradientBackgroundFor(context),
          ),
          child: padding != null
              ? Padding(padding: padding!, child: body)
              : body,
        ),
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}