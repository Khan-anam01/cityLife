import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repository/auth_repository.dart';
import '../../../shared/models/user_model.dart';

// ── Auth State ─────────────────────────────────────────
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
}

// ── Auth Notifier ──────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  final _repo = AuthRepository.instance;

  void _init() {
    _repo.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        final cached = await _repo.getCachedUser(firebaseUser.uid);
        if (cached != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: cached,
          );
        } else {
          // User exists in Firebase but not cached — build from Firebase
          final user = UserModel(
            id: firebaseUser.uid,
            email: firebaseUser.email!,
            displayName: firebaseUser.displayName,
            photoUrl: firebaseUser.photoURL,
            isVerified: firebaseUser.emailVerified,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          );
        }
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
        );
      }
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
    UserRole role = UserRole.user,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final user = await _repo.register(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      final user = await _repo.login(email: email, password: password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _repo.sendPasswordReset(email);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ── Providers ─────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
