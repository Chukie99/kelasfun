import 'package:flutter/material.dart';
import 'package:kelasfun/core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingBase,
        vertical: AppTheme.spacingSm,
      ),
      child: Material(
        color: isDark ? AppTheme.surface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          splashColor: Colors.transparent,
          highlightColor: isDark
              ? AppTheme.surfaceLight.withOpacity(0.5)
              : AppTheme.lightSurfaceLight.withOpacity(0.5),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
