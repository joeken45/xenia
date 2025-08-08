import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/constants.dart';
import '../../generated/l10n.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(),
        ],
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNotificationsTab(),
                  _buildSettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      title: Text(S.of(context).notifications),
      floating: true,
      snap: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, _) {
            return IconButton(
              icon: const Icon(Icons.mark_email_read),
              onPressed: notificationProvider.unreadCount > 0
                  ? () => notificationProvider.markAllAsRead()
                  : null,
            );
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'clear_all':
                _showClearAllDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear_all',
              child: Row(
                children: [
                  Icon(Icons.clear_all),
                  SizedBox(width: 8),
                  Text('清除所有通知'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(text: '通知', icon: Icon(Icons.notifications, size: 20)),
          Tab(text: '設定', icon: Icon(Icons.settings, size: 20)),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        if (notificationProvider.notifications.isEmpty) {
          return _buildEmptyNotifications();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await notificationProvider.loadNotifications();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            itemCount: notificationProvider.notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSizes.paddingS),
            itemBuilder: (context, index) {
              final notification = notificationProvider.notifications[index];
              return _buildNotificationCard(notification, notificationProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return ListView(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          children: [
            _buildSettingsSection(
              title: '通知類型',
              children: [
                _buildSettingsSwitch(
                  title: '血糖警報',
                  subtitle: '高低血糖通知',
                  value: settingsProvider.glucoseAlertsEnabled,
                  onChanged: settingsProvider.setGlucoseAlertsEnabled,
                  icon: Icons.water_drop,
                ),
                _buildSettingsSwitch(
                  title: '設備狀態',
                  subtitle: '設備連線與電量通知',
                  value: settingsProvider.deviceAlertsEnabled,
                  onChanged: settingsProvider.setDeviceAlertsEnabled,
                  icon: Icons.bluetooth,
                ),
                _buildSettingsSwitch(
                  title: '提醒事項',
                  subtitle: '進食、運動等提醒',
                  value: settingsProvider.reminderAlertsEnabled,
                  onChanged: settingsProvider.setReminderAlertsEnabled,
                  icon: Icons.schedule,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.paddingL),
            _buildSettingsSection(
              title: '血糖警報設定',
              children: [
                _buildThresholdSetting(
                  title: '高血糖門檻',
                  value: settingsProvider.highGlucoseThreshold,
                  unit: 'mg/dL',
                  onChanged: settingsProvider.setHighGlucoseThreshold,
                  icon: Icons.trending_up,
                  color: AppColors.glucoseHigh,
                ),
                _buildThresholdSetting(
                  title: '低血糖門檻',
                  value: settingsProvider.lowGlucoseThreshold,
                  unit: 'mg/dL',
                  onChanged: settingsProvider.setLowGlucoseThreshold,
                  icon: Icons.trending_down,
                  color: AppColors.glucoseLow,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyNotifications() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            '暫無通知',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '您的通知會顯示在這裡',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification, NotificationProvider provider) {
    final isUnread = !notification.isRead;

    return Card(
      elevation: isUnread ? 3 : 1,
      child: InkWell(
        onTap: () {
          if (isUnread) {
            provider.markAsRead(notification.id);
          }
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: isUnread
                ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notification.type).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnread)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'delete':
                          provider.deleteNotification(notification.id);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('刪除'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.paddingS),
              Text(
                notification.body,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildThresholdSetting({
    required String title,
    required double value,
    required String unit,
    required ValueChanged<double> onChanged,
    required IconData icon,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text('${value.toInt()} $unit'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThresholdDialog(title, value, unit, onChanged),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.glucoseAlert:
        return AppColors.error;
      case NotificationType.deviceAlert:
        return AppColors.warning;
      case NotificationType.reminder:
        return AppColors.info;
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.error:
        return AppColors.error;
      case NotificationType.info:
      // default:
        return AppColors.info;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.glucoseAlert:
        return Icons.water_drop;
      case NotificationType.deviceAlert:
        return Icons.bluetooth;
      case NotificationType.reminder:
        return Icons.schedule;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.info:
      // default:
        return Icons.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '剛剛';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} 分鐘前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} 小時前';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除所有通知'),
        content: const Text('確定要清除所有通知嗎？此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<NotificationProvider>(context, listen: false)
                  .clearAllNotifications();
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }

  void _showThresholdDialog(
      String title,
      double currentValue,
      String unit,
      ValueChanged<double> onChanged,
      ) {
    final controller = TextEditingController(text: currentValue.toInt().toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('設定$title'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: title,
            suffixText: unit,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null) {
                onChanged(value);
                Navigator.pop(context);
              }
            },
            child: const Text('確定'),
          ),
        ],
      ),
    );
  }
}