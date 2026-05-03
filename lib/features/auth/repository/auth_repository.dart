import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/firestore_service.dart';
import '../../../shared/models/user_model.dart';

class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  // ── Current Firebase User Stream ───────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  // ── Register ───────────────────────────────────────────
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
    UserRole role = UserRole.user,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.updateDisplayName(displayName.trim());
      await credential.user?.sendEmailVerification();

      final user = UserModel(
        id: credential.user!.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Persist to Firestore (source of truth) and SQLite (local cache)
      await _firestore.createUser(user);
      await _cacheUser(user);
      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  // ── Login ──────────────────────────────────────────────
  // FIX: Role is not stored in Firebase Auth — it must be read from
  // Firestore (source of truth) or the local SQLite cache. The old
  // implementation always built a UserModel with the default role
  // (UserRole.user), which caused regular users and company users to
  // both appear as 'user' after login, breaking role-based routing.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;

      // 1. Try local SQLite cache first (fast, no network round-trip)
      final cached = await getCachedUser(uid);
      if (cached != null) {
        // Refresh mutable Firebase Auth fields (email verified status, photo)
        // but keep the role from the trusted cache.
        final refreshed = UserModel(
          id: cached.id,
          email: credential.user!.email!,
          displayName: credential.user!.displayName ?? cached.displayName,
          photoUrl: credential.user!.photoURL ?? cached.photoUrl,
          role: cached.role, // ← preserve stored role
          phone: cached.phone,
          bio: cached.bio,
          isVerified: credential.user!.emailVerified,
          createdAt: cached.createdAt,
          updatedAt: DateTime.now(),
        );
        await _cacheUser(refreshed);
        return refreshed;
      }

      // 2. Cache miss (fresh install / cleared data) — fetch from Firestore
      final firestoreUser = await _firestore.getUser(uid);
      if (firestoreUser != null) {
        final synced = UserModel(
          id: firestoreUser.id,
          email: credential.user!.email!,
          displayName:
              credential.user!.displayName ?? firestoreUser.displayName,
          photoUrl: credential.user!.photoURL ?? firestoreUser.photoUrl,
          role: firestoreUser.role, // ← role from Firestore
          phone: firestoreUser.phone,
          bio: firestoreUser.bio,
          isVerified: credential.user!.emailVerified,
          createdAt: firestoreUser.createdAt,
          updatedAt: DateTime.now(),
        );
        await _cacheUser(synced); // re-populate local cache
        return synced;
      }

      // 3. Fallback — user exists in Firebase Auth but not in Firestore
      // (e.g. accounts created before this integration). Default to 'user' role.
      final fallback = UserModel(
        id: uid,
        email: credential.user!.email!,
        displayName: credential.user!.displayName,
        photoUrl: credential.user!.photoURL,
        role: UserRole.user,
        isVerified: credential.user!.emailVerified,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _cacheUser(fallback);
      return fallback;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  // ── Forgot Password ────────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e);
    }
  }

  // ── Sign Out ───────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
    await _clearCachedUser();
  }

  // ── Get Cached User ────────────────────────────────────
  Future<UserModel?> getCachedUser(String uid) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [uid],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }

  // ── Cache User to SQLite ───────────────────────────────
  Future<void> _cacheUser(UserModel user) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── Clear Cached User ──────────────────────────────────
  Future<void> _clearCachedUser() async {
    final db = await DatabaseHelper.instance.database;
    final uid = currentFirebaseUser?.uid;
    if (uid != null) {
      await db.delete('users', where: 'id = ?', whereArgs: [uid]);
    }
  }

  // ── Map Firebase Errors to readable messages ───────────
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'invalid-credential':
        return 'Incorrect email or password.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}
