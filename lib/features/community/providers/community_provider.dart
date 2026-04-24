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

// ── Posts (For You feed) ───────────────────────────────
class PostsNotifier extends StateNotifier<AsyncValue<List<PostModel>>> {
  PostsNotifier() : super(const AsyncValue.loading()) {
    loadPosts();
  }

  Future<void> loadPosts({String? county, String? constituency}) async {
    state = const AsyncValue.loading();
    try {
      await CommunityRepository.instance.createTables();
      await CommunityRepository.instance.seedCommunity();
      final posts = await CommunityRepository.instance.getPosts(
        county: county,
        constituency: constituency,
      );
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createPost(PostModel post) async {
    await CommunityRepository.instance.createPost(post);
    await loadPosts();
  }

  Future<void> toggleLike(String postId, bool isLiked) async {
    await CommunityRepository.instance.toggleLike(postId, !isLiked);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current.map((p) {
      if (p.id != postId) return p;
      return p.copyWith(
        likes: isLiked ? p.likes - 1 : p.likes + 1,
        isLiked: !isLiked,
      );
    }).toList());
  }

  Future<void> deletePost(String postId) async {
    await CommunityRepository.instance.deletePost(postId);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current.where((p) => p.id != postId).toList());
  }
}

final postsProvider =
    StateNotifierProvider<PostsNotifier, AsyncValue<List<PostModel>>>(
  (ref) => PostsNotifier(),
);

// ── Posts (Following feed) ─────────────────────────────
class FollowingPostsNotifier
    extends StateNotifier<AsyncValue<List<PostModel>>> {
  final String currentUserId;
  FollowingPostsNotifier(this.currentUserId)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final posts =
          await CommunityRepository.instance.getFollowingPosts(currentUserId);
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleLike(String postId, bool isLiked) async {
    await CommunityRepository.instance.toggleLike(postId, !isLiked);
    final current = state.valueOrNull ?? [];
    state = AsyncValue.data(current.map((p) {
      if (p.id != postId) return p;
      return p.copyWith(
        likes: isLiked ? p.likes - 1 : p.likes + 1,
        isLiked: !isLiked,
      );
    }).toList());
  }
}

final followingPostsProvider =
    StateNotifierProvider<FollowingPostsNotifier, AsyncValue<List<PostModel>>>(
        (ref) {
  final user = ref.watch(currentUserProvider);
  return FollowingPostsNotifier(user?.id ?? '');
});

// ── Comments ───────────────────────────────────────────
class CommentsNotifier extends StateNotifier<AsyncValue<List<CommentModel>>> {
  final String postId;
  CommentsNotifier(this.postId) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final comments = await CommunityRepository.instance.getComments(postId);
      state = AsyncValue.data(comments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addComment(CommentModel comment) async {
    await CommunityRepository.instance.addComment(comment);
    await _load();
  }
}

final commentsProvider = StateNotifierProvider.family<CommentsNotifier,
    AsyncValue<List<CommentModel>>, String>(
  (ref, postId) => CommentsNotifier(postId),
);

// ── Groups ─────────────────────────────────────────────
final groupsProvider =
    FutureProvider.family<List<GroupModel>, String?>((ref, county) async {
  await CommunityRepository.instance.createTables();
  await CommunityRepository.instance.seedCommunity();
  return CommunityRepository.instance.getGroups(county: county);
});

// ── Follow state for a specific target user ────────────
final isFollowingProvider =
    FutureProvider.family<bool, String>((ref, targetUserId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  return CommunityRepository.instance.isFollowing(user.id, targetUserId);
});

// ── Follow counts ──────────────────────────────────────
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
class FollowNotifier extends StateNotifier<bool> {
  final String currentUserId;
  final String targetUserId;
  final Ref _ref;

  FollowNotifier(this.currentUserId, this.targetUserId, this._ref, bool initial)
      : super(initial);

  Future<void> toggle() async {
    final wasFollowing = state;
    state = !wasFollowing;
    try {
      if (wasFollowing) {
        await CommunityRepository.instance
            .unfollow(currentUserId, targetUserId);
      } else {
        await CommunityRepository.instance.follow(currentUserId, targetUserId);
      }
      // Refresh following feed
      _ref.read(followingPostsProvider.notifier).load();
    } catch (_) {
      state = wasFollowing; // revert on error
    }
  }
}

final followNotifierProvider = StateNotifierProvider.family<FollowNotifier,
    bool, ({String currentUserId, String targetUserId, bool initial})>(
  (ref, args) => FollowNotifier(
    args.currentUserId,
    args.targetUserId,
    ref,
    args.initial,
  ),
);
