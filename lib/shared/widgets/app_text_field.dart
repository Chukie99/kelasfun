import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kelasfun/core/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final IconData? suffixIcon;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final int? flex;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffix,
    this.suffixIcon,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onTap,
    this.keyboardType,
    this.flex,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget field = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
      child: SizedBox(
        height: maxLines > 1 ? null : 44,
        child: TextFormField(
          controller: controller,
          onChanged: onChanged,
          obscureText: obscureText,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: 18,
                    color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                  )
                : null,
            suffixIcon: suffix ?? (suffixIcon != null
                ? Icon(
                    suffixIcon,
                    size: 18,
                    color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                  )
                : null),
            filled: true,
            fillColor: isDark ? AppTheme.inputFill : AppTheme.lightInputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(
                color: isDark ? AppTheme.inputBorder : AppTheme.lightInputBorder,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(
                color: isDark ? AppTheme.inputBorder : AppTheme.lightInputBorder,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(
                color: isDark ? AppTheme.accent : AppTheme.lightAccent,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(
                color: isDark ? AppTheme.coral : AppTheme.lightCoral,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(
                color: isDark ? AppTheme.coral : AppTheme.lightCoral,
                width: 1.5,
              ),
            ),
            labelStyle: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
            ),
            hintStyle: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? AppTheme.textTertiary : AppTheme.lightTextTertiary,
            ),
            errorStyle: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? AppTheme.coral : AppTheme.lightCoral,
            ),
          ),
        ),
      ),
    );

    if (flex != null) {
      field = Expanded(flex: flex!, child: field);
    }

    return field;
  }
}
