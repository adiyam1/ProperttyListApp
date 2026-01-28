import 'package:shared_preferences/shared_preferences.dart';

const _keyCurrentUserId = 'current_user_id';

class AuthService {
  final SharedPreferences _prefs;

  AuthService(this._prefs);

  Future<int?> getCurrentUserId() async {
    final id = _prefs.getInt(_keyCurrentUserId);
    return id;
  }

  Future<void> setCurrentUserId(int id) async {
    await _prefs.setInt(_keyCurrentUserId, id);
  }

  Future<void> clearCurrentUserId() async {
    await _prefs.remove(_keyCurrentUserId);
  }
}
