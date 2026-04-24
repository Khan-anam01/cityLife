import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/cl_button.dart';
import '../../../shared/widgets/cl_text_field.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../models/report_model.dart';
import '../providers/reports_provider.dart';

class ReportIssueScreen extends ConsumerStatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  ConsumerState<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends ConsumerState<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _picker = ImagePicker();

  ReportCategory _selectedCategory = ReportCategory.pothole;
  Position? _position;
  String? _locationError;
  bool _isLocating = false;
  bool _isSubmitting = false;

  // Evidence media
  XFile? _mediaFile;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ── Location ───────────────────────────────────────
  Future<void> _getLocation() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });

    try {
      // 1. Check if service is enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLocating = false;
          _locationError = 'Location services are off. Enable GPS in settings.';
        });
        return;
      }

      // 2. Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _isLocating = false;
          _locationError = 'Location permission denied.';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLocating = false;
          _locationError =
              'Location permission permanently denied. Enable it in App Settings.';
        });
        return;
      }

      // 3. Get position
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      if (mounted) {
        setState(() {
          _position = pos;
          _isLocating = false;
          _locationError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLocating = false;
          _locationError = 'Could not get location. Tap retry.';
        });
      }
    }
  }

  Future<void> _openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  // ── Media picker ────────────────────────────────────
  void _showMediaPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded,
                  color: AppColors.accent),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.camera, isVideo: false);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.videocam_rounded, color: AppColors.accent),
              title: const Text('Record Video (max 20s)'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.camera, isVideo: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.accent),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.gallery, isVideo: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library_rounded,
                  color: AppColors.accent),
              title: const Text('Video from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickMedia(ImageSource.gallery, isVideo: true);
              },
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source, {required bool isVideo}) async {
    try {
      XFile? file;
      if (isVideo) {
        file = await _picker.pickVideo(
          source: source,
          maxDuration: const Duration(seconds: 20),
        );
      } else {
        file = await _picker.pickImage(
          source: source,
          imageQuality: 80,
          maxWidth: 1920,
        );
      }
      if (file != null && mounted) {
        setState(() {
          _mediaFile = file;
          _isVideo = isVideo;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Could not access camera/gallery', isError: true);
      }
    }
  }

  // ── Submit ─────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_position == null) {
      _showSnack('Location is required. Please tap Retry.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    final user = ref.read(currentUserProvider);

    final report = ReportModel(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      userId: user?.id ?? 'anonymous',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      // Store local path for now — in production upload to Firebase Storage
      imageUrl: _mediaFile?.path,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.read(reportsProvider.notifier).submit(report);
    setState(() => _isSubmitting = false);

    if (mounted) {
      _showSnack('Report submitted successfully! ✅');
      Navigator.pop(context);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: AppTypography.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(AppSpacing.base),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Report an Issue',
            style: AppTypography.headlineMedium.copyWith(color: textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Info banner ───────────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.sky.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: AppColors.sky.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.sky, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Reports are routed to the relevant city department. '
                        'You\'ll receive status updates in My Reports.',
                        style: AppTypography.bodySmall
                            .copyWith(color: textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Category grid ─────────────────────
              Text('Issue Category',
                  style: AppTypography.labelLarge.copyWith(color: textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.1,
                children: ReportCategory.values.map((cat) {
                  final dummy = ReportModel(
                    id: '',
                    userId: '',
                    title: '',
                    description: '',
                    category: cat,
                    latitude: 0,
                    longitude: 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? AppColors.accent.withOpacity(0.15)
                                : AppColors.primary.withOpacity(0.07))
                            : (isDark
                                ? AppColors.darkSurface
                                : AppColors.surface),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.cardRadiusSm),
                        border: Border.all(
                          color: isSelected
                              ? (isDark ? AppColors.accent : AppColors.primary)
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(dummy.categoryEmoji,
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(
                            dummy.categoryLabel,
                            style: AppTypography.caption.copyWith(
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.accent
                                      : AppColors.primary)
                                  : textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Title ─────────────────────────────
              CLTextField(
                label: 'Issue Title',
                hint: 'e.g. Large pothole on Ngong Road near junction',
                controller: _titleController,
                prefixIcon: Icons.title_rounded,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (v.trim().length < 10) {
                    return 'Title must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.base),

              // ── Description ───────────────────────
              CLTextField(
                label: 'Description',
                hint:
                    'Describe the issue in detail — how long it\'s been there and its impact.',
                controller: _descController,
                maxLines: 4,
                prefixIcon: Icons.description_outlined,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please describe the issue';
                  }
                  if (v.trim().length < 20) {
                    return 'Description must be at least 20 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Location ──────────────────────────
              Text('Location',
                  style: AppTypography.labelLarge.copyWith(color: textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(
                    color: _position != null
                        ? AppColors.success.withOpacity(0.4)
                        : _locationError != null
                            ? AppColors.error.withOpacity(0.4)
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.border),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _position != null
                                ? AppColors.success.withOpacity(0.12)
                                : _locationError != null
                                    ? AppColors.error.withOpacity(0.1)
                                    : AppColors.amber.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _position != null
                                ? Icons.location_on_rounded
                                : _locationError != null
                                    ? Icons.location_off_rounded
                                    : Icons.location_searching_rounded,
                            color: _position != null
                                ? AppColors.success
                                : _locationError != null
                                    ? AppColors.error
                                    : AppColors.amber,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isLocating
                                    ? 'Getting your location...'
                                    : _position != null
                                        ? 'Location captured ✓'
                                        : 'Location not available',
                                style: AppTypography.labelMedium.copyWith(
                                  color: _position != null
                                      ? AppColors.success
                                      : textPrimary,
                                ),
                              ),
                              if (_position != null)
                                Text(
                                  '${_position!.latitude.toStringAsFixed(5)}, '
                                  '${_position!.longitude.toStringAsFixed(5)}',
                                  style: AppTypography.caption
                                      .copyWith(color: textSecondary),
                                ),
                            ],
                          ),
                        ),
                        if (_isLocating)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.accent),
                          ),
                        if (!_isLocating && _position == null)
                          TextButton(
                            onPressed: _getLocation,
                            child: Text(
                              'Retry',
                              style: AppTypography.labelMedium.copyWith(
                                color: isDark
                                    ? AppColors.accent
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Error message with settings link
                    if (_locationError != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _locationError!,
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.error),
                            ),
                          ),
                          if (_locationError!.contains('permanently'))
                            TextButton(
                              onPressed: _openAppSettings,
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero),
                              child: Text(
                                'Open Settings',
                                style: AppTypography.labelSmall.copyWith(
                                  color: isDark
                                      ? AppColors.accent
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Evidence (optional) ───────────────
              Row(
                children: [
                  Text('Evidence',
                      style: AppTypography.labelLarge
                          .copyWith(color: textPrimary)),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Optional',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Media preview / picker
              GestureDetector(
                onTap: _showMediaPicker,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _mediaFile != null ? 200 : 100,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(
                      color: _mediaFile != null
                          ? AppColors.accent.withOpacity(0.4)
                          : (isDark ? AppColors.darkBorder : AppColors.border),
                      style: _mediaFile != null
                          ? BorderStyle.solid
                          : BorderStyle.solid,
                    ),
                  ),
                  child: _mediaFile != null
                      ? Stack(
                          children: [
                            // Preview
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.cardRadius - 1),
                              child: _isVideo
                                  ? Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      color: Colors.black,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                              Icons.play_circle_fill_rounded,
                                              color: Colors.white,
                                              size: 48),
                                          const SizedBox(height: AppSpacing.sm),
                                          Text(
                                            'Video recorded',
                                            style: AppTypography.bodyMedium
                                                .copyWith(color: Colors.white),
                                          ),
                                          Text(
                                            _mediaFile!.path.split('/').last,
                                            style:
                                                AppTypography.caption.copyWith(
                                              color: Colors.white70,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    )
                                  : Image.file(
                                      File(_mediaFile!.path),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                            ),
                            // Remove button
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() => _mediaFile = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black54,
                                  ),
                                  child: const Icon(Icons.close_rounded,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                            // Change button
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: _showMediaPicker,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Change',
                                    style: AppTypography.caption
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 32,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textTertiary,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Add photo or video evidence',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textTertiary,
                              ),
                            ),
                            Text(
                              'Max 20 seconds for videos',
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // ── Submit ────────────────────────────
              CLButton(
                label: 'Submit Report',
                onPressed: _submit,
                isLoading: _isSubmitting,
                icon: Icons.send_rounded,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
