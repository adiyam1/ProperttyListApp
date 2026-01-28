import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:propert_list/providers/auth_provider.dart';

import '../db/database_helper.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier(ref);
});

class ThemeNotifier extends StateNotifier<bool> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Ref _ref;

  ThemeNotifier(this._ref) : super(false) {
    _initTheme();
  }

  Future<void> _initTheme() async {
    final auth = _ref.read(authServiceProvider);
    final id = await auth.getCurrentUserId();
    if (id != null) {
      final user = await _db.getUserById(id);
      if (user != null) state = user.isDarkMode;
    }
  }

  Future<void> toggleTheme() async {
    state = !state;

    // Access the user state from the AsyncNotifier
    final userState = _ref.read(userProvider);

    // Check if the user is loaded (AsyncData)
    if (userState is AsyncData && userState.value != null) {
      final user = userState.value!;
      if (user.id != null) {
        // Persist theme choice
        await _db.updateUserTheme(user.id!, state);

        //  This will now work perfectly!
        await _ref.read(userProvider.notifier).updateUser(
          user.copyWith(isDarkMode: state),
        );
      }
    }
  }
}