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
import '../../../shared/models/user_model.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserRole _selectedRole = UserRole.user;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).register(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _nameController.text,
          role: _selectedRole,
        );

    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      _showSuccess();
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

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account created! Please verify your email.',
            style: AppTypography.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(AppSpacing.base),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                const Text('Create account', style: AppTypography.displaySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Join City Life and explore your city',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Full name
                CLTextField(
                  label: 'Full name',
                  hint: 'John Doe',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.base),

                // Email
                CLTextField(
                  label: 'Email address',
                  hint: 'you@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                  textInputAction: TextInputAction.next,
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

                // Password
                CLTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.base),

                // Confirm Password
                CLTextField(
                  label: 'Confirm password',
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // Role selection
                const Text('Account type', style: AppTypography.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _RoleCard(
                      label: 'Individual',
                      icon: Icons.person_rounded,
                      description: 'Personal use',
                      isSelected: _selectedRole == UserRole.user,
                      onTap: () =>
                          setState(() => _selectedRole = UserRole.user),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _RoleCard(
                      label: 'Business',
                      icon: Icons.business_rounded,
                      description: 'Company account',
                      isSelected: _selectedRole == UserRole.company,
                      onTap: () =>
                          setState(() => _selectedRole = UserRole.company),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Register button
                CLButton(
                  label: 'Create Account',
                  onPressed: _register,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: AppSpacing.base),

                // Terms note
                Center(
                  child: Text(
                    'By creating an account you agree to our Terms of Service',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Role Selection Card ────────────────────────────────
class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? AppColors.accent.withOpacity(0.12)
                    : AppColors.primary.withOpacity(0.06))
                : (isDark ? AppColors.darkSurface : AppColors.surface),
            borderRadius: BorderRadius.circular(AppSpacing.cardRadiusSm),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.accent : AppColors.primary)
                  : (isDark ? AppColors.darkBorder : AppColors.border),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: AppSpacing.iconMd,
                color: isSelected
                    ? (isDark ? AppColors.accent : AppColors.primary)
                    : AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? (isDark ? AppColors.accent : AppColors.primary)
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary),
                      ),
                    ),
                    Text(
                      description,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
