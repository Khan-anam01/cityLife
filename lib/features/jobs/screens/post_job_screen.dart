import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/user_model.dart';
import '../models/job_model.dart';
import '../repository/jobs_repository.dart';

class PostJobScreen extends ConsumerStatefulWidget {
  const PostJobScreen({super.key});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _applyUrlCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();

  String _selectedType = 'full-time';
  String _selectedCategory = 'Technology';
  bool _isRemote = false;
  bool _isSubmitting = false;
  DateTime? _deadline;

  static const _types = [
    ('full-time', 'Full-time'),
    ('part-time', 'Part-time'),
    ('contract', 'Contract'),
    ('internship', 'Internship'),
    ('freelance', 'Freelance'),
  ];

  static const _categories = [
    'Technology',
    'Marketing',
    'Engineering',
    'Healthcare',
    'Finance',
    'Design',
    'Education',
    'Sales',
    'Operations',
    'Legal',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill company name from user profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user?.displayName != null) {
        _companyCtrl.text = user!.displayName!;
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _companyCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _salaryCtrl.dispose();
    _skillsCtrl.dispose();
    _applyUrlCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null || user.role != UserRole.company) return;

    setState(() => _isSubmitting = true);
    try {
      final job = JobModel(
        id: const Uuid().v4(),
        title: _titleCtrl.text.trim(),
        company: _companyCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        location: _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
        salary:
            _salaryCtrl.text.trim().isEmpty ? null : _salaryCtrl.text.trim(),
        type: _selectedType,
        category: _selectedCategory,
        skills:
            _skillsCtrl.text.trim().isEmpty ? null : _skillsCtrl.text.trim(),
        deadline: _deadline,
        isRemote: _isRemote,
        applyUrl: _applyUrlCtrl.text.trim().isEmpty
            ? null
            : _applyUrlCtrl.text.trim(),
        postedById: user.id,
        postedByName: user.displayName,
        postedByRole: 'company',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await JobsRepository.instance.postJob(job, poster: user);

      if (mounted) {
        _showSuccess();
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success.withOpacity(0.12),
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppColors.success, size: 36),
            ),
            const SizedBox(height: 16),
            Text('Job Posted!', style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Your listing is now live and visible to job seekers.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);

    // Guard: non-company users should never see this screen
    if (user == null || user.role != UserRole.company) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post a Job')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.error.withOpacity(0.1),
                  ),
                  child: const Icon(Icons.lock_outline_rounded,
                      color: AppColors.error, size: 40),
                ),
                const SizedBox(height: 20),
                Text('Company Account Required',
                    style: AppTypography.headlineMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Only company accounts can post job listings. Upgrade your account to start hiring.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18,
              color:
                  isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Post a Job',
          style: AppTypography.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            // ── Company badge ──────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent.withOpacity(0.15),
                    ),
                    child: const Icon(Icons.business_rounded,
                        color: AppColors.accent, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Posting as Business Account',
                            style: AppTypography.labelSmall.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600)),
                        Text(user.displayName ?? user.email,
                            style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            _sectionLabel('Job Details', isDark),
            const SizedBox(height: AppSpacing.md),

            _buildField(
              ctrl: _titleCtrl,
              label: 'Job Title',
              hint: 'e.g. Senior Flutter Developer',
              icon: Icons.work_outline_rounded,
              isDark: isDark,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Job title is required'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildField(
              ctrl: _companyCtrl,
              label: 'Company Name',
              hint: 'Your company name',
              icon: Icons.business_outlined,
              isDark: isDark,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Company name is required'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildField(
              ctrl: _descCtrl,
              label: 'Job Description',
              hint: 'Describe the role, responsibilities, and requirements...',
              icon: Icons.description_outlined,
              isDark: isDark,
              maxLines: 5,
              validator: (v) => (v == null || v.trim().length < 30)
                  ? 'Please write at least 30 characters'
                  : null,
            ),

            const SizedBox(height: AppSpacing.xl),
            _sectionLabel('Type & Category', isDark),
            const SizedBox(height: AppSpacing.md),

            // Job type chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.map((t) {
                final selected = _selectedType == t.$1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = t.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : (isDark ? AppColors.darkSurface : AppColors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.border),
                      ),
                    ),
                    child: Text(
                      t.$2,
                      style: AppTypography.labelSmall.copyWith(
                        color: selected
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary),
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.md),

            // Category dropdown
            _buildDropdown(
              label: 'Category',
              value: _selectedCategory,
              items: _categories,
              icon: Icons.category_outlined,
              isDark: isDark,
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),

            const SizedBox(height: AppSpacing.xl),
            _sectionLabel('Location & Compensation', isDark),
            const SizedBox(height: AppSpacing.md),

            // Remote toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.laptop_mac_rounded,
                      size: 18,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Remote / Work from Home',
                        style: AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary)),
                  ),
                  Switch.adaptive(
                    value: _isRemote,
                    onChanged: (v) => setState(() => _isRemote = v),
                    activeColor: AppColors.accent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),
            _buildField(
              ctrl: _locationCtrl,
              label: 'Location',
              hint: 'e.g. Nairobi, Kenya',
              icon: Icons.location_on_outlined,
              isDark: isDark,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildField(
              ctrl: _salaryCtrl,
              label: 'Salary / Compensation',
              hint: 'e.g. KES 80,000 - 120,000/mo',
              icon: Icons.attach_money_rounded,
              isDark: isDark,
            ),

            const SizedBox(height: AppSpacing.xl),
            _sectionLabel('Skills & Application', isDark),
            const SizedBox(height: AppSpacing.md),

            _buildField(
              ctrl: _skillsCtrl,
              label: 'Required Skills',
              hint: 'e.g. Flutter, Dart, Firebase (comma separated)',
              icon: Icons.psychology_outlined,
              isDark: isDark,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildField(
              ctrl: _applyUrlCtrl,
              label: 'Apply URL (optional)',
              hint: 'https://yourcompany.com/careers/...',
              icon: Icons.link_rounded,
              isDark: isDark,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: AppSpacing.md),

            // Deadline picker
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _deadline == null
                            ? 'Application Deadline (optional)'
                            : 'Deadline: ${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: _deadline == null
                              ? (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textTertiary)
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary),
                        ),
                      ),
                    ),
                    if (_deadline != null)
                      GestureDetector(
                        onTap: () => setState(() => _deadline = null),
                        child: Icon(Icons.close_rounded,
                            size: 16, color: AppColors.textSecondary),
                      ),
                    if (_deadline == null)
                      Icon(Icons.chevron_right_rounded,
                          size: 18,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textTertiary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.massive),

            // ── Submit ──────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text('Post Job Listing',
                              style: AppTypography.labelLarge
                                  .copyWith(color: Colors.white)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: AppTypography.headlineSmall.copyWith(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTypography.bodyMedium.copyWith(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon,
            size: 18,
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        labelStyle: AppTypography.bodySmall.copyWith(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        hintStyle:
            AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required bool isDark,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      style: AppTypography.bodyMedium.copyWith(
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
      dropdownColor: isDark ? AppColors.darkSurface : AppColors.white,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon,
            size: 18,
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        labelStyle: AppTypography.bodySmall.copyWith(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      items: items
          .map((i) => DropdownMenuItem(
                value: i,
                child: Text(i,
                    style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary)),
              ))
          .toList(),
    );
  }
}
