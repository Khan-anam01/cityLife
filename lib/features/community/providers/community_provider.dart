import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/group_model.dart';
import '../repository/community_repository.dart';
import '../../auth/providers/auth_provider.dart';

// ── Feed filter ────────────────────────────────────────
enum FeedFilter { forYou, following, constituency }

final feedFilterProvider =
    StateProvider<FeedFilter>((ref) => FeedFilter.forYou);

// ── County / Constituency filter ───────────────────────
final selectedCountyProvider = StateProvider<String>((ref) => 'All');
final selectedConstituencyProvider = StateProvider<String>((ref) => '');

// ── Counties list ──────────────────────────────────────
final countiesProvider = Provider<List<String>>((ref) => [
      'All',
      'Nairobi',
      'Mombasa',
      'Kisumu',
      'Nakuru',
      'Eldoret',
      'Thika',
      'Kiambu',
      'Machakos',
      'Meru',
      'Nyeri',
      'Kisii',
      'Kakamega',
      'Garissa',
      'Malindi',
      'Kitale',
      'Bungoma',
      'Embu',
      'Isiolo',
      'Lamu',
    ]);

// ── Constituency list (Nairobi sample) ─────────────────
final constituenciesProvider = Provider<List<String>>((ref) => [
      '',
      'Westlands',
      'Dagoretti North',
      'Dagoretti South',
      'Langata',
      'Kibra',
      'Roysambu',
      'Kasarani',
      'Ruaraka',
      'Embakasi South',
      'Embakasi North',
      'Embakasi Central',
      'Embakasi East',
      'Embakasi West',
      'Makadara',
      'Kamukunji',
      'Starehe',
      'Mathare',
    ]);

// ── Posts: For You feed (stream) ───────────────────────
// StreamProvider automatically rebuilds the UI whenever Realtime DB updates.
final postsStreamProvider = StreamProvider<List<PostModel>>((ref) {
  final county = ref.watch(selectedCountyProvider);
  return CommunityRepository.instance.postsStream(county: county);
});

// ── Posts: Constituency feed (stream) ──────────────────
final constituencyPostsProvider =
    StreamProvider.family<List<PostModel>, String>((ref, constituency) {
  return CommunityRepository.instance.postsStream(constituency: constituency);
});

// ── Posts: Following feed (stream) ─────────────────────
// Filters the global stream client-side to posts from followed users.
final followingPostsProvider = StreamProvider<List<PostModel>>((ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield [];
    return;
  }

  final followingIds =
      await CommunityRepository.instance.getFollowingIds(user.id);

  if (followingIds.isEmpty) {
    yield [];
    return;
  }

  yield* CommunityRepository.instance.postsStream().map(
      (posts) => posts.where((p) => followingIds.contains(p.userId)).toList());
});

// ── Posts: By a specific user (one-time fetch) ─────────
final userPostsProvider =
    FutureProvider.family<List<PostModel>, String>((ref, userId) {
  return CommunityRepository.instance.getPostsByUser(userId);
});

// ── Create post action ─────────────────────────────────
// Kept as a simple repository call — the StreamProvider auto-refreshes.
class PostActionsNotifier extends StateNotifier<AsyncValue<void>> {
  PostActionsNotifier() : super(const AsyncValue.data(null));

  Future<void> createPost(PostModel post) async {
    state = const AsyncValue.loading();
    try {
      await CommunityRepository.instance.createPost(post);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleLike(String postId, bool currentlyLiked) async {
    await CommunityRepository.instance.toggleLike(postId, !currentlyLiked);
  }

  Future<void> deletePost(String postId) async {
    await CommunityRepository.instance.deletePost(postId);
  }
}

final postActionsProvider =
    StateNotifierProvider<PostActionsNotifier, AsyncValue<void>>(
  (ref) => PostActionsNotifier(),
);

// ── Comments: stream per post ──────────────────────────
final commentsStreamProvider =
    StreamProvider.family<List<CommentModel>, String>((ref, postId) {
  return CommunityRepository.instance.commentsStream(postId);
});

// ── Comment actions ────────────────────────────────────
class CommentsNotifier extends StateNotifier<AsyncValue<void>> {
  final String postId;
  CommentsNotifier(this.postId) : super(const AsyncValue.data(null));

  Future<void> addComment(CommentModel comment) async {
    state = const AsyncValue.loading();
    try {
      await CommunityRepository.instance.addComment(comment);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteComment(String commentId) async {
    await CommunityRepository.instance.deleteComment(postId, commentId);
  }
}

final commentsProvider =
    StateNotifierProvider.family<CommentsNotifier, AsyncValue<void>, String>(
  (ref, postId) => CommentsNotifier(postId),
);

// ── Groups ─────────────────────────────────────────────
final groupsProvider =
    FutureProvider.family<List<GroupModel>, String?>((ref, county) async {
  await CommunityRepository.instance.createTables();
  return CommunityRepository.instance.getGroups(county: county);
});

// ── Follow state ───────────────────────────────────────
final isFollowingProvider =
    FutureProvider.family<bool, String>((ref, targetUserId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return CommunityRepository.instance.isFollowing(user.id, targetUserId);
});

final followerCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final ids = await CommunityRepository.instance.getFollowerIds(userId);
  return ids.length;
});

final followingCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final ids = await CommunityRepository.instance.getFollowingIds(userId);
  return ids.length;
});

// ── Follow / Unfollow action ───────────────────────────
class FollowNotifier extends StateNotifier<AsyncValue<bool>> {
  final String currentUserId;
  final String targetUserId;
  final Ref _ref;

  FollowNotifier(this.currentUserId, this.targetUserId, this._ref)
      : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final following = await CommunityRepository.instance
          .isFollowing(currentUserId, targetUserId);
      if (mounted) state = AsyncValue.data(following);
    } catch (e, s) {
      if (mounted) state = AsyncValue.error(e, s);
    }
  }

  Future<void> toggle() async {
    final current = state.valueOrNull;
    if (current == null) return;
    // Optimistic update
    state = AsyncValue.data(!current);
    try {
      if (current) {
        await CommunityRepository.instance
            .unfollow(currentUserId, targetUserId);
      } else {
        await CommunityRepository.instance.follow(currentUserId, targetUserId);
      }
      // Refresh following feed
      _ref.read(followingPostsProvider.notifier).load();
    } catch (_) {
      // Revert on error
      state = AsyncValue.data(current);
    }
  }
}

final followNotifierProvider = StateNotifierProvider.family<FollowNotifier,
    AsyncValue<bool>, ({String currentUserId, String targetUserId})>(
  (ref, args) => FollowNotifier(args.currentUserId, args.targetUserId, ref),
);
