import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../models/event_model.dart';
import '../repository/events_repository.dart';
import '../providers/events_provider.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _organizerCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  String _selectedCategory = 'Community';
  bool _isFree = true;
  bool _isSubmitting = false;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  static const _categories = [
    ('Community', '🤝'),
    ('Music', '🎵'),
    ('Technology', '💻'),
    ('Sports', '🏃'),
    ('Food', '🍽️'),
    ('Arts', '🎨'),
    ('Business', '💼'),
    ('Education', '📚'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user?.displayName != null) {
        _organizerCtrl.text = user!.displayName!;
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _venueCtrl.dispose();
    _organizerCtrl.dispose();
    _capacityCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: _datepickerTheme,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time == null) return;
    setState(() {
      _startDate = date;
      _startTime = time;
    });
  }

  Future<void> _pickEndDateTime() async {
    final initial = _startDate ?? DateTime.now().add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: _datepickerTheme,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 17, minute: 0),
    );
    if (time == null) return;
    setState(() {
      _endDate = date;
      _endTime = time;
    });
  }

  Widget Function(BuildContext, Widget?) get _datepickerTheme =>
      (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.amber,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppColors.textPrimary,
              ),
            ),
            child: child!,
          );

  DateTime? _combinedDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _formatDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null) return '';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final d = '${date.day} ${months[date.month - 1]} ${date.year}';
    if (time == null) return d;
    final h = time.hour;
    final m = time.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$d at $hour:$m $period';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar('Please set the event start date and time', isError: true),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSubmitting = true);
    try {
      final startDt = _combinedDateTime(_startDate, _startTime)!;
      final endDt = _combinedDateTime(_endDate, _endTime);
      final price =
          _isFree ? 0.0 : (double.tryParse(_priceCtrl.text.trim()) ?? 0.0);

      final event = EventModel(
        id: const Uuid().v4(),
        title: _titleCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        venue: _venueCtrl.text.trim(),
        startDate: startDt,
        endDate: endDt,
        category: _selectedCategory,
        organizer: _organizerCtrl.text.trim().isEmpty
            ? null
            : _organizerCtrl.text.trim(),
        capacity: _capacityCtrl.text.trim().isEmpty
            ? null
            : int.tryParse(_capacityCtrl.text.trim()),
        price: price,
        isFree: _isFree,
        organizerId: user.id,
        organizerRole: user.role.name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await EventsRepository.instance.insert(event);
      // Invalidate so the events list refreshes
      ref.invalidate(allEventsProvider);

      if (mounted) _showSuccess();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(_snackBar(e.toString(), isError: true));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  SnackBar _snackBar(String msg, {bool isError = false}) => SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

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
                color: AppColors.amber.withOpacity(0.12),
              ),
              child: const Icon(Icons.celebration_rounded,
                  color: AppColors.amber, size: 36),
            ),
            const SizedBox(height: 16),
            Text('Event Created!', style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Your event is now live. People in your city can discover and RSVP.',
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
                  backgroundColor: AppColors.amber,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);
    final isCompany = user?.role.name == 'company';

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
          'Create Event',
          style: AppTypography.headlineSmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.border),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            // ── Organizer badge ────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.amber.withOpacity(0.15),
                    ),
                    child: Icon(
                      isCompany
                          ? Icons.business_rounded
                          : Icons.person_outline_rounded,
                      color: AppColors.amber,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCompany
                              ? 'Posting as Business'
                              : 'Posting as Individual',
                          style: AppTypography.labelSmall.copyWith(
                              color: AppColors.amber,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          user?.displayName ?? user?.email ?? '',
                          style: AppTypography.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            _sectionLabel('Event Details', isDark),
            const SizedBox(height: AppSpacing.md),

            _buildField(
              ctrl: _titleCtrl,
              label: 'Event Title',
              hint: 'e.g. Nairobi Tech Meetup #12',
              icon: Icons.event_rounded,
              isDark: isDark,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildField(
              ctrl: _descCtrl,
              label: 'Description (optional)',
              hint: 'Tell people what to expect at your event...',
              icon: Icons.description_outlined,
              isDark: isDark,
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildField(
              ctrl: _venueCtrl,
              label: 'Venue / Location',
              hint: 'e.g. iHub, Ngong Road, Nairobi',
              icon: Icons.location_on_outlined,
              isDark: isDark,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Venue is required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildField(
              ctrl: _organizerCtrl,
              label: 'Organizer Name',
              hint: 'Who is hosting this event?',
              icon: Icons.groups_outlined,
              isDark: isDark,
            ),

            const SizedBox(height: AppSpacing.xl),
            _sectionLabel('Category', isDark),
            const SizedBox(height: AppSpacing.md),

            // Category chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((c) {
                final selected = _selectedCategory == c.$1;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = c.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.amber
                          : (isDark ? AppColors.darkSurface : AppColors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.amber
                            : (isDark
                                ? AppColors.darkBorder
                                : AppColors.border),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(c.$2, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 5),
                        Text(
                          c.$1,
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
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.xl),
            _sectionLabel('Date & Time', isDark),
            const SizedBox(height: AppSpacing.md),

            // Start date
            _DatePickerTile(
              label: 'Start Date & Time *',
              value: _formatDateTime(_startDate, _startTime),
              icon: Icons.play_circle_outline_rounded,
              placeholder: 'Tap to set start date & time',
              isDark: isDark,
              onTap: _pickStartDateTime,
              onClear: () => setState(() {
                _startDate = null;
                _startTime = null;
              }),
            ),
            const SizedBox(height: AppSpacing.md),

            // End date
            _DatePickerTile(
              label: 'End Date & Time (optional)',
              value: _formatDateTime(_endDate, _endTime),
              icon: Icons.stop_circle_outlined,
              placeholder: 'Tap to set end date & time',
              isDark: isDark,
              onTap: _pickEndDateTime,
              onClear: () => setState(() {
                _endDate = null;
                _endTime = null;
              }),
            ),

            const SizedBox(height: AppSpacing.xl),
            _sectionLabel('Capacity & Pricing', isDark),
            const SizedBox(height: AppSpacing.md),

            _buildField(
              ctrl: _capacityCtrl,
              label: 'Capacity (optional)',
              hint: 'Max number of attendees',
              icon: Icons.people_outline_rounded,
              isDark: isDark,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.md),

            // Free / paid toggle
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
                  Icon(Icons.confirmation_num_outlined,
                      size: 18,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Free Event',
                        style: AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary)),
                  ),
                  Switch.adaptive(
                    value: _isFree,
                    onChanged: (v) => setState(() => _isFree = v),
                    activeColor: AppColors.accent,
                  ),
                ],
              ),
            ),

            if (!_isFree) ...[
              const SizedBox(height: AppSpacing.md),
              _buildField(
                ctrl: _priceCtrl,
                label: 'Ticket Price (KES)',
                hint: 'e.g. 500',
                icon: Icons.local_activity_outlined,
                isDark: isDark,
                keyboardType: TextInputType.number,
                validator: (v) => (!_isFree && (v == null || v.trim().isEmpty))
                    ? 'Enter a price or mark as free'
                    : null,
              ),
            ],

            const SizedBox(height: AppSpacing.massive),

            // ── Submit ──────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.amber.withOpacity(0.5),
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
                          const Icon(Icons.celebration_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text('Publish Event',
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

  Widget _sectionLabel(String label, bool isDark) => Text(
        label,
        style: AppTypography.headlineSmall.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      );

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
          borderSide: const BorderSide(color: AppColors.amber, width: 1.5),
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
}

// ── Date picker tile ─────────────────────────────────────
class _DatePickerTile extends StatelessWidget {
  final String label;
  final String value;
  final String placeholder;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DatePickerTile({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.icon,
    required this.isDark,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon,
                    size: 18,
                    color: hasValue
                        ? AppColors.amber
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasValue ? value : placeholder,
                    style: AppTypography.bodyMedium.copyWith(
                      color: hasValue
                          ? (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary)
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
                if (hasValue)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(Icons.close_rounded,
                        size: 16, color: AppColors.textSecondary),
                  )
                else
                  Icon(Icons.chevron_right_rounded,
                      size: 18,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
