import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool showMessage;
  final Color? color;
  final double size;
  final double strokeWidth;

  const LoadingWidget({
    super.key,
    this.message,
    this.showMessage = true,
    this.color,
    this.size = 40.0,
    this.strokeWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
              strokeWidth: strokeWidth,
            ),
          ),
          if (showMessage && message != null) ...[
            const SizedBox(height: AppSizes.paddingM),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// 小型載入指示器
class SmallLoadingWidget extends StatelessWidget {
  final Color? color;
  final double size;

  const SmallLoadingWidget({
    super.key,
    this.color,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primary,
        ),
        strokeWidth: 2.0,
      ),
    );
  }
}

// 覆蓋式載入
class OverlayLoadingWidget extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final Color? backgroundColor;

  const OverlayLoadingWidget({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.3),
            child: LoadingWidget(
              message: loadingMessage,
              showMessage: loadingMessage != null,
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}

// 線性載入指示器
class LinearLoadingWidget extends StatelessWidget {
  final double? value;
  final Color? backgroundColor;
  final Color? valueColor;
  final double height;

  const LinearLoadingWidget({
    super.key,
    this.value,
    this.backgroundColor,
    this.valueColor,
    this.height = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: backgroundColor ?? AppColors.surfaceVariant,
        valueColor: AlwaysStoppedAnimation<Color>(
          valueColor ?? AppColors.primary,
        ),
      ),
    );
  }
}

// 帶標題的載入頁面
class LoadingPage extends StatelessWidget {
  final String? title;
  final String? message;
  final Color? backgroundColor;

  const LoadingPage({
    super.key,
    this.title,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const LoadingWidget(size: 60.0),
                if (title != null) ...[
                  const SizedBox(height: AppSizes.paddingL),
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (message != null) ...[
                  const SizedBox(height: AppSizes.paddingM),
                  Text(
                    message!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 卡片內載入
class CardLoadingWidget extends StatelessWidget {
  final double height;
  final String? message;

  const CardLoadingWidget({
    super.key,
    this.height = 200.0,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: height,
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: LoadingWidget(
          message: message,
          showMessage: message != null,
        ),
      ),
    );
  }
}