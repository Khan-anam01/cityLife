import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../shared/widgets/cl_button.dart';
import '../../../shared/widgets/cl_text_field.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref
        .read(authProvider.notifier)
        .sendPasswordReset(_emailController.text);

    if (success && mounted) {
      setState(() => _emailSent = true);
    } else if (mounted) {
      final error = ref.read(authProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error,
                style: AppTypography.bodySmall.copyWith(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(AppSpacing.base),
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: _emailSent ? _buildSuccessView() : _buildFormView(authState),
        ),
      ),
    );
  }

  Widget _buildFormView(AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),

          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: AppColors.accent,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          const Text('Reset password', style: AppTypography.displaySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Enter your email and we\'ll send you a link to reset your password.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          CLTextField(
            label: 'Email address',
            hint: 'you@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline_rounded,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _sendReset(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),

          CLButton(
            label: 'Send Reset Link',
            onPressed: _sendReset,
            isLoading: authState.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.success,
            size: 28,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const Text('Check your email', style: AppTypography.displaySmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'We sent a password reset link to\n${_emailController.text}',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        CLButton(
          label: 'Back to Sign In',
          onPressed: () => context.go(AppRoutes.login),
        ),
        const SizedBox(height: AppSpacing.base),
        CLButton(
          label: 'Resend email',
          variant: CLButtonVariant.outline,
          onPressed: () => setState(() {
            _emailSent = false;
          }),
        ),
      ],
    );
  }
}
