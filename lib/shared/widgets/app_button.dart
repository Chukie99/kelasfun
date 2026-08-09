import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelasfun/core/theme/app_theme.dart';

enum AppButtonType { primary, secondary, danger, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonType type;
  final bool isLoading;
  final bool isOutlined;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isOutlined = false,
  });

  AppButtonType get _effectiveType {
    if (isOutlined) return AppButtonType.secondary;
    return type;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveType = _effectiveType;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (bgColor, fgColor, borderColor) = _getColors(effectiveType, isDark);

    final buttonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return bgColor.withOpacity(0.5);
        }
        if (states.contains(WidgetState.hovered)) {
          return bgColor.withOpacity(0.85);
        }
        return bgColor;
      }),
      foregroundColor: WidgetStateProperty.all(fgColor),
      side: borderColor != null ? WidgetStateProperty.all(BorderSide(color: borderColor, width: 1.5)) : null,
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingBase,
          vertical: AppTheme.spacingMd,
        ),
      ),
      elevation: WidgetStateProperty.all(0),
      textStyle: WidgetStateProperty.all(
        GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    if (isLoading) {
      return _buildLoadingButton(buttonStyle);
    }

    if (icon != null) {
      return _buildIconButton(buttonStyle);
    }

    return _buildTextButton(buttonStyle);
  }

  (Color, Color, Color?) _getColors(AppButtonType type, bool isDark) {
    switch (type) {
      case AppButtonType.primary:
        return (
          isDark ? AppTheme.accent : AppTheme.lightAccent,
          Colors.white,
          null,
        );
      case AppButtonType.secondary:
        return (
          Colors.transparent,
          isDark ? AppTheme.accent : AppTheme.lightAccent,
          isDark ? AppTheme.accent : AppTheme.lightAccent,
        );
      case AppButtonType.danger:
        return (
          isDark ? AppTheme.coral : AppTheme.lightCoral,
          Colors.white,
          null,
        );
      case AppButtonType.ghost:
        return (
          Colors.transparent,
          isDark ? AppTheme.accent : AppTheme.lightAccent,
          null,
        );
    }
  }

  Widget _buildLoadingButton(ButtonStyle buttonStyle) {
    return ElevatedButton(
      onPressed: null,
      style: buttonStyle,
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _effectiveType == AppButtonType.ghost
                ? AppTheme.accent
                : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(ButtonStyle buttonStyle) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: buttonStyle,
    );
  }

  Widget _buildTextButton(ButtonStyle buttonStyle) {
    return ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: Text(label),
    );
  }
}