import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';

// Mock conversation data — will connect to real DB in a later polish step
class _MockConversation {
  final String id;
  final String name;
  final String initials;
  final String lastMessage;
  final String time;
  final int unread;
  final Color color;

  const _MockConversation({
    required this.id,
    required this.name,
    required this.initials,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
    required this.color,
  });
}

class MessagesTab extends ConsumerWidget {
  const MessagesTab({super.key});

  static const List<_MockConversation> _conversations = [
    _MockConversation(
        id: 'u2',
        name: 'Amina Hassan',
        initials: 'AH',
        lastMessage: 'Did you see the new hospital wing?',
        time: '2m',
        unread: 2,
        color: AppColors.accent),
    _MockConversation(
        id: 'u3',
        name: 'Peter Otieno',
        initials: 'PO',
        lastMessage: 'The street lights are still off 😤',
        time: '15m',
        unread: 0,
        color: AppColors.lavender),
    _MockConversation(
        id: 'u4',
        name: 'Grace Wanjiru',
        initials: 'GW',
        lastMessage: 'Tech Summit was amazing!',
        time: '1h',
        unread: 1,
        color: AppColors.amber),
    _MockConversation(
        id: 'u5',
        name: 'Hassan Ali',
        initials: 'HA',
        lastMessage: 'Check out the job listings I sent',
        time: '3h',
        unread: 0,
        color: AppColors.coral),
    _MockConversation(
        id: 'u6',
        name: 'Faith Achieng',
        initials: 'FA',
        lastMessage: 'Same time next month for the cleanup?',
        time: '1d',
        unread: 0,
        color: AppColors.success),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.sm,
          ),
          child: TextField(
            style: AppTypography.bodyMedium.copyWith(color: textPrimary),
            decoration: InputDecoration(
              hintText: 'Search messages...',
              hintStyle: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textTertiary),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.textTertiary, size: 20),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: isDark ? AppColors.accent : AppColors.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
        ),

        // Conversations list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: AppSpacing.massive),
            itemCount: _conversations.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: AppSpacing.screenPadding +
                  AppSpacing.avatarMd +
                  AppSpacing.md,
              color: isDark ? AppColors.darkBorder : AppColors.divider,
            ),
            itemBuilder: (context, i) {
              final conv = _conversations[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.xs,
                ),
                leading: Stack(
                  children: [
                    Container(
                      width: AppSpacing.avatarMd,
                      height: AppSpacing.avatarMd,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: conv.color.withOpacity(0.15),
                        border: Border.all(
                          color: conv.color.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          conv.initials,
                          style: AppTypography.labelMedium.copyWith(
                            color: conv.color,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    // Online dot
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success,
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBackground
                                : AppColors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        conv.name,
                        style: AppTypography.labelLarge.copyWith(
                          color: textPrimary,
                          fontWeight: conv.unread > 0
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      conv.time,
                      style: AppTypography.caption.copyWith(
                        color: conv.unread > 0
                            ? (isDark ? AppColors.accent : AppColors.primary)
                            : textSecondary,
                        fontWeight:
                            conv.unread > 0 ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Text(
                        conv.lastMessage,
                        style: AppTypography.bodySmall.copyWith(
                          color: conv.unread > 0 ? textPrimary : textSecondary,
                          fontWeight: conv.unread > 0
                              ? FontWeight.w500
                              : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (conv.unread > 0)
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppColors.accent : AppColors.primary,
                        ),
                        child: Center(
                          child: Text(
                            '${conv.unread}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('DM with ${conv.name} — coming soon!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
