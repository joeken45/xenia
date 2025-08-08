import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/constants.dart';
import '../../generated/l10n.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(context),
              const SizedBox(height: AppSizes.paddingL),
              _buildProfileMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.userModel;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    user?.name?.isNotEmpty == true
                        ? user!.name![0].toUpperCase()
                        : user?.email[0].toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                Text(
                  user?.name ?? '用戶',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingS),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingM),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingM,
                    vertical: AppSizes.paddingS,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: AppSizes.paddingS),
                      Text(
                        S.of(context).xeniaDescription,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
      child: Column(
        children: [
          _buildMenuSection(
            context,
            title: '個人設定',
            items: [
              _ProfileMenuItem(
                title: '個人資料',
                subtitle: '編輯姓名、電話等資訊',
                icon: Icons.person,
                onTap: () => _showComingSoonSnackBar(context),
              ),
              _ProfileMenuItem(
                title: '帳號安全',
                subtitle: '密碼、兩步驟驗證',
                icon: Icons.security,
                onTap: () => _showComingSoonSnackBar(context),
              ),
              _ProfileMenuItem(
                title: '隱私設定',
                subtitle: '資料分享、權限管理',
                icon: Icons.privacy_tip,
                onTap: () => _showComingSoonSnackBar(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          _buildMenuSection(
            context,
            title: '應用程式設定',
            items: [
              _ProfileMenuItem(
                title: '語言設定',
                subtitle: _getLanguageDescription(context),
                icon: Icons.language,
                onTap: () => _showLanguageSelector(context),
              ),
              _ProfileMenuItem(
                title: '深色模式',
                subtitle: '調整應用程式外觀',
                icon: Icons.dark_mode,
                trailing: Consumer<SettingsProvider>(
                  builder: (context, settingsProvider, _) {
                    return Switch(
                      value: settingsProvider.darkMode,
                      onChanged: settingsProvider.setDarkMode,
                    );
                  },
                ),
                onTap: null,
              ),
              _ProfileMenuItem(
                title: '通知設定',
                subtitle: '管理通知偏好',
                icon: Icons.notifications,
                onTap: () => _showComingSoonSnackBar(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          _buildMenuSection(
            context,
            title: '數據管理',
            items: [
              _ProfileMenuItem(
                title: '匯出數據',
                subtitle: '下載您的健康數據',
                icon: Icons.download,
                onTap: () => _showComingSoonSnackBar(context),
              ),
              _ProfileMenuItem(
                title: '數據備份',
                subtitle: '雲端備份與同步',
                icon: Icons.cloud_upload,
                onTap: () => _showComingSoonSnackBar(context),
              ),
              _ProfileMenuItem(
                title: '清除數據',
                subtitle: '刪除本地儲存的數據',
                icon: Icons.delete_forever,
                iconColor: AppColors.error,
                onTap: () => _showClearDataDialog(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          _buildMenuSection(
            context,
            title: '支援與回饋',
            items: [
              _ProfileMenuItem(
                title: '使用說明',
                subtitle: '查看應用程式使用指南',
                icon: Icons.help,
                onTap: () => _showComingSoonSnackBar(context),
              ),
              _ProfileMenuItem(
                title: '客服中心',
                subtitle: '聯絡客服團隊',
                icon: Icons.support_agent,
                onTap: () => _showComingSoonSnackBar(context),
              ),
              _ProfileMenuItem(
                title: '意見回饋',
                subtitle: '分享您的使用心得',
                icon: Icons.feedback,
                onTap: () => _showComingSoonSnackBar(context),
              ),
              _ProfileMenuItem(
                title: '關於 Xenia',
                subtitle: '版本資訊、授權條款',
                icon: Icons.info,
                onTap: () => _showAboutDialog(context),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          _buildLogoutButton(context),
          const SizedBox(height: AppSizes.paddingL),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
      BuildContext context, {
        required String title,
        required List<_ProfileMenuItem> items,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Card(
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (item.iconColor ?? AppColors.primary).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        color: item.iconColor ?? AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(item.title),
                    subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
                    trailing: item.trailing ??
                        (item.onTap != null ? const Icon(Icons.chevron_right) : null),
                    onTap: item.onTap,
                  ),
                  if (!isLast) const Divider(height: 1),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout),
        label: Text(S.of(context).signOut),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
        ),
      ),
    );
  }

  String _getLanguageDescription(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        switch (settingsProvider.language) {
          case 'zh_TW':
            return '繁體中文';
          case 'en':
            return 'English';
          default:
            return '系統預設';
        }
      },
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '選擇語言',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingL),
            Consumer<SettingsProvider>(
              builder: (context, settingsProvider, _) {
                return Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('繁體中文'),
                      value: 'zh_TW',
                      groupValue: settingsProvider.language,
                      onChanged: (value) {
                        if (value != null) {
                          settingsProvider.setLanguage(value);
                          Navigator.pop(context);
                        }
                      },
                    ),
                    RadioListTile<String>(
                      title: const Text('English'),
                      value: 'en',
                      groupValue: settingsProvider.language,
                      onChanged: (value) {
                        if (value != null) {
                          settingsProvider.setLanguage(value);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('登出'),
        content: const Text('確定要登出嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            child: const Text('登出'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除數據'),
        content: const Text('確定要清除所有本地數據嗎？此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoonSnackBar(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('清除'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: S.of(context).appName,
      applicationVersion: AppStrings.appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        child: const Icon(
          Icons.favorite,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        Text(S.of(context).xeniaDescription),
        const SizedBox(height: AppSizes.paddingM),
        const Text('© 2024 Xenia Team. All rights reserved.'),
      ],
    );
  }

  void _showComingSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('功能開發中，敬請期待'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}

class _ProfileMenuItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  _ProfileMenuItem({
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.trailing,
    this.onTap,
  });
}