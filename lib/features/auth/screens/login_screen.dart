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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      context.go(AppRoutes.home);
    } else if (authState.error != null) {
      _showError(authState.error!);
      ref.read(authProvider.notifier).clearError();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: AppTypography.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(AppSpacing.base),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background decoration ────────────────────
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(isDark ? 0.06 : 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.3,
            left: -60,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(isDark ? 0.1 : 0.04),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xxxl),

                    // Logo / Brand
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text('CL',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            )),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    const Text('Welcome back',
                        style: AppTypography.displaySmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Sign in to your City Life account',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    // Email field
                    CLTextField(
                      label: 'Email address',
                      hint: 'you@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                      focusNode: _emailFocus,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _passwordFocus.requestFocus(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.base),

                    // Password field
                    CLTextField(
                      label: 'Password',
                      hint: '••••••••',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _login(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push(AppRoutes.forgotPassword),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot password?',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Sign In button
                    CLButton(
                      label: 'Sign In',
                      onPressed: _login,
                      isLoading: authState.isLoading,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.register),
                          child: Text(
                            'Create one',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.massive),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
