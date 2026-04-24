import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_spacing.dart';
import '../providers/community_provider.dart';
import '../repository/community_repository.dart';
import 'post_card.dart';

class FeedTab extends ConsumerStatefulWidget {
  const FeedTab({super.key});

  @override
  ConsumerState<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends ConsumerState<FeedTab>
    with SingleTickerProviderStateMixin {
  late TabController _feedTabController;

  @override
  void initState() {
    super.initState();
    _feedTabController = TabController(length: 3, vsync: this);
    _feedTabController.addListener(() {
      if (!_feedTabController.indexIsChanging) {
        final filter = FeedFilter.values[_feedTabController.index];
        ref.read(feedFilterProvider.notifier).state = filter;
      }
    });
  }

  @override
  void dispose() {
    _feedTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final constituency = ref.watch(selectedConstituencyProvider);
    final constituencies = ref.watch(constituenciesProvider);

    return Column(
      children: [
        // ── Inner tab bar: For You / Following / Constituency ──
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _feedTabController,
            labelColor: isDark ? AppColors.accent : AppColors.primary,
            unselectedLabelColor:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            labelStyle: AppTypography.labelMedium.copyWith(fontSize: 13),
            unselectedLabelStyle:
                AppTypography.labelMedium.copyWith(fontSize: 13),
            indicatorColor: isDark ? AppColors.accent : AppColors.primary,
            indicatorWeight: 2,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'For You'),
              Tab(text: 'Following'),
              Tab(text: 'Constituency'),
            ],
          ),
        ),

        // ── Constituency picker (only on Constituency tab) ─────
        AnimatedBuilder(
          animation: _feedTabController,
          builder: (context, _) {
            if (_feedTabController.index != 2) return const SizedBox.shrink();
            return _ConstituencyBar(
              constituency: constituency,
              constituencies: constituencies,
            );
          },
        ),

        // ── Tab content ────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _feedTabController,
            children: const [
              _ForYouFeed(),
              _FollowingFeed(),
              _ConstituencyFeed(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── For You Feed ───────────────────────────────────────
class _ForYouFeed extends ConsumerWidget {
  const _ForYouFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsState = ref.watch(postsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return postsState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (e, _) => _FeedError(
        onRetry: () => ref.read(postsProvider.notifier).loadPosts(),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return const _EmptyFeed(
              emoji: '🌆',
              label: 'No posts yet',
              sub: 'Be the first to post in your area!');
        }
        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () => ref.read(postsProvider.notifier).loadPosts(),
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: AppSpacing.massive),
            itemCount: posts.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.divider,
            ),
            itemBuilder: (context, i) => PostCard(post: posts[i]),
          ),
        );
      },
    );
  }
}

// ── Following Feed ─────────────────────────────────────
class _FollowingFeed extends ConsumerWidget {
  const _FollowingFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsState = ref.watch(followingPostsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return postsState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (e, _) => _FeedError(
        onRetry: () => ref.read(followingPostsProvider.notifier).load(),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return const _EmptyFeed(
            emoji: '👥',
            label: 'Nothing here yet',
            sub: 'Follow people from the For You feed to see their posts here.',
          );
        }
        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () => ref.read(followingPostsProvider.notifier).load(),
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: AppSpacing.massive),
            itemCount: posts.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.divider,
            ),
            itemBuilder: (context, i) =>
                PostCard(post: posts[i], useFollowingFeed: true),
          ),
        );
      },
    );
  }
}

// ── Constituency Feed ──────────────────────────────────
class _ConstituencyFeed extends ConsumerWidget {
  const _ConstituencyFeed();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final constituency = ref.watch(selectedConstituencyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (constituency.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('📍', style: TextStyle(fontSize: 48)),
              const SizedBox(height: AppSpacing.md),
              Text('Select your constituency',
                  style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Use the picker above to filter posts by constituency.',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Re-use the postsProvider but filtered — we load with constituency arg
    // We use a local FutureProvider here to avoid polluting the global state
    return _ConstituencyPostList(constituency: constituency);
  }
}

class _ConstituencyPostList extends ConsumerWidget {
  final String constituency;
  const _ConstituencyPostList({required this.constituency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Scoped future that re-runs when constituency changes
    final postsAsync = ref.watch(
      _constituencyPostsProvider(constituency),
    );

    return postsAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent)),
      error: (_, __) => _FeedError(onRetry: () {}),
      data: (posts) {
        if (posts.isEmpty) {
          return _EmptyFeed(
            emoji: '📍',
            label: 'No posts in $constituency',
            sub: 'Be the first to post from this constituency!',
          );
        }
        return RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () async =>
              ref.refresh(_constituencyPostsProvider(constituency)),
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: AppSpacing.massive),
            itemCount: posts.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.divider,
            ),
            itemBuilder: (context, i) => PostCard(post: posts[i]),
          ),
        );
      },
    );
  }
}

final _constituencyPostsProvider =
    FutureProvider.family((ref, String constituency) async {
  await CommunityRepository.instance.createTables();
  return CommunityRepository.instance.getPosts(constituency: constituency);
});

// ── Constituency picker bar ────────────────────────────
class _ConstituencyBar extends ConsumerWidget {
  final String constituency;
  final List<String> constituencies;

  const _ConstituencyBar({
    required this.constituency,
    required this.constituencies,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = constituency.isEmpty ? 'Select Constituency' : constituency;

    return GestureDetector(
      onTap: () => _showPicker(context, ref),
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.sm,
          AppSpacing.screenPadding,
          AppSpacing.xs,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: constituency.isEmpty
              ? (isDark ? AppColors.darkSurface : AppColors.background)
              : (isDark
                  ? AppColors.accent.withOpacity(0.12)
                  : AppColors.primary.withOpacity(0.07)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: constituency.isEmpty
                ? (isDark ? AppColors.darkBorder : AppColors.border)
                : (isDark ? AppColors.accent : AppColors.primary),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.my_location_rounded,
              size: 13,
              color: constituency.isEmpty
                  ? AppColors.textTertiary
                  : (isDark ? AppColors.accent : AppColors.primary),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                fontSize: 12,
                color: constituency.isEmpty
                    ? (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary)
                    : (isDark ? AppColors.accent : AppColors.primary),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: constituency.isEmpty
                  ? AppColors.textTertiary
                  : (isDark ? AppColors.accent : AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ConstituencyPicker(
        constituencies: constituencies,
        selected: ref.read(selectedConstituencyProvider),
        onSelect: (c) {
          ref.read(selectedConstituencyProvider.notifier).state = c;
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _ConstituencyPicker extends StatelessWidget {
  final List<String> constituencies;
  final String selected;
  final void Function(String) onSelect;

  const _ConstituencyPicker({
    required this.constituencies,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
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
        Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Text(
            'Select Constituency',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 320,
          child: ListView.builder(
            itemCount: constituencies.length,
            itemBuilder: (context, i) {
              final c = constituencies[i];
              final label = c.isEmpty ? 'All Constituencies' : c;
              final isSelected = selected == c;
              return ListTile(
                title: Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isSelected
                        ? (isDark ? AppColors.accent : AppColors.primary)
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_rounded,
                        color: isDark ? AppColors.accent : AppColors.primary,
                        size: 18)
                    : null,
                onTap: () => onSelect(c),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Shared helpers ─────────────────────────────────────
class _EmptyFeed extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;
  const _EmptyFeed(
      {required this.emoji, required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.md),
          Text(label, style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: Text(
              sub,
              style: AppTypography.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedError extends StatelessWidget {
  final VoidCallback onRetry;
  const _FeedError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😕', style: TextStyle(fontSize: 40)),
          const SizedBox(height: AppSpacing.md),
          Text('Could not load posts', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
