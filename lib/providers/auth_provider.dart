import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _firebaseUser = user;
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _userModel = null;
        _isLoading = false;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      _userModel = await _authService.getUserData(uid);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 註冊
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phoneNumber: phoneNumber,
      );

      if (result != null) {
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 登入
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result != null;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Google 登入
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _authService.signInWithGoogle();
      return result != null;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 忘記密碼
  Future<bool> resetPassword(String email) async {
    try {
      _errorMessage = null;
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // 登出
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // 更新用戶資料
  Future<bool> updateProfile({
    String? name,
    String? phoneNumber,
    Map<String, dynamic>? settings,
  }) async {
    try {
      if (_firebaseUser == null) return false;

      await _authService.updateUserData(
        uid: _firebaseUser!.uid,
        name: name,
        phoneNumber: phoneNumber,
        settings: settings,
      );

      // 重新載入用戶資料
      await _loadUserData(_firebaseUser!.uid);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 清除錯誤訊息
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}