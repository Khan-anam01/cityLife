import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_spacing.dart';

class CLTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final bool enabled;
  final int maxLines;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;

  const CLTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixWidget,
    this.enabled = true,
    this.maxLines = 1,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<CLTextField> createState() => _CLTextFieldState();
}

class _CLTextFieldState extends State<CLTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.labelMedium.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          enabled: widget.enabled,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          textInputAction: widget.textInputAction,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    size: AppSpacing.iconSm,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textTertiary,
                  )
                : null,
            suffixIcon: widget.isPassword
                ? GestureDetector(
                    onTap: () => setState(() => _obscureText = !_obscureText),
                    child: Icon(
                      _obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: AppSpacing.iconSm,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textTertiary,
                    ),
                  )
                : widget.suffixWidget,
          ),
        ),
      ],
    );
  }
}
