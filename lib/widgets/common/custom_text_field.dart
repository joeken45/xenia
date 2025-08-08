import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final EdgeInsetsGeometry? margin;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final String? helperText;
  final Color? fillColor;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.margin,
    this.inputFormatters,
    this.focusNode,
    this.helperText,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget textField = TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onTap: onTap,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        helperText: helperText,
        prefixIcon: prefixIcon != null
            ? Icon(
          prefixIcon,
          color: enabled ? AppColors.textSecondary : AppColors.textDisabled,
        )
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor ?? (enabled ? AppColors.surfaceVariant : Colors.grey[100]),

        // 邊框樣式
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          borderSide: BorderSide.none,
        ),

        // 內容間距
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingM,
        ),

        // 文字樣式
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
        helperStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: 12,
        ),
      ),
      style: TextStyle(
        color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
        fontSize: 16,
      ),
    );

    if (margin != null) {
      textField = Container(
        margin: margin,
        child: textField,
      );
    }

    return textField;
  }
}

// 密碼輸入框
class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const PasswordTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      labelText: widget.labelText ?? '密碼',
      hintText: widget.hintText ?? '請輸入密碼',
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      prefixIcon: Icons.lock_outlined,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}

// 數字輸入框
class NumberTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final double? minValue;
  final double? maxValue;
  final int? decimalPlaces;
  final String? suffix;

  const NumberTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.minValue,
    this.maxValue,
    this.decimalPlaces,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      keyboardType: TextInputType.numberWithOptions(
        decimal: decimalPlaces != null && decimalPlaces! > 0,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          decimalPlaces != null && decimalPlaces! > 0
              ? RegExp(r'^\d*\.?\d*')
              : RegExp(r'^\d*'),
        ),
      ],
      suffixIcon: suffix != null
          ? Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Center(
          widthFactor: 1.0,
          child: Text(
            suffix!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
      )
          : null,
      validator: validator,
      onChanged: onChanged,
    );
  }
}

// 搜尋輸入框
class SearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const SearchTextField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: hintText ?? '搜尋...',
      prefixIcon: Icons.search,
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          controller?.clear();
          onClear?.call();
        },
      )
          : null,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
    );
  }
}

// Email 輸入框
class EmailTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const EmailTextField({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: 'Email',
      hintText: '請輸入電子信箱',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      prefixIcon: Icons.email_outlined,
      validator: validator,
      onChanged: onChanged,
    );
  }
}

// 電話號碼輸入框
class PhoneTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PhoneTextField({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: '手機號碼',
      hintText: '請輸入手機號碼',
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      prefixIcon: Icons.phone_outlined,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validator: validator,
      onChanged: onChanged,
    );
  }
}

// 多行文字輸入框
class MultilineTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int maxLines;
  final int? maxLength;

  const MultilineTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.maxLines = 3,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      maxLines: maxLines,
      maxLength: maxLength,
      textInputAction: TextInputAction.newline,
      validator: validator,
      onChanged: onChanged,
    );
  }
}