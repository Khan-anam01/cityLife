import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/events/models/event_model.dart';
import '../../../features/events/repository/events_repository.dart';
import '../models/post_model.dart';
import '../providers/community_provider.dart';
import '../repository/community_repository.dart';
import '../widgets/post_card.dart';
import '../widgets/follow_button.dart';

// ── Provider for a specific user's posts ──────────────
final userPostsProvider =
    FutureProvider.family<List<PostModel>, String>((ref, userId) async {
  return CommunityRepository.instance.getPostsByUser(userId);
});

// ── Provider for a specific user's info ───────────────
final userInfoProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, userId) async {
  return CommunityRepository.instance.getUserInfo(userId);
});

// ── Provider for a specific user's events ─────────────
final userEventsProvider =
    FutureProvider.family<List<EventModel>, String>((ref, userId) async {
  return EventsRepository.instance.getByOrganizerId(userId);
});

class UserProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  final String? userName;
  final String? userInitials;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.userName,
    this.userInitials,
  });

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _avatarColor(String userId) {
    final colors = [
      AppColors.primary,
      AppColors.accent,
      AppColors.amber,
      AppColors.lavender,
      AppColors.coral,
      AppColors.sky,
    ];
    final index = userId.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[index];
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = ref.watch(currentUserProvider);
    final isOwnProfile = currentUser?.id == widget.userId;
    final followerCount = ref.watch(followerCountProvider(widget.userId));
    final followingCount = ref.watch(followingCountProvider(widget.userId));
    final userInfo = ref.watch(userInfoProvider(widget.userId));
    final userPosts = ref.watch(userPostsProvider(widget.userId));
    final color = _avatarColor(widget.userId);

    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.background,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back_ios_rounded,
                    size: 16, color: textPrimary),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (!isOwnProfile)
                IconButton(
                  icon: const Icon(Icons.more_horiz_rounded),
                  onPressed: () => _showOptions(context),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.8),
                      color.withOpacity(0.4),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      // Avatar
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.6), width: 3),
                        ),
                        child: Center(
                          child: Text(
                            widget.userInitials ?? '?',
                            style: AppTypography.headlineLarge.copyWith(
                              color: Colors.white,
                              fontSize: 26,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        widget.userName ?? 'User',
                        style: AppTypography.headlineLarge
                            .copyWith(color: Colors.white),
                      ),
                      userInfo.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (info) {
                          final bio = info?['bio'] as String?;
                          if (bio == null || bio.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl),
                            child: Text(
                              bio,
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Stats + Follow bar ──────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: isDark ? AppColors.darkBackground : AppColors.background,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.md),
              child: Row(
                children: [
                  // Followers stat
                  Expanded(
                    child: _StatPill(
                      label: 'Followers',
                      value: followerCount.when(
                        data: (n) => '$n',
                        loading: () => '—',
                        error: (_, __) => '0',
                      ),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Following stat
                  Expanded(
                    child: _StatPill(
                      label: 'Following',
                      value: followingCount.when(
                        data: (n) => '$n',
                        loading: () => '—',
                        error: (_, __) => '0',
                      ),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Posts stat
                  Expanded(
                    child: userPosts.when(
                      data: (posts) => _StatPill(
                        label: 'Posts',
                        value: '${posts.length}',
                        isDark: isDark,
                      ),
                      loading: () =>
                          _StatPill(label: 'Posts', value: '—', isDark: isDark),
                      error: (_, __) =>
                          _StatPill(label: 'Posts', value: '0', isDark: isDark),
                    ),
                  ),

                  // Follow / Message buttons
                  if (!isOwnProfile) ...[
                    const SizedBox(width: AppSpacing.sm),
                    FollowButton(
                      targetUserId: widget.userId,
                      targetUserName: widget.userName ?? '',
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    // DM button
                    GestureDetector(
                      onTap: () => context.push(
                        '/dm/${widget.userId}',
                        extra: {
                          'userId': widget.userId,
                          'userName': widget.userName,
                          'userInitials': widget.userInitials,
                        },
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurface
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.border,
                          ),
                        ),
                        child: Icon(
                          Icons.mail_outline_rounded,
                          size: 18,
                          color: isDark ? AppColors.accent : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Tab bar ─────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: isDark ? AppColors.accent : AppColors.primary,
                unselectedLabelColor: textSecondary,
                indicatorColor: isDark ? AppColors.accent : AppColors.primary,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: AppTypography.labelMedium.copyWith(fontSize: 13),
                tabs: const [
                  Tab(text: 'Posts'),
                  Tab(text: 'Events'),
                  Tab(text: 'Messages'),
                ],
              ),
              isDark: isDark,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── Posts tab ──────────────────────────────
            userPosts.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
              error: (e, _) => Center(
                child: Text('Could not load posts',
                    style:
                        AppTypography.bodyMedium.copyWith(color: textPrimary)),
              ),
              data: (posts) {
                if (posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📝', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: AppSpacing.md),
                        Text('No posts yet',
                            style: AppTypography.headlineSmall
                                .copyWith(color: textPrimary)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: posts.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.divider,
                  ),
                  itemBuilder: (context, i) => PostCard(post: posts[i]),
                );
              },
            ),

            // ── Events tab ─────────────────────────────
            _UserEventsTab(
              userId: widget.userId,
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),

            // ── Messages tab ───────────────────────────
            _UserMessagesTab(
              userId: widget.userId,
              userName: widget.userName ?? 'User',
              isDark: isDark,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Report user'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.block_rounded, color: AppColors.error),
            title: const Text('Block user',
                style: TextStyle(color: AppColors.error)),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }
}

// ── Stat pill widget ───────────────────────────────────
class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _StatPill(
      {required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadiusSm),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              fontSize: 18,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Events tab ─────────────────────────────────────────
class _UserEventsTab extends ConsumerWidget {
  final String userId;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _UserEventsTab({
    required this.userId,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  String _categoryEmoji(String? cat) {
    const map = {
      'Music': '🎵',
      'Technology': '💻',
      'Sports': '🏃',
      'Food': '🍽️',
      'Arts': '🎨',
      'Business': '💼',
      'Community': '🤝',
      'Education': '📚',
    };
    return map[cat] ?? '🗓️';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(userEventsProvider(userId));

    return eventsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (_, __) => Center(
        child: Text('Could not load events',
            style: AppTypography.bodyMedium.copyWith(color: textPrimary)),
      ),
      data: (events) {
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🗓️', style: TextStyle(fontSize: 40)),
                const SizedBox(height: AppSpacing.md),
                Text('No events yet',
                    style: AppTypography.headlineSmall
                        .copyWith(color: textPrimary)),
                const SizedBox(height: AppSpacing.xs),
                Text('Events organised by this user will appear here',
                    textAlign: TextAlign.center,
                    style:
                        AppTypography.bodySmall.copyWith(color: textSecondary)),
              ],
            ),
          );
        }

        final now = DateTime.now();
        final upcoming = events.where((e) => e.startDate.isAfter(now)).toList();
        final past = events.where((e) => !e.startDate.isAfter(now)).toList();

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          children: [
            if (upcoming.isNotEmpty) ...[
              _EventSectionHeader(
                  label: 'Upcoming', count: upcoming.length, isDark: isDark),
              ...upcoming.map((e) => _EventTile(
                    event: e,
                    isDark: isDark,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    emoji: _categoryEmoji(e.category),
                  )),
            ],
            if (past.isNotEmpty) ...[
              _EventSectionHeader(
                  label: 'Past',
                  count: past.length,
                  isDark: isDark,
                  muted: true),
              ...past.map((e) => Opacity(
                    opacity: 0.6,
                    child: _EventTile(
                      event: e,
                      isDark: isDark,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      emoji: _categoryEmoji(e.category),
                    ),
                  )),
            ],
          ],
        );
      },
    );
  }
}

class _EventSectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final bool isDark;
  final bool muted;

  const _EventSectionHeader({
    required this.label,
    required this.count,
    required this.isDark,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = muted
        ? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
        : AppColors.amber;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, AppSpacing.md, AppSpacing.screenPadding, 6),
      child: Row(
        children: [
          Text(label,
              style: AppTypography.labelMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$count',
                style: AppTypography.caption.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final EventModel event;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;
  final String emoji;

  const _EventTile({
    required this.event,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding, vertical: 4),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border:
            Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Row(
        children: [
          // Emoji badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.amber.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: AppTypography.bodyMedium.copyWith(
                        color: textPrimary, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 11, color: AppColors.textTertiary),
                  const SizedBox(width: 3),
                  Text(event.formattedDate,
                      style:
                          AppTypography.caption.copyWith(color: textSecondary)),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.location_on_outlined,
                      size: 11, color: AppColors.textTertiary),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(event.venue,
                        style: AppTypography.caption
                            .copyWith(color: textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
              ],
            ),
          ),
          // Free / paid badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: event.isFree
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              event.priceLabel,
              style: AppTypography.caption.copyWith(
                  color: event.isFree ? AppColors.success : AppColors.amber),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Messages tab ────────────────────────────────────────
class _UserMessagesTab extends ConsumerWidget {
  final String userId;
  final String userName;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _UserMessagesTab({
    required this.userId,
    required this.userName,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserProvider)?.id ?? '';
    final messagesAsync =
        ref.watch(dmHistoryProvider(DmPair(currentUserId, userId)));

    return messagesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (_, __) => Center(
        child: Text('Could not load messages',
            style: AppTypography.bodyMedium.copyWith(color: textPrimary)),
      ),
      data: (messages) {
        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('💬', style: TextStyle(fontSize: 40)),
                const SizedBox(height: AppSpacing.md),
                Text('No messages yet',
                    style: AppTypography.headlineSmall
                        .copyWith(color: textPrimary)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Start a conversation with $userName',
                  style: AppTypography.bodySmall.copyWith(color: textSecondary),
                ),
                const SizedBox(height: AppSpacing.xl),
                ElevatedButton.icon(
                  onPressed: () => context.push(
                    '/dm/$userId',
                    extra: {'userId': userId, 'userName': userName},
                  ),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('Send Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? AppColors.accent : AppColors.primary,
                    foregroundColor: isDark ? AppColors.primary : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.buttonRadius),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.base),
          itemCount: messages.length,
          itemBuilder: (context, i) {
            final msg = messages[i];
            final isMe = msg.senderId == currentUserId;
            return _MessageBubble(
              message: msg,
              isMe: isMe,
              isDark: isDark,
            );
          },
        );
      },
    );
  }
}

// ── DM history provider ────────────────────────────────
class DmPair {
  final String userId1;
  final String userId2;
  const DmPair(this.userId1, this.userId2);

  @override
  bool operator ==(Object other) =>
      other is DmPair &&
      ((userId1 == other.userId1 && userId2 == other.userId2) ||
          (userId1 == other.userId2 && userId2 == other.userId1));

  @override
  int get hashCode => userId1.hashCode ^ userId2.hashCode;
}

final dmHistoryProvider =
    FutureProvider.family<List<dynamic>, DmPair>((ref, pair) async {
  return CommunityRepository.instance.getMessages(pair.userId1, pair.userId2);
});

// ── Message bubble ─────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final dynamic message;
  final bool isMe;
  final bool isDark;

  const _MessageBubble(
      {required this.message, required this.isMe, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.2),
              ),
              child: Center(
                child: Text(
                  (message.senderInitials ?? '?'),
                  style: AppTypography.caption
                      .copyWith(color: AppColors.accent, fontSize: 11),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isMe
                    ? (isDark ? AppColors.accent : AppColors.primary)
                    : (isDark ? AppColors.darkSurface : AppColors.surface),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: isMe
                    ? null
                    : Border.all(
                        color:
                            isDark ? AppColors.darkBorder : AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content as String,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isMe
                          ? (isDark ? AppColors.primary : Colors.white)
                          : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message.timeAgo as String,
                    style: AppTypography.caption.copyWith(
                      fontSize: 10,
                      color: isMe
                          ? (isDark
                              ? AppColors.primary.withOpacity(0.7)
                              : Colors.white70)
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sliver tab bar delegate ────────────────────────────
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;

  _SliverTabBarDelegate(this.tabBar, {required this.isDark});

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.background,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate old) =>
      tabBar != old.tabBar || isDark != old.isDark;
}
