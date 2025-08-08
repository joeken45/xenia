import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../generated/l10n.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.paddingXL * 2),
                _buildHeader(),
                const SizedBox(height: AppSizes.paddingXL * 2),
                _buildLoginForm(),
                const SizedBox(height: AppSizes.paddingL),
                _buildLoginButton(),
                const SizedBox(height: AppSizes.paddingM),
                _buildForgotPasswordButton(),
                const SizedBox(height: AppSizes.paddingXL),
                _buildDivider(),
                const SizedBox(height: AppSizes.paddingL),
                _buildSocialLoginButtons(),
                const SizedBox(height: AppSizes.paddingXL),
                _buildRegisterPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite,
            size: 64,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingL),
        Text(
          S.of(context).appName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          S.of(context).welcome,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          labelText: S.of(context).email,
          hintText: '請輸入您的電子信箱',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixIcon: Icons.email_outlined,
          validator: Validators.validateEmail,
        ),
        const SizedBox(height: AppSizes.paddingM),
        CustomTextField(
          controller: _passwordController,
          labelText: S.of(context).password,
          hintText: '請輸入您的密碼',
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.done,
          prefixIcon: Icons.lock_outlined,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          validator: Validators.validatePassword,
          onFieldSubmitted: (_) => _handleLogin(),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isLoading = _isLoading || authProvider.isLoading;

        return CustomButton(
          text: S.of(context).signIn,
          onPressed: isLoading ? null : _handleLogin,
          isLoading: isLoading,
        );
      },
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ForgotPasswordScreen(),
          ),
        );
      },
      child: Text(S.of(context).forgotPassword),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
          child: Text(
            '或',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Column(
          children: [
            _buildSocialLoginButton(
              icon: Icons.g_mobiledata,
              text: S.of(context).signInWithGoogle,
              onPressed: authProvider.isLoading ? null : _handleGoogleLogin,
              backgroundColor: Colors.white,
              textColor: Colors.black87,
              borderColor: Colors.grey[300],
            ),
            const SizedBox(height: AppSizes.paddingM),
            _buildSocialLoginButton(
              icon: Icons.apple,
              text: S.of(context).signInWithApple,
              onPressed: authProvider.isLoading ? null : _handleAppleLogin,
              backgroundColor: Colors.black,
              textColor: Colors.white,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSocialLoginButton({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(
          text,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor ?? backgroundColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          S.of(context).dontHaveAccount,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterScreen(),
              ),
            );
          },
          child: Text(
            S.of(context).signUp,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).loginSuccess),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          _showErrorSnackBar(
            authProvider.errorMessage ?? '登入失敗，請重試',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('登入失敗: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.signInWithGoogle();

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).loginSuccess),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          _showErrorSnackBar(
            authProvider.errorMessage ?? 'Google 登入失敗，請重試',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Google 登入失敗: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAppleLogin() async {
    // Apple 登入實現
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Apple 登入功能開發中'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: '關閉',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}