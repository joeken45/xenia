import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 取得當前用戶
  User? get currentUser => _auth.currentUser;

  // 監聽認證狀態變化
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email 註冊
  Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // 更新顯示名稱
        await user.updateDisplayName(name);

        // 創建用戶文檔
        await _createUserDocument(
          uid: user.uid,
          email: email,
          name: name,
          phoneNumber: phoneNumber,
        );

        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('註冊失敗: ${e.toString()}');
    }
  }

  // Email 登入
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // 更新最後登入時間
        await _updateLastLoginTime(user.uid);
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('登入失敗: ${e.toString()}');
    }
  }

  // Google 登入
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      final User? user = result.user;

      if (user != null) {
        // 檢查是否為新用戶，如果是則創建用戶文檔
        final userDoc = await _firestore
            .collection(APIConstants.usersCollection)
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await _createUserDocument(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? '',
          );
        } else {
          await _updateLastLoginTime(user.uid);
        }

        return user;
      }
      return null;
    } catch (e) {
      throw Exception('Google 登入失敗: ${e.toString()}');
    }
  }

  // 密碼重設
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('密碼重設失敗: ${e.toString()}');
    }
  }

  // 登出
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('登出失敗: ${e.toString()}');
    }
  }

  // 取得用戶資料
  Future<UserModel?> getUserData(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(APIConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('取得用戶資料失敗: ${e.toString()}');
    }
  }

  // 更新用戶資料
  Future<void> updateUserData({
    required String uid,
    String? name,
    String? phoneNumber,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};

      if (name != null) updateData['name'] = name;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (settings != null) updateData['settings'] = settings;

      if (updateData.isNotEmpty) {
        await _firestore
            .collection(APIConstants.usersCollection)
            .doc(uid)
            .update(updateData);
      }
    } catch (e) {
      throw Exception('更新用戶資料失敗: ${e.toString()}');
    }
  }

  // 刪除帳號
  Future<void> deleteAccount() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        // 刪除 Firestore 中的用戶資料
        await _firestore
            .collection(APIConstants.usersCollection)
            .doc(user.uid)
            .delete();

        // 刪除 Auth 帳號
        await user.delete();
      }
    } catch (e) {
      throw Exception('刪除帳號失敗: ${e.toString()}');
    }
  }

  // 私有方法：創建用戶文檔
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String name,
    String? phoneNumber,
  }) async {
    final userModel = UserModel(
      uid: uid,
      email: email,
      name: name,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      settings: {
        'glucoseUnit': 'mg/dL',
        'highGlucoseThreshold': 180.0,
        'lowGlucoseThreshold': 70.0,
        'enableAlarms': true,
        'language': 'zh_TW',
      },
    );

    await _firestore
        .collection(APIConstants.usersCollection)
        .doc(uid)
        .set(userModel.toMap());
  }

  // 私有方法：更新最後登入時間
  Future<void> _updateLastLoginTime(String uid) async {
    await _firestore
        .collection(APIConstants.usersCollection)
        .doc(uid)
        .update({'lastLoginAt': DateTime.now().millisecondsSinceEpoch});
  }

  // 私有方法：處理認證異常
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return '密碼強度不足，請使用至少 6 個字符';
      case 'email-already-in-use':
        return '此電子郵件已被註冊';
      case 'invalid-email':
        return '電子郵件格式不正確';
      case 'user-disabled':
        return '此帳號已被停用';
      case 'user-not-found':
        return '找不到此用戶';
      case 'wrong-password':
        return '密碼錯誤';
      case 'too-many-requests':
        return '登入嘗試次數過多，請稍後再試';
      case 'network-request-failed':
        return '網路連線失敗，請檢查網路設定';
      default:
        return '認證失敗: ${e.message}';
    }
  }

  // 重新認證用戶（用於敏感操作）
  Future<void> reauthenticateWithPassword(String password) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }
    } catch (e) {
      throw Exception('重新認證失敗: ${e.toString()}');
    }
  }

  // 更改密碼
  Future<void> changePassword(String newPassword) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      throw Exception('密碼更改失敗: ${e.toString()}');
    }
  }

  // 驗證電子郵件
  Future<void> sendEmailVerification() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      throw Exception('發送驗證郵件失敗: ${e.toString()}');
    }
  }
}