import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;
  final Color? backgroundColor;
  final bool showRetryButton;

  const ErrorDisplayWidget({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.onRetry,
    this.retryText,
    this.backgroundColor,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon ?? Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSizes.paddingM),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  message!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (showRetryButton && onRetry != null) ...[
                const SizedBox(height: AppSizes.paddingL),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(retryText ?? '重試'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// 網路錯誤組件
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: '網路連線錯誤',
      message: message ?? '請檢查您的網路連線並重試',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      retryText: '重新連線',
    );
  }
}

// 數據載入錯誤
class DataLoadErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? message;

  const DataLoadErrorWidget({
    super.key,
    this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: '資料載入失敗',
      message: message ?? '無法載入資料，請稍後再試',
      icon: Icons.cloud_off,
      onRetry: onRetry,
      retryText: '重新載入',
    );
  }
}

// 權限錯誤
class PermissionErrorWidget extends StatelessWidget {
  final String permissionName;
  final VoidCallback? onRequestPermission;
  final String? message;

  const PermissionErrorWidget({
    super.key,
    required this.permissionName,
    this.onRequestPermission,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: '需要$permissionName權限',
      message: message ?? '請授予$permissionName權限以使用此功能',
      icon: Icons.security,
      onRetry: onRequestPermission,
      retryText: '授予權限',
    );
  }
}

// 設備連接錯誤
class DeviceConnectionErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? deviceName;

  const DeviceConnectionErrorWidget({
    super.key,
    this.onRetry,
    this.deviceName,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: '設備連接失敗',
      message: deviceName != null
          ? '無法連接到 $deviceName，請檢查設備是否開啟並重試'
          : '無法連接到設備，請檢查設備狀態並重試',
      icon: Icons.bluetooth_disabled,
      onRetry: onRetry,
      retryText: '重新連接',
    );
  }
}

// 空數據狀態
class EmptyDataWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyDataWidget({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSizes.paddingS),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null) ...[
              const SizedBox(height: AppSizes.paddingL),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText ?? '新增'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 搜尋無結果
class NoSearchResultsWidget extends StatelessWidget {
  final String searchTerm;
  final VoidCallback? onClearSearch;

  const NoSearchResultsWidget({
    super.key,
    required this.searchTerm,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyDataWidget(
      title: '找不到結果',
      message: '沒有找到與 "$searchTerm" 相關的結果',
      icon: Icons.search_off,
      onAction: onClearSearch,
      actionText: '清除搜尋',
    );
  }
}

// 卡片錯誤組件
class CardErrorWidget extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final double? height;

  const CardErrorWidget({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: height,
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSizes.paddingM),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSizes.paddingS),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSizes.paddingM),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('重試'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 通用錯誤處理器
class ErrorHandler {
  static Widget handleError({
    required Object error,
    StackTrace? stackTrace,
    VoidCallback? onRetry,
  }) {
    String title = '發生錯誤';
    String? message;
    IconData? icon;

    if (error.toString().contains('network') ||
        error.toString().contains('internet') ||
        error.toString().contains('connection')) {
      return NetworkErrorWidget(onRetry: onRetry);
    } else if (error.toString().contains('permission')) {
      return PermissionErrorWidget(
        permissionName: '必要',
        onRequestPermission: onRetry,
      );
    } else if (error.toString().contains('bluetooth')) {
      return DeviceConnectionErrorWidget(onRetry: onRetry);
    } else {
      return ErrorDisplayWidget(
        title: title,
        message: message ?? error.toString(),
        icon: icon,
        onRetry: onRetry,
      );
    }
  }
}