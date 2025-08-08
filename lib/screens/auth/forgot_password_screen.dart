import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../generated/l10n.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(S.of(context).resetPassword),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.paddingXL),
                _buildHeader(),
                const SizedBox(height: AppSizes.paddingXL * 2),
                if (!_emailSent) ...[
                  _buildEmailForm(),
                  const SizedBox(height: AppSizes.paddingL),
                  _buildResetButton(),
                ] else ...[
                  _buildSuccessMessage(),
                  const SizedBox(height: AppSizes.paddingL),
                  _buildResendButton(),
                ],
                const SizedBox(height: AppSizes.paddingL),
                _buildBackToLoginButton(),
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
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: _emailSent
                ? AppColors.success.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _emailSent ? Icons.mark_email_read : Icons.lock_reset,
            size: 64,
            color: _emailSent ? AppColors.success : AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSizes.paddingL),
        Text(
          _emailSent ? '郵件已發送' : '重設密碼',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: _emailSent ? AppColors.success : AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          _emailSent
              ? '我們已將密碼重設連結發送到您的信箱'
              : '請輸入您的電子信箱，我們將發送重設密碼的連結',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return CustomTextField(
      controller: _emailController,
      labelText: S.of(context).email,
      hintText: '請輸入您註冊時使用的電子信箱',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      prefixIcon: Icons.email_outlined,
      validator: Validators.validateEmail,
      onFieldSubmitted: (_) => _handleResetPassword(),
    );
  }

  Widget _buildResetButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final isLoading = _isLoading || authProvider.isLoading;

        return CustomButton(
          text: '發送重設連結',
          onPressed: isLoading ? null : _handleResetPassword,
          isLoading: isLoading,
          icon: Icons.send,
        );
      },
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle,
            size: 48,
            color: AppColors.success,
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            '重設連結已發送',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          Text(
            '請檢查您的信箱：${_emailController.text}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingM),
          Text(
            '如果沒有收到郵件，請檢查垃圾郵件夾或點擊下方重新發送',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResendButton() {
    return SecondaryButton(
      text: '重新發送',
      onPressed: () {
        setState(() {
          _emailSent = false;
        });
      },
      icon: Icons.refresh,
    );
  }

  Widget _buildBackToLoginButton() {
    return TextButton.icon(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back),
      label: Text(
        '返回登入',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.resetPassword(_emailController.text.trim());

      if (success) {
        setState(() {
          _emailSent = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('密碼重設郵件已發送'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          _showErrorSnackBar(
            authProvider.errorMessage ?? '發送失敗，請重試',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('發送失敗: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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