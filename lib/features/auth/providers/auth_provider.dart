import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repository/auth_repository.dart';
import '../../../core/services/firestore_service.dart';
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
  final _firestore = FirestoreService();

  // Prevents the Firebase auth stream (_init) from overwriting the state
  // that login() / register() is in the middle of setting. Without this flag,
  // Firebase fires authStateChanges BEFORE login() has finished writing to
  // Firestore/SQLite. _init() then hits the fallback (role: UserRole.user),
  // races with the correct state from login(), and causes a redirect loop
  // back to the login screen for regular 'user' role accounts.
  bool _authOperationInProgress = false;

  void _init() {
    _repo.authStateChanges.listen((User? firebaseUser) async {
      // Skip stream events while login() or register() is actively running.
      // Those methods manage state themselves and will set the final
      // authenticated state with the correct role when complete.
      if (_authOperationInProgress) return;

      if (firebaseUser != null) {
        // 1. Try local cache first (handles normal app restarts)
        final cached = await _repo.getCachedUser(firebaseUser.uid);
        if (cached != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: cached,
          );
          return;
        }

        // 2. Cache miss — fetch full profile (including role) from Firestore.
        // Handles fresh installs or cleared app storage.
        final firestoreUser = await _firestore.getUser(firebaseUser.uid);
        if (firestoreUser != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: firestoreUser,
          );
          return;
        }

        // 3. Absolute fallback — user in Auth but not in Firestore.
        // Only happens for accounts created before this integration.
        final fallback = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          displayName: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
          role: UserRole.user,
          isVerified: firebaseUser.emailVerified,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: fallback,
        );
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
    _authOperationInProgress = true;
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
    } finally {
      _authOperationInProgress = false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _authOperationInProgress = true;
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
    } finally {
      // Always clear the flag — even on error — so the stream
      // resumes normal operation (e.g. for sign out events).
      _authOperationInProgress = false;
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
