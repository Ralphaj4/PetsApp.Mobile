import 'package:flutter/material.dart';
import 'package:petsapp_mobile/core/theme/app_colors.dart';

class BottomActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderRadius;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final bool isLoading;
  final bool enabled;

  const BottomActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.white,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.borderRadius = 32,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
    this.width,
    this.height,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          minimumSize: height != null
              ? Size.fromHeight(height!)
              : const Size(200, 60),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: (isLoading || !enabled) ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
              ),
      ),
    );
  }
}
