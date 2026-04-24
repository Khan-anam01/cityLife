import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/cl_button.dart';
import '../../../shared/widgets/cl_text_field.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/database/database_helper.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) return;

      // Update Firebase display name
      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName(_nameController.text.trim());

      // Update SQLite
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'users',
        {
          'display_name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'bio': _bioController.text.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [user.id],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated!',
                style: AppTypography.bodySmall.copyWith(color: Colors.white)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(AppSpacing.base),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile',
                style: AppTypography.bodySmall.copyWith(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(AppSpacing.base),
          ),
        );
      }
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile',
            style: AppTypography.headlineMedium.copyWith(color: textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar preview
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.4),
                          width: 2.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          user?.initials ?? 'CL',
                          style: AppTypography.displaySmall.copyWith(
                            color: Colors.white,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.accent : AppColors.primary,
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBackground
                                : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Email (read-only)
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.mail_outline_rounded,
                        size: AppSpacing.iconSm,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textTertiary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email',
                              style: AppTypography.caption
                                  .copyWith(color: textSecondary)),
                          Text(
                            user?.email ?? '',
                            style: AppTypography.bodyMedium
                                .copyWith(color: textPrimary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Locked',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textTertiary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.base),

              // Display name
              CLTextField(
                label: 'Display Name',
                hint: 'Your full name',
                controller: _nameController,
                prefixIcon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Name cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.base),

              // Phone
              CLTextField(
                label: 'Phone Number',
                hint: '+254 7XX XXX XXX',
                controller: _phoneController,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.base),

              // Bio
              CLTextField(
                label: 'Bio',
                hint: 'Tell your community a bit about yourself...',
                controller: _bioController,
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSpacing.xxxl),

              CLButton(
                label: 'Save Changes',
                onPressed: _save,
                isLoading: _isSaving,
                icon: Icons.check_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
