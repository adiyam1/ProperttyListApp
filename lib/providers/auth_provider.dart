import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/auth_util.dart';
import '../core/services/auth_service.dart';
import '../db/database_helper.dart';
import '../models/user.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'Override sharedPrefsProvider with SharedPreferences.getInstance()',
  );
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(sharedPrefsProvider));
});

final authNotifierProvider = Provider<AuthNotifier>((ref) => AuthNotifier(ref));


// User (current session)

class UserNotifier extends AsyncNotifier<UserModel?> {
  final _db = DatabaseHelper.instance;

  @override
  FutureOr<UserModel?> build() async {
    final auth = ref.read(authServiceProvider);
    final id = await auth.getCurrentUserId();
    if (id == null) return null;
    return await _db.getUserById(id);
  }

  Future<void> updateUser(UserModel updatedUser) async {
    await _db.saveUser(updatedUser);
    state = AsyncData(updatedUser);
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, UserModel?>(() {
  return UserNotifier();
});


// Auth actions

class AuthNotifier {
  final Ref _ref;
  final _db = DatabaseHelper.instance;

  AuthNotifier(this._ref);

  AuthService get _auth => _ref.read(authServiceProvider);

  Future<String?> signIn(String email, String password, UserRole role) async {
    final e = email.trim().toLowerCase();
    final p = password.trim();
    if (e.isEmpty || p.isEmpty) return 'Email and password required';

    final user = await _db.getUserByEmail(e);
    if (user == null) return 'No account with this email';

    if (!verifyPassword(p, user.passwordHash)) return 'Incorrect password';

    if (user.role != role) {
      return 'This account is ${user.role.displayName}. Sign in as ${user.role.displayName}.';
    }

    await _auth.setCurrentUserId(user.id!);
    _ref.invalidate(userProvider);
    return null;
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final n = name.trim();
    final e = email.trim().toLowerCase();
    final p = password.trim();
    if (n.isEmpty || e.isEmpty || p.isEmpty) {
      return 'Name, email and password required';
    }
    if (p.length < 6) return 'Password must be at least 6 characters';

    final existing = await _db.getUserByEmail(e);
    if (existing != null) return 'An account with this email already exists';

    final user = UserModel(
      name: n,
      email: e,
      passwordHash: hashPassword(p),
      role: role,
      createdAt: DateTime.now(),
    );

    await _db.saveUser(user);
    final saved = await _db.getUserByEmail(e);
    if (saved == null) return 'Registration failed';

    await _auth.setCurrentUserId(saved.id!);
    _ref.invalidate(userProvider);
    return null;
  }

  Future<void> signOut() async {
    await _auth.clearCurrentUserId();
    _ref.invalidate(userProvider);
  }
}
