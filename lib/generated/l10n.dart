// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Xenia`
  String get appName {
    return Intl.message(
      'Xenia',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `歡迎使用 Xenia`
  String get welcome {
    return Intl.message(
      '歡迎使用 Xenia',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `您的智慧血糖管理夥伴`
  String get xeniaDescription {
    return Intl.message(
      '您的智慧血糖管理夥伴',
      name: 'xeniaDescription',
      desc: '',
      args: [],
    );
  }

  /// `登入`
  String get login {
    return Intl.message(
      '登入',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `註冊`
  String get register {
    return Intl.message(
      '註冊',
      name: 'register',
      desc: '',
      args: [],
    );
  }

  /// `電子信箱`
  String get email {
    return Intl.message(
      '電子信箱',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `密碼`
  String get password {
    return Intl.message(
      '密碼',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `確認密碼`
  String get confirmPassword {
    return Intl.message(
      '確認密碼',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `姓名`
  String get name {
    return Intl.message(
      '姓名',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `手機號碼`
  String get phoneNumber {
    return Intl.message(
      '手機號碼',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `忘記密碼？`
  String get forgotPassword {
    return Intl.message(
      '忘記密碼？',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `重設密碼`
  String get resetPassword {
    return Intl.message(
      '重設密碼',
      name: 'resetPassword',
      desc: '',
      args: [],
    );
  }

  /// `使用 Google 登入`
  String get signInWithGoogle {
    return Intl.message(
      '使用 Google 登入',
      name: 'signInWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `使用 Apple 登入`
  String get signInWithApple {
    return Intl.message(
      '使用 Apple 登入',
      name: 'signInWithApple',
      desc: '',
      args: [],
    );
  }

  /// `還沒有帳號？`
  String get dontHaveAccount {
    return Intl.message(
      '還沒有帳號？',
      name: 'dontHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `已經有帳號了？`
  String get alreadyHaveAccount {
    return Intl.message(
      '已經有帳號了？',
      name: 'alreadyHaveAccount',
      desc: '',
      args: [],
    );
  }

  /// `註冊`
  String get signUp {
    return Intl.message(
      '註冊',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `登入`
  String get signIn {
    return Intl.message(
      '登入',
      name: 'signIn',
      desc: '',
      args: [],
    );
  }

  /// `登出`
  String get signOut {
    return Intl.message(
      '登出',
      name: 'signOut',
      desc: '',
      args: [],
    );
  }

  /// `首頁`
  String get dashboard {
    return Intl.message(
      '首頁',
      name: 'dashboard',
      desc: '',
      args: [],
    );
  }

  /// `分析`
  String get analytics {
    return Intl.message(
      '分析',
      name: 'analytics',
      desc: '',
      args: [],
    );
  }

  /// `紀錄`
  String get logging {
    return Intl.message(
      '紀錄',
      name: 'logging',
      desc: '',
      args: [],
    );
  }

  /// `通知`
  String get notifications {
    return Intl.message(
      '通知',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `我的`
  String get profile {
    return Intl.message(
      '我的',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `目前血糖`
  String get currentGlucose {
    return Intl.message(
      '目前血糖',
      name: 'currentGlucose',
      desc: '',
      args: [],
    );
  }

  /// `血糖趨勢`
  String get glucoseTrend {
    return Intl.message(
      '血糖趨勢',
      name: 'glucoseTrend',
      desc: '',
      args: [],
    );
  }

  /// `設備狀態`
  String get deviceStatus {
    return Intl.message(
      '設備狀態',
      name: 'deviceStatus',
      desc: '',
      args: [],
    );
  }

  /// `已連接`
  String get connected {
    return Intl.message(
      '已連接',
      name: 'connected',
      desc: '',
      args: [],
    );
  }

  /// `未連接`
  String get disconnected {
    return Intl.message(
      '未連接',
      name: 'disconnected',
      desc: '',
      args: [],
    );
  }

  /// `連接設備`
  String get connectDevice {
    return Intl.message(
      '連接設備',
      name: 'connectDevice',
      desc: '',
      args: [],
    );
  }

  /// `開始設定`
  String get startSetup {
    return Intl.message(
      '開始設定',
      name: 'startSetup',
      desc: '',
      args: [],
    );
  }

  /// `儲存`
  String get save {
    return Intl.message(
      '儲存',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `取消`
  String get cancel {
    return Intl.message(
      '取消',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `刪除`
  String get delete {
    return Intl.message(
      '刪除',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `編輯`
  String get edit {
    return Intl.message(
      '編輯',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `確認`
  String get confirm {
    return Intl.message(
      '確認',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `載入中...`
  String get loading {
    return Intl.message(
      '載入中...',
      name: 'loading',
      desc: '',
      args: [],
    );
  }

  /// `重試`
  String get retry {
    return Intl.message(
      '重試',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `重新整理`
  String get refresh {
    return Intl.message(
      '重新整理',
      name: 'refresh',
      desc: '',
      args: [],
    );
  }

  /// `暫無資料`
  String get noData {
    return Intl.message(
      '暫無資料',
      name: 'noData',
      desc: '',
      args: [],
    );
  }

  /// `錯誤`
  String get error {
    return Intl.message(
      '錯誤',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `成功`
  String get success {
    return Intl.message(
      '成功',
      name: 'success',
      desc: '',
      args: [],
    );
  }

  /// `警告`
  String get warning {
    return Intl.message(
      '警告',
      name: 'warning',
      desc: '',
      args: [],
    );
  }

  /// `資訊`
  String get info {
    return Intl.message(
      '資訊',
      name: 'info',
      desc: '',
      args: [],
    );
  }

  /// `登入成功`
  String get loginSuccess {
    return Intl.message(
      '登入成功',
      name: 'loginSuccess',
      desc: '',
      args: [],
    );
  }

  /// `註冊成功`
  String get registerSuccess {
    return Intl.message(
      '註冊成功',
      name: 'registerSuccess',
      desc: '',
      args: [],
    );
  }

  /// `登出成功`
  String get logoutSuccess {
    return Intl.message(
      '登出成功',
      name: 'logoutSuccess',
      desc: '',
      args: [],
    );
  }

  /// `儲存成功`
  String get saveSuccess {
    return Intl.message(
      '儲存成功',
      name: 'saveSuccess',
      desc: '',
      args: [],
    );
  }

  /// `刪除成功`
  String get deleteSuccess {
    return Intl.message(
      '刪除成功',
      name: 'deleteSuccess',
      desc: '',
      args: [],
    );
  }

  /// `更新成功`
  String get updateSuccess {
    return Intl.message(
      '更新成功',
      name: 'updateSuccess',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
