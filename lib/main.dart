import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/auth_provider.dart';
import 'providers/cgm_provider.dart';
import 'providers/bluetooth_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/settings_provider.dart'; // 新增
import 'screens/auth/login_screen.dart';
import 'screens/main/main_navigation.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'generated/l10n.dart'; // Flutter Intl 生成的檔案

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 初始化 Firebase
    await Firebase.initializeApp();

    // 初始化通知服務
    await NotificationService.instance.initialize();

    print('App initialization completed successfully');
  } catch (e) {
    print('Failed to initialize app: $e');
  }

  runApp(const XeniaApp());
}

class XeniaApp extends StatelessWidget {
  const XeniaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CGMProvider()),
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()), // 新增
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          return Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return MaterialApp(
                title: 'Xenia',
                debugShowCheckedModeBanner: false,

                // 主題配置
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: settingsProvider.darkMode
                    ? ThemeMode.dark
                    : ThemeMode.light,

                // 國際化配置 (使用 Flutter Intl)
                localizationsDelegates: const [
                  S.delegate, // Flutter Intl 生成的代理
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: S.delegate.supportedLocales,

                // 語言設定
                locale: Locale(
                  settingsProvider.language == 'zh_TW' ? 'zh' : 'en',
                  settingsProvider.language == 'zh_TW' ? 'TW' : null,
                ),

                // 路由配置
                home: _buildHome(authProvider),

                // 全域錯誤處理
                builder: (context, child) {
                  return _GlobalErrorHandler(child: child);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHome(AuthProvider authProvider) {
    // 顯示載入畫面
    if (authProvider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Xenia',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '初始化中...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 根據認證狀態返回對應頁面
    if (authProvider.isAuthenticated) {
      return const MainNavigation();
    }

    return const LoginScreen();
  }
}

// 全域錯誤處理器
class _GlobalErrorHandler extends StatelessWidget {
  final Widget? child;

  const _GlobalErrorHandler({this.child});

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox.shrink();
  }
}

// 應用程式錯誤處理
class AppErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const AppErrorWidget({
    super.key,
    required this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: AppColors.error,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Xenia 遇到了問題',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '請重新啟動應用程式',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}