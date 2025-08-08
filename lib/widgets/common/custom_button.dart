import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final BorderSide? borderSide;
  final double? elevation;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.height,
    this.margin,
    this.borderRadius,
    this.borderSide,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? Colors.white,
        minimumSize: Size(
          isExpanded ? double.infinity : 120,
          height ?? AppSizes.buttonHeight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? AppSizes.radiusL),
          side: borderSide ?? BorderSide.none,
        ),
        elevation: elevation ?? 2,
        disabledBackgroundColor: (backgroundColor ?? AppColors.primary).withOpacity(0.6),
        disabledForegroundColor: (textColor ?? Colors.white).withOpacity(0.6),
      ),
      child: isLoading
          ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            textColor ?? Colors.white,
          ),
        ),
      )
          : Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );

    if (margin != null) {
      button = Container(
        margin: margin,
        child: button,
      );
    }

    return button;
  }
}

// 輔助按鈕變體
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: Colors.transparent,
      textColor: AppColors.primary,
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      elevation: 0,
    );
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const DangerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
    );
  }
}

class SmallButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;

  const SmallButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
      backgroundColor: backgroundColor,
      height: AppSizes.buttonHeightSmall,
      isExpanded: false,
      borderRadius: AppSizes.radiusM,
    );
  }
}