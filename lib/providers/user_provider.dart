import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/database_helper.dart';
import '../models/user.dart';

class UserNotifier extends AsyncNotifier<UserModel?> {
  final _db = DatabaseHelper.instance;

  @override
  FutureOr<UserModel?> build() async {
    // This loads the user from SQLite when the app starts
    return await _db.getUser();
  }

  /// ✅ THIS IS THE MISSING METHOD
  /// This updates the database and the UI state simultaneously
  Future<void> updateUser(UserModel updatedUser) async {
    // 1. Update SQLite so the change is permanent
    await _db.saveUser(updatedUser);

    // 2. Update the 'state' so all widgets watching userProvider rebuild
    state = AsyncData(updatedUser);
  }
}

// Ensure the provider is defined using the class above
final userProvider = AsyncNotifierProvider<UserNotifier, UserModel?>(() {
  return UserNotifier();
});